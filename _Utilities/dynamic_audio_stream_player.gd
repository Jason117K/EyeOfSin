extends AudioStreamPlayer

@export var calm_1_start : float = 0.0
@export var calm_1_end : float = 40.0
@export var calm_2_start : float = 114.0
@export var calm_2_end : float = 131.0

@export var intense_1_start : float = 40.0
@export var intense_1_end : float = 114.0
@export var intense_2_start : float = 131.0
@export var intense_2_end : float = 202.0

var _loop_start : float = 0.0
var _loop_end : float = 0.0
var _looping : bool = false


func _process(_delta: float) -> void:
	if not _looping or not playing:
		return

	# Add the time since the last audio mix for a more accurate position.
	var pos := get_playback_position() + AudioServer.get_time_since_last_mix()

	if pos >= _loop_end:
		# Carry the overshoot into the jump so the loop stays in time.
		var overshoot := pos - _loop_end
		seek(_loop_start + overshoot)


func _play_section(start: float, end: float) -> void:
	# Do nothing if this section is already the one playing.
	if _looping and playing and _loop_start == start and _loop_end == end:
		return
	_loop_start = start
	_loop_end = end
	_looping = true
	play(start)



func stop_music() -> void:
	_looping = false
	stop()


func play_calm_1() -> void:
	_play_section(calm_1_start, calm_1_end)

func play_calm_2() -> void:
	_play_section(calm_2_start, calm_2_end)

func play_intense_1() -> void:
	_play_section(intense_1_start, intense_1_end)

func play_intense_2() -> void:
	_play_section(intense_2_start, intense_2_end)
