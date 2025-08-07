@tool
extends VBoxContainer


var database : TRDataBase


func _ready():
	load_database()
	$ToolBar/Add.icon = EditorInterface.get_editor_theme().get_icon("Add", "EditorIcons")
	%Play.icon = EditorInterface.get_editor_theme().get_icon("Play", "EditorIcons")
	%Stop.icon = EditorInterface.get_editor_theme().get_icon("Stop", "EditorIcons")
	%Tree.set_column_title(0, "Action")
	%Tree.set_column_title(1, "Sound")
	%Tree.set_column_title(2, "Volume")
	%Tree.set_column_expand_ratio(1, 2)
	%Tree.set_column_expand(2, false)
	%Tree.set_column_custom_minimum_width(2, 150)
	refresh()

func load_database():
	var db = load("res://traudio_db.tres")
	if db == null:
		database = TRDataBase.new()
		database.sounds = TRSoundItem.new()
		save_database()
	elif db is TRDataBase:
		database = db
	elif db is TRSoundItem:
		print("Converting database...")
		database = TRDataBase.new()
		database.sounds = db

func save_database():
	ResourceSaver.save(database.duplicate(true), "res://traudio_db.tres")
	print("saved")

func refresh():
	var selected_name : String = ""
	if %Tree.get_selected():
		selected_name = get_item_sound_name(%Tree.get_selected())
	%Tree.clear()
	%Tree.create_item(%Tree.get_root(), -1)
	fill_tree(%Tree.get_root(), database.sounds)
	%Tree.get_root().collapsed = false
	if selected_name != "":
		var item : TreeItem = %Tree.get_root()
		for n in selected_name.split("/"):
			var found : bool = false
			for child_item : TreeItem in item.get_children():
				if child_item.get_text(0) == n:
					found = true
					item = child_item
					break
			if not found:
				return
		%Tree.set_selected(item, 0)

func update_item(ti : TreeItem, sound : TRSoundItem):
	if sound.stream:
		ti.set_text(1, sound.stream.get_path().get_file())
		ti.set_icon(0, EditorInterface.get_editor_theme().get_icon("AudioStreamPlayer", "EditorIcons"))
	else:
		ti.set_icon(0, EditorInterface.get_editor_theme().get_icon("Folder", "EditorIcons"))
	ti.set_text(2, str(sound.volume_db)+"db")

func fill_tree(ti : TreeItem, d : TRSoundItem):
	var keys : Array = d.children.keys()
	keys.sort()
	for i in keys:
		var new_item : TreeItem = %Tree.create_item(ti, -1)
		new_item.set_text(0, i)
		var sound : TRSoundItem = d.children[i]
		update_item(new_item, sound)
		new_item.set_editable(2, true)
		new_item.set_editable(0, true)
		new_item.set_metadata(0, d)
		new_item.set_metadata(1, i)
		fill_tree(new_item, sound)
		if sound:
			new_item.collapsed = sound.collapsed

func _on_add_pressed():
	var selected : TreeItem = %Tree.get_selected()
	var parent : TRSoundItem = database.sounds
	if selected:
		parent = selected.get_metadata(0).children[selected.get_metadata(1)]
	parent.add_child("#new_item")
	save_database()
	refresh()

func _on_reload_pressed():
	EditorInterface.set_plugin_enabled("TRAudio", false)
	await get_tree().create_timer(0.1).timeout
	EditorInterface.set_plugin_enabled("TRAudio", true)

func _on_tree_item_edited():
	var s : TreeItem = %Tree.get_selected()
	var old_name : String = s.get_metadata(1)
	var new_name : String = s.get_text(0)
	var parent : TRSoundItem = s.get_metadata(0)
	if old_name != new_name:
		if not new_name in parent.children:
			if new_name != "":
				parent.children[new_name] = parent.children[old_name]
			parent.children.erase(old_name)
			s.set_metadata(1, new_name)
	else:
		parent.children[new_name].volume_db = s.get_text(2).to_float()
	save_database()
	refresh()

func get_item_sound_name(ti : TreeItem) -> String:
	var sound_name : String = ti.get_text(0)
	while true:
		ti = ti.get_parent()
		if ti == %Tree.get_root():
			break
		sound_name = ti.get_text(0)+"/"+sound_name
	return sound_name

func _on_play_pressed():
	TRAudio.update_sound_collection(database.sounds)
	var s : TreeItem = %Tree.get_selected()
	var sound_name : String = get_item_sound_name(s)
	TRAudio.get_sound(sound_name).play_on_audio_stream_player($AudioStreamPlayer)

