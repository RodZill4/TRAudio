class_name TRSoundPlayer
extends Node


## A sound player that adapts to its parent.
##
## TRSoundPlayer will create an
## AudioStreamPlayer3D if its parent is a Node3D, an
## AudioStreamPlayer2D if its parent is a Node2D, and an
## AudioStreamPlayer otherwise.
## [br]
## Just like TRAudioStreamPlayer, TRAudioStreamPlayer2D and 
## TRAudioStreamPlayer3D, it is well suited for playing sounds
## from an AnimationPlayer (that calls the play_sound function),
## but is able to layer sounds if needed.

## String replaces that are applied to the sound names when calling [method play_sound].
@export var replaces : Dictionary[String, String] = {}


## Play a sound by (hierarchical) name (specified in [param sound_name]) using an AudioStreamPlayer.
func play_sound(sound_name : String):
	var parent : Node = get_parent()
	if parent is Node2D:
		TRAudio.play_sound_2d(sound_name, parent, replaces)
	elif parent is Node3D:
		TRAudio.play_sound_3d(sound_name, parent, replaces)
	else:
		TRAudio.play_sound(sound_name, replaces)
