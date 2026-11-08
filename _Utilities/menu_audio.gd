class_name MenuAudio extends AudioStreamPlayer
## Plays whenever no level is loaded. GameController calls stop_for_level() and
## play_menu_music() from its level transitions.

## Entry N plays in Act N+1's menus. An empty or missing entry plays the default stream.
@export var act_music: Array[AudioStream] = []
@export var fade_in_duration := 1.0
@export var fade_out_duration := 0.5

var _default_stream: AudioStream
var _full_volume: float
var _fade: Tween
var _is_fading_out := false


func _ready() -> void:
	_default_stream = stream
	_full_volume = volume_linear
	play_menu_music()


func play_menu_music() -> void:
	var track := _track_for_act(Progress.menu_music_act())
	if playing and stream == track and not _is_fading_out:
		return
	_restart_fade(false)
	stream = track
	volume_linear = 0.0
	play()
	_fade.tween_property(self, "volume_linear", _full_volume, fade_in_duration)


func stop_for_level() -> void:
	if not playing or _is_fading_out:
		return
	_restart_fade(true)
	_fade.tween_property(self, "volume_linear", 0.0, fade_out_duration)
	_fade.tween_callback(stop)


func _restart_fade(fading_out: bool) -> void:
	if _fade:
		_fade.kill()
	_is_fading_out = fading_out
	_fade = create_tween()


func _track_for_act(act: int) -> AudioStream:
	var index := act - 1
	if index >= 0 and index < act_music.size() and act_music[index] != null:
		return act_music[index]
	return _default_stream
