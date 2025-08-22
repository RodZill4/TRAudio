@tool
class_name TRAudioAddon
extends Node


## The TRAudio addon for Godot is meant for separating the _sounds
## and their associated parameters from the scenes and code they
## are used in, so sound designers and developers can focus on
## their tasks.
##
## Sounds are declared and defined in a tree view in the TRAudio
## tab in Godot's UI, and referenced in the codes and scenes using
## their hierarchical name.
## [br]
## TRAudio is the name of the main global for this addon, and is
## used for most of its features. All methods here can be called
## as [b]TRAudio.[i]method_name[/i][/b] anywhere in the code.


var _database : TRDataBase
var _sounds : Dictionary[String, TRSoundBase] = {}
var audio_stream_player_3d_callbacks : Array[Callable]

const FIELDS : Dictionary[String, Dictionary] = {
	bus = { type="string", default = "" },
	volume_randomness = { type="float", default=0.0, range=Vector2(0.00, 8.0) },
	pitch_scale = { type="random_float", default=Vector2(1.0, 1.0), range=Vector2(0.01, 4.0) },
	asp3d_attenuation_model = { type="enum", default=0, values=["Inverse", "Inverse Square", "Logarithmic", "Disabled"] },
	asp3d_unit_size = { type="float", default=10, range=Vector2(0.1, 100) },
	asp3d_max_db = { type="float", default=3.0, range=Vector2(-24, 6.0) },
	asp3d_max_distance = { type="float", default=0.0, range=Vector2(0, 4096) }
}

func _enter_tree():
	var db = load("res://traudio_db.tres")
	if db is TRDataBase:
		_database = db
	elif db is TRSoundItem:
		print("Converting _database...")
		_database = TRDataBase.new()
		_database.sounds = db
	update_sound_collection(_database.sounds)

func update_sound_collection(item : TRSoundItem, prefix : String = "", sound : TRSound = TRSound.new()) -> Array[TRSound]:
	if prefix == "":
		_sounds = {}
	var rv : Array[TRSound] = []
	var new_sound : TRSound = sound.duplicate()
	if item.stream:
		new_sound.stream = item.stream
	new_sound.volume_db += item.volume_db
	for k in item.parameters.keys():
		if k in FIELDS.keys():
			new_sound.set(k, item.parameters[k])
	if new_sound.stream:
		new_sound.name = prefix
		_sounds[prefix] = new_sound
		rv.append(new_sound)
	var separator : String = ""
	if prefix != "":
		separator = "/"
	for n in item.children.keys():
		rv.append_array(update_sound_collection(item.children[n], prefix+separator+n, new_sound))
	if new_sound.stream == null:
		_sounds[prefix] = TRSoundRandom.new()
		_sounds[prefix].sounds = rv.duplicate()
	return rv

## Get a sound by (hierarchical) name. Note that selecting a sound in the
## TreeView of the TRAudio tab will copy its hierarchical name, so it can
## easily be pasted into your code or the inspector.
## The [param replaces] parameter is used to replace substrings of the sound name with others,
## and is useful to play different sounds depending on the context (for example different
## footstep sounds depending on the character and the ground surface).
func get_sound(sound_name : String, replaces : Dictionary[String, String] = {}) -> TRSoundBase:
	for k in replaces.keys():
		sound_name = sound_name.replace(k, replaces[k])
	if sound_name in _sounds:
		return _sounds[sound_name]
	else:
		print("missing sound ", sound_name)
		return null

## Play a sound by (hierarchical) name (specified in [param sound_name]) using an AudioStreamPlayer.
## The [param replaces] parameter is used to replace substrings of the sound name with others,
## and is useful to play different sounds depending on the context (for example different
## footstep sounds depending on the character and the ground surface).
func play_sound(sound_name : String, replaces : Dictionary[String, String] = {}):
	get_sound(sound_name, replaces).play_on_audio_stream_player(get_audio_stream_player())

## Play a sound by (hierarchical) name (specified in [param sound_name]) using an AudioStreamPlayer2D.
## The [param node] parameter is used as parent of the AudioStreamPlayer2D, and the AudioStreamPlayer2D will be freed after the sound is played.
## The [param replaces] parameter is used to replace substrings of the sound name with others,
## and is useful to play different sounds depending on the context (for example different
## footstep sounds depending on the character and the ground surface).
func play_sound_2d(sound_name : String, node : Node2D, replaces : Dictionary[String, String] = {}):
	get_sound(sound_name, replaces).play_on_audio_stream_player_2d(get_audio_stream_player_2d(node))

