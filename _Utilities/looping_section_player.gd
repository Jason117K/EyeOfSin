class_name LoopingSectionPlayer extends AudioStreamPlayer

var _loop_start : float = 0.0
var _loop_end : float = 0.0
var _looping : bool = false

var fade : float = 0.0:
	set(value):
		fade = value
		_apply_volume()

var gain : float = 1.0:
	set(value):
		gain = value
		_apply_volume()


func _process(_delta: float) -> void:
	if not _looping or not playing:
		return

	# Add the time since the last audio mix for a more accurate position.
	var pos := get_playback_position() + AudioServer.get_time_since_last_mix()

	if pos >= _loop_end:
		# Carry the overshoot into the jump so the loop stays in time.
		var overshoot := pos - _loop_end
		seek(_loop_start + overshoot)


func play_section(start: float, end: float) -> void:
	_loop_start = start
	_loop_end = end
	_looping = true
	play(start)


func is_playing_section(start: float, end: float) -> bool:
	return _looping and playing and _loop_start == start and _loop_end == end


func stop_section() -> void:
	_looping = false
	stop()


func _apply_volume() -> void:
	volume_linear = fade * gain