func _on_stop_pressed():
	$AudioStreamPlayer.stop()

func update_volume(value : float, sound : TRSoundItem):
	sound.volume_db = value
	update_item(%Tree.get_selected(), sound)

class AudioStreamProxy:
	var panel : Control
	var sound : TRSoundItem
	@export var stream : AudioStream:
		set(v):
			stream = v
			if sound.stream != stream:
				sound.stream = stream
				panel.save_database()
				panel.refresh()
	func _init(p, s):
		panel = p
		sound = s
		stream = sound.stream

var audio_stream_proxy : AudioStreamProxy

func _on_tree_item_selected():
	# Clear attributes view
	while %Attributes.get_child_count() > 0:
		var c = %Attributes.get_child(0)
		%Attributes.remove_child(c)
		c.queue_free()
	#Show attributes or stream
	var s : TreeItem = %Tree.get_selected()
	DisplayServer.clipboard_set(get_item_sound_name(s))
	var sound : TRSoundItem = s.get_metadata(0).children[s.get_metadata(1)]
	if %ShowProperties.button_pressed:
		var grid : GridContainer = GridContainer.new()
		grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		#grid.size_flags_vertical = Control.SIZE_EXPAND_FILL
		grid.columns = 3
		%Attributes.add_child(grid)
		grid.add_child(Control.new())
		var name_label : Label = Label.new()
		name_label.text = "Volume"
		grid.add_child(name_label)
		var float_edit : EditorSpinSlider
		float_edit = EditorSpinSlider.new()
		float_edit.min_value = -100
		float_edit.max_value = 20
		float_edit.suffix = "db"
		float_edit.value = sound.volume_db
		float_edit.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		float_edit.value_changed.connect(self.update_volume.bind(sound))
		grid.add_child(float_edit)
		var keys : Array = sound.parameters.keys()
		keys.sort()
		for f in keys:
			var delete_button : Button = Button.new()
			delete_button.icon = EditorInterface.get_editor_theme().get_icon("Remove", "EditorIcons")
			grid.add_child(delete_button)
			delete_button.pressed.connect(self.remove_property.bind(f))
			name_label = Label.new()
			name_label.text = f
			grid.add_child(name_label)
			var control_scene : PackedScene = load("res://addons/traudio/ui/trsound_property_"+TRAudio.FIELDS[f].type+".tscn")
			if control_scene == null:
				grid.add_child(Control.new())
				continue
			var control : Control = control_scene.instantiate()
			control.set_key_and_value(f, sound.parameters[f], TRAudio.FIELDS[f])
			grid.add_child(control)
			control.value_changed.connect(self.set_property)
		var add_fields : OptionButton = OptionButton.new()
		add_fields.add_item("Add property...", 1000)
		var index : int = 0
		keys = TRAudio.FIELDS.keys()
		keys.sort()
		for f in keys:
			add_fields.add_item(f, index)
			index += 1
		%Attributes.add_child(add_fields)
		add_fields.item_selected.connect(self.add_property.bind(add_fields))
	else:
		audio_stream_proxy = AudioStreamProxy.new(self, sound)
		var editor_inspector : EditorInspector = EditorInspector.new()
		%Attributes.add_child(editor_inspector)
		editor_inspector.edit(audio_stream_proxy)
		editor_inspector.size_flags_vertical = Control.SIZE_EXPAND_FILL

func add_property(index : int, add_fields : OptionButton):
	var id : int = add_fields.get_item_id(index)
	var keys : Array = TRAudio.FIELDS.keys()
	keys.sort()
	if id >= keys.size():
		return
	var s : TreeItem = %Tree.get_selected()
	var sound : TRSoundItem = s.get_metadata(0).children[s.get_metadata(1)]
	sound.parameters[keys[id]] = TRAudio.FIELDS[keys[id]].default
	save_database()
	_on_tree_item_selected()

func remove_property(n : String):
	var s : TreeItem = %Tree.get_selected()
	var sound : TRSoundItem = s.get_metadata(0).children[s.get_metadata(1)]
	sound.parameters.erase(n)
	save_database()
	_on_tree_item_selected()

func set_property(n : String, v):
	var s : TreeItem = %Tree.get_selected()
	var sound : TRSoundItem = s.get_metadata(0).children[s.get_metadata(1)]
	sound.parameters[n] = v
	save_database()
	_on_tree_item_selected()

func _on_show_properties_toggled(toggled_on):
	_on_tree_item_selected()


func _on_tree_item_collapsed(item):
	item.get_metadata(0).children[item.get_metadata(1)].collapsed = item.collapsed
