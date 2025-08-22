class_name TRAudioAnimationPlayer
extends AnimationPlayer


## An AnimationPlayer that can synchronize to music.

# Synchronization information for all animations
@export var animation_sync_info : Dictionary[String, TRAnimationSyncInfo]


func sync(animation_name : String, audio_stream_player) -> bool:
	if not "stream" in audio_stream_player:
		return false
	var bpm : float = audio_stream_player.stream.get_bpm()
	var offset : float = audio_stream_player.get_playback_position() + AudioServer.get_time_since_last_mix() - AudioServer.get_output_latency()
	if bpm == 0:
		return false
	var animation : Animation = get_animation(animation_name)
	var count : float = 1.0
	if not animation_name in animation_sync_info:
		return false
	count = animation_sync_info[animation_name].count
	var delay : float = (animation_sync_info[animation_name].offset*count/animation.length+60)/bpm-offset
	get_tree().create_timer(delay).timeout.connect(self.play.bind(animation_name, -1, animation.length*bpm/60.0/count))
	return true
