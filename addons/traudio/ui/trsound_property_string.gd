@tool
extends LineEdit


@export var key : String


signal value_changed(key, value)


func set_key_and_value(k, v, field_def):
	key = k
	text = v

func _on_text_submitted(value : String):
	value_changed.emit(key, value)
