@tool
extends Tree

func _get_drag_data(_at_position: Vector2) -> Variant:
	var item : TreeItem = get_selected()
	var label : Label = Label.new()
	label.text = item.get_text(0)
	set_drag_preview(label)
	return item

func _can_drop_data(at_position, data):
	var item : TreeItem = get_item_at_position(at_position)
	if data is TreeItem:
		if item == null:
			item = get_root()
		# Cannot move item to its parent because it's already in there
		if item == data.get_parent():
			return null
		 # Cannot move item inside itself
		var parent : TreeItem = item
		while parent:
			if parent == data:
				return false
			parent = parent.get_parent()
		return true
	elif data is Dictionary and data["type"] == "files":
		if item == null:
			return false
		return true

func _drop_data(at_position, data):
	var item : TreeItem = get_item_at_position(at_position)
	if data is TreeItem:
		var new_parent_item : TRSoundItem
		if item == null:
			new_parent_item = owner.database
		else:
			new_parent_item = item.get_metadata(0).children[item.get_metadata(1)]
		var old_parent_item : TRSoundItem = data.get_metadata(0) as TRSoundItem
		var old_item_name : String = data.get_metadata(1) as String
		var new_item_name : String = old_item_name
		var new_item_name_index : int = 1
		while new_item_name in new_parent_item.children:
			new_item_name_index += 1
			new_item_name = old_item_name+str(new_item_name_index)
		new_parent_item.children[new_item_name] = old_parent_item.children[old_item_name]
		old_parent_item.children.erase(old_item_name)
		owner.save_database()
		owner.refresh()
	elif data is Dictionary and data["type"] == "files":
		if item == null:
			return
		var sound_item : TRSoundItem = item.get_metadata(0).children[item.get_text(0)]
		if data["type"] == "files":
			var streams : Array[AudioStream] = []
			for i in data["files"].size():
				var stream : AudioStream = load(data["files"][i]) as AudioStream
				if stream:
					streams.append(stream)
			if streams.is_empty():
				return
			if streams.size() == 1:
				sound_item.stream = streams[0]
			else:
				for s in streams:
					sound_item.add_child(item.get_text(0), true).stream = s
			owner.save_database()
			owner.refresh()
