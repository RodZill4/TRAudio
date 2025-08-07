extends Node
class_name TRUiSfxSetup

## Applies sounds recursively to the UI elements in its parent node.
## The sounds must be named after the following convention:
## [i]prefix[/i]/[i]ControlType[/i]/[i]signal_name[/i]
## for example, a sound named [b]ui/sfx/BaseButton/pressed[/b] will be
## played when a button in the parent's hierarchy is pressed.

## Set to true to apply automatically the sounds to the UI
@export var auto : bool = true
## The prefix of the sounds used for the UI
@export var prefix : String = "ui/sfx"

func _ready():
	if auto:
		apply()

## Apply the sounds to the UI
func apply():
	Utilities.call_recursive(get_parent(), self._set_sounds)

## Remove the sounds from the UI
func remove():
	Utilities.call_recursive(get_parent(), self._unset_sounds)

func _set_sounds(node : Node) -> bool:
	for k : String in TRAudio._sounds.keys():
		if not k.begins_with(prefix+"/"):
			continue
		var split = k.trim_prefix(prefix+"/").split("/")
		var script : Script = node.get_script()
		if split.size() == 2 and (node.is_class(split[0]) or script and script.get_global_name() == split[0]):
			node.connect(split[1], TRAudio.play_sound.bind(k))
	return true

func _unset_sounds(node : Node) -> bool:
	for k : String in TRAudio._sounds.keys():
		if not k.begins_with(prefix+"/"):
			continue
		var split = k.trim_prefix(prefix+"/").split("/")
		var script : Script = node.get_script()
		if split.size() == 2 and (node.is_class(split[0]) or script and script.get_global_name() == split[0]):
			node.disconnect(split[1], TRAudio.play_sound.bind(k))
	return true
