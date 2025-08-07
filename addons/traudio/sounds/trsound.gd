@tool
class_name TRSound
extends TRSoundBase


@export var name : String
@export var stream : AudioStream
@export var volume_db : float = 0.0
@export var pitch_scale : Vector2 = Vector2(1.0, 1.0)
@export var volume_randomness : float = 0.0
@export var bus : String = ""
@export var asp3d_attenuation_model : AudioStreamPlayer3D.AttenuationModel = AudioStreamPlayer3D.ATTENUATION_INVERSE_DISTANCE
@export var asp3d_unit_size : float = 10
@export var asp3d_max_db : float = 3.0
@export var asp3d_max_distance : float = 0.0


func _to_string():
	return "volume = "+str(volume_db)

func play_on_audio_stream_player(audio_stream_player : AudioStreamPlayer):
	#print("play_on_audio_stream_player ", name)
	audio_stream_player.stream = stream
	audio_stream_player.volume_db = randf_range(volume_db-volume_randomness, volume_db+volume_randomness)
	audio_stream_player.pitch_scale = randf_range(pitch_scale.x, pitch_scale.y)
	if not Engine.is_editor_hint():
		audio_stream_player.bus = bus
	audio_stream_player.play()

func play_on_audio_stream_player_2d(audio_stream_player_2d : AudioStreamPlayer2D):
	#print("play_on_audio_stream_player_2d ", name)
	audio_stream_player_2d.stream = stream
	audio_stream_player_2d.volume_db = randf_range(volume_db-volume_randomness, volume_db+volume_randomness)
	audio_stream_player_2d.pitch_scale = randf_range(pitch_scale.x, pitch_scale.y)
	if not Engine.is_editor_hint():
		audio_stream_player_2d.bus = bus
	audio_stream_player_2d.play()

func play_on_audio_stream_player_3d(audio_stream_player_3d : AudioStreamPlayer3D):
	#print("play_on_audio_stream_player_3d ", name)
	audio_stream_player_3d.stream = stream
	audio_stream_player_3d.volume_db = randf_range(volume_db-volume_randomness, volume_db+volume_randomness)
	audio_stream_player_3d.pitch_scale = randf_range(pitch_scale.x, pitch_scale.y)
	if not Engine.is_editor_hint():
		audio_stream_player_3d.bus = bus
	audio_stream_player_3d.attenuation_model = asp3d_attenuation_model
	audio_stream_player_3d.unit_size = asp3d_unit_size
	audio_stream_player_3d.max_db = asp3d_max_db
	audio_stream_player_3d.max_distance = asp3d_max_distance
	for c in TRAudio.audio_stream_player_3d_callbacks:
		c.call(audio_stream_player_3d)
	audio_stream_player_3d.add_to_group("trasp3d")
	audio_stream_player_3d.play()
