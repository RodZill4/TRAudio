@tool
extends OptionButton


@export var key : String


signal value_changed(key, value)


func set_key_and_value(k, v, field_def):
	key = k
	clear()
	for value in field_def.values:
		add_item(value)
	selected = v

func _on_item_selected(index):
	value_changed.emit(key, index)
