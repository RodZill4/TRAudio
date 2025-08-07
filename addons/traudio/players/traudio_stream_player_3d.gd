@tool
class_name TRAudioStreamPlayer3D
extends AudioStreamPlayer3D

## An AudioStreamPlayer3D that can play sounds by name.

## String replaces that are applied to the sound names when calling [method play_sound].
@export var replaces : Dictionary[String, String] = {}


## Play a sound by (hierarchical) name (specified in [param sound_name]).
func play_sound(sound_name : String):
	TRAudio.get_sound(sound_name, replaces).play_on_audio_stream_player_3d(self)
