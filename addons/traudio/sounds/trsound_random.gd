@tool
class_name TRSoundRandom
extends TRSoundBase


var sounds : Array[TRSound] = []


func play_on_audio_stream_player(audio_stream_player : AudioStreamPlayer):
	sounds[randi_range(0, sounds.size())-1].play_on_audio_stream_player(audio_stream_player)

func play_on_audio_stream_player_2d(audio_stream_player_2d : AudioStreamPlayer2D):
	sounds[randi_range(0, sounds.size())-1].play_on_audio_stream_player_2d(audio_stream_player_2d)

func play_on_audio_stream_player_3d(audio_stream_player_3d : AudioStreamPlayer3D):
	sounds[randi_range(0, sounds.size())-1].play_on_audio_stream_player_3d(audio_stream_player_3d)
