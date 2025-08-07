@tool
extends HBoxContainer


@export var key : String
@export var value : Vector2


signal value_changed(key, value)


var minimum : EditorSpinSlider
var maximum : EditorSpinSlider


func _ready():
	pass

func set_key_and_value(k : String, v, field_def : Dictionary):
	key = k
	value = v
	var float_edit : EditorSpinSlider
	float_edit = EditorSpinSlider.new()
	if "range" in field_def:
		float_edit.min_value = field_def.range.x
		float_edit.max_value = field_def.range.y
	float_edit.step = 0
	float_edit.value = value.x
	float_edit.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	add_child(float_edit)
	float_edit.value_changed.connect(self.update_field.bind(0))
	float_edit = EditorSpinSlider.new()
	if "range" in field_def:
		float_edit.min_value = field_def.range.x
		float_edit.max_value = field_def.range.y
	float_edit.step = 0
	float_edit.value = value.y
	float_edit.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	add_child(float_edit)
	float_edit.value_changed.connect(self.update_field.bind(1))

func update_field(v : float, index : int):
	value[index] = v
	update.call_deferred()

var need_update : bool = false
var updating : bool = false

func update():
	need_update = true
	if updating:
		return
	updating = true
	while need_update:
		need_update = false
		await get_tree().create_timer(0.1).timeout
	updating = false
	value_changed.emit(key, value)