## Play a sound by (hierarchical) name (specified in [param sound_name]) using an AudioStreamPlayer3D.
## The [param node] parameter is used as parent of the AudioStreamPlayer3D, and the AudioStreamPlayer3D will be freed after the sound is played.
## The [param replaces] parameter is used to replace substrings of the sound name with others,
## and is useful to play different sounds depending on the context (for example different
## footstep sounds depending on the character and the ground surface).
func play_sound_3d(sound_name : String, node : Node3D, replaces : Dictionary[String, String] = {}):
	get_sound(sound_name, replaces).play_on_audio_stream_player_3d(get_audio_stream_player_3d(node))

var _audio_stream_players_pool : Array[AudioStreamPlayer] = []
var _audio_stream_players_2d_pool : Array[AudioStreamPlayer2D] = []
var _audio_stream_players_3d_pool : Array[AudioStreamPlayer3D] = []

func get_audio_stream_player() -> AudioStreamPlayer:
	var audio_stream_player : AudioStreamPlayer
	if _audio_stream_players_pool.is_empty():
		audio_stream_player = AudioStreamPlayer.new()
		audio_stream_player.finished.connect(self.free_audio_stream_player.bind(audio_stream_player))
	else:
		audio_stream_player = _audio_stream_players_pool.pop_back()
	add_child(audio_stream_player)
	return audio_stream_player

func free_audio_stream_player(audio_stream_player : AudioStreamPlayer):
	audio_stream_player.get_parent().remove_child(audio_stream_player)
	_audio_stream_players_pool.append(audio_stream_player)

func get_audio_stream_player_2d(node : Node2D) -> AudioStreamPlayer2D:
	var audio_stream_player : AudioStreamPlayer2D
	if _audio_stream_players_2d_pool.is_empty():
		audio_stream_player = AudioStreamPlayer2D.new()
		audio_stream_player.finished.connect(self.free_audio_stream_player_2d.bind(audio_stream_player))
	else:
		audio_stream_player = _audio_stream_players_2d_pool.pop_back()
	node.add_child(audio_stream_player)
	return audio_stream_player

func free_audio_stream_player_2d(audio_stream_player : AudioStreamPlayer2D):
	audio_stream_player.get_parent().remove_child(audio_stream_player)
	_audio_stream_players_2d_pool.append(audio_stream_player)

func get_audio_stream_player_3d(node : Node3D) -> AudioStreamPlayer3D:
	var audio_stream_player : AudioStreamPlayer3D
	if _audio_stream_players_3d_pool.is_empty():
		audio_stream_player = AudioStreamPlayer3D.new()
		audio_stream_player.finished.connect(self.free_audio_stream_player_3d.bind(audio_stream_player))
	else:
		audio_stream_player = _audio_stream_players_3d_pool.pop_back()
	node.add_child(audio_stream_player)
	return audio_stream_player

func free_audio_stream_player_3d(audio_stream_player : AudioStreamPlayer3D):
	audio_stream_player.get_parent().remove_child(audio_stream_player)
	_audio_stream_players_3d_pool.append(audio_stream_player)

var music_player : AudioStreamPlayer
var current_music : TRSound

func play_music(music_name : String, out_time : float = 0, in_time : float = 0):
	
	var music : TRSound
	if music_name == "":
		music = null
	else:
		music = get_sound(music_name)
	if music == current_music:
		return
	current_music = music	
	var tween : Tween
	if music_player:
		if out_time > 0:
			tween = get_tree().create_tween()
			tween.tween_property(music_player, "volume_db", -80.0, out_time)
			await tween.finished
	else:
		music_player = AudioStreamPlayer.new()
		add_child(music_player)
	if music:
		music.play_on_audio_stream_player(music_player)
		if in_time > 0:
			tween = get_tree().create_tween()
			music_player.volume_db = -80.0
			tween.tween_property(music_player, "volume_db", music.volume_db, in_time)
			await tween.finished
