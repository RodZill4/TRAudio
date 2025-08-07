@tool
class_name TRSoundItem
extends Resource


@export var stream : AudioStream = null
@export var volume_db : float = 0
@export var children : Dictionary[String, TRSoundItem] = {}
@export var parameters : Dictionary[String, Variant] = {}
@export var collapsed : bool = false


func add_child(prefix : String, always_prefix : bool = false) -> TRSoundItem:
	var new_item_name : String = prefix
	var new_item_index : int = 1
	if always_prefix:
		new_item_name += "1"
	while new_item_name in children:
		new_item_index += 1
		new_item_name = prefix+str(new_item_index)
	children[new_item_name] = TRSoundItem.new()
	return children[new_item_name]
