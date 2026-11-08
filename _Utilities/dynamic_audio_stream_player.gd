# This node never plays itself: its stream, bus and volume_db configure the two voices it crossfades between.
class_name DynamicAudioStreamPlayer extends AudioStreamPlayer

@export var calm_1_start : float = 0.0
@export var calm_1_end : float = 40.0
@export var intense_1_start : float = 40.0
@export var intense_1_end : float = 114.0
@export var calm_2_start : float = 114.0
@export var calm_2_end : float = 131.0
@export var intense_2_start : float = 131.0
@export var intense_2_end : float = 202.0

@export var crossfade_duration : float = 1.5

@export_range(0.0, 100.0, 1.0, "suffix:%") var pause_volume_reduction_percent : float = 50.0
@export var pause_fade_duration : float = 0.25

var _active_voice : LoopingSectionPlayer
var _idle_voice : LoopingSectionPlayer
var _crossfade : Tween
var _is_paused_volume : bool = false
var _pause_fade : Tween


func _ready() -> void:
	self.bus = "music"
	_is_paused_volume = get_tree().paused
	_active_voice = _create_voice()
	_idle_voice = _create_voice()


func _process(_delta: float) -> void:
	if get_tree().paused != _is_paused_volume:
		_is_paused_volume = get_tree().paused
		_fade_gain_to(_target_gain())


func _create_voice() -> LoopingSectionPlayer:
	var voice := LoopingSectionPlayer.new()
	voice.stream = stream
	voice.bus = bus
	voice.fade = 0.0
	voice.gain = _target_gain()
	add_child(voice)
	return voice


func _target_gain() -> float:
	var level_gain := db_to_linear(volume_db)
	if _is_paused_volume:
		return level_gain * (1.0 - pause_volume_reduction_percent / 100.0)
	return level_gain


func _fade_gain_to(target_gain: float) -> void:
	if _pause_fade:
		_pause_fade.kill()
	_pause_fade = create_tween().set_parallel().set_trans(Tween.TRANS_SINE)
	for voice: LoopingSectionPlayer in [_active_voice, _idle_voice]:
		_pause_fade.tween_property(voice, "gain", target_gain, pause_fade_duration)


func _play_section(start: float, end: float) -> void:
	if _active_voice.is_playing_section(start, end):
		return
	# Mid-fade, the section may still be playing on the outgoing voice: fade it back
	# up from where it is instead of restarting it.
	if not _idle_voice.is_playing_section(start, end):
		_idle_voice.fade = 0.0
		_idle_voice.play_section(start, end)
	var outgoing := _active_voice
	_active_voice = _idle_voice
	_idle_voice = outgoing
	_fade_between(outgoing, _active_voice)


func _fade_between(outgoing: LoopingSectionPlayer, incoming: LoopingSectionPlayer) -> void:
	if _crossfade:
		_crossfade.kill()
	_crossfade = create_tween().set_parallel().set_trans(Tween.TRANS_SINE)
	_crossfade.tween_property(incoming, "fade", 1.0, crossfade_duration)
	_crossfade.tween_property(outgoing, "fade", 0.0, crossfade_duration)
	_crossfade.chain().tween_callback(outgoing.stop_section)


func stop_music() -> void:
	if _crossfade:
		_crossfade.kill()
	_active_voice.stop_section()
	_idle_voice.stop_section()


func play_calm_1() -> void:
	_play_section(calm_1_start, calm_1_end)

func play_calm_2() -> void:
	if _section_exists(calm_2_start, calm_2_end):
		_play_section(calm_2_start, calm_2_end)
	else:
		play_calm_1()

func play_intense_1() -> void:
	_play_section(intense_1_start, intense_1_end)

func play_intense_2() -> void:
	if _section_exists(intense_2_start, intense_2_end):
		_play_section(intense_2_start, intense_2_end)
	else:
		play_intense_1()

func _section_exists(start: float, end: float) -> bool:
	return not is_zero_approx(start) and not is_zero_approx(end)
