extends Node2D
class_name WaveManager

signal wave_started(wave_index: int)
signal all_waves_complete
signal level_ended

## Delay before wave i+1 starts after wave i begins.
## Length determines total wave count: total_waves = wave_delays.size() + 1.
## A value <= 0 means that wave requires manual start via start_next_wave().
@export var wave_delays: Array = []

## Seconds before a wave starts that the preview icon appears.
@export var preview_lead_time: float = 10.0

## Player health — will be extracted to a separate node later.
@export var health_points: int = 10

var can_start: bool = false

var _spawners: Array = []
var _wave_previews: Array = []
var _current_wave: int = -1
var _total_waves: int = 0
var _spawners_finished: int = 0
var _all_spawning_done: bool = false


func _ready():
	call_deferred("_setup")


func _setup():
	_total_waves = wave_delays.size() + 1

	_spawners = get_tree().get_nodes_in_group("ZombieSpawners")

	_wave_previews = []
	for spawner in _spawners:
		var preview = spawner.get_wave_preview()
		if preview != null:
			_wave_previews.append(preview)
			preview.game_start_requested.connect(_on_game_start_requested)

		spawner.all_waves_exhausted.connect(_on_spawner_all_waves_exhausted)

	$Area2D.connect("area_entered", _on_damage_area_entered)

	# Show wave 0 preview with start button so the player can begin
	for preview in _wave_previews:
		preview.show_preview(0, true)


func get_wave_count() -> int:
	return _total_waves


func get_current_wave() -> int:
	return _current_wave


## Called when the player clicks the Start button (gated by can_start).
func _on_game_start_requested() -> void:
	if not can_start:
		return
	_start_wave(0)


## Manually start the next wave (for tutorial-controlled progression).
func start_next_wave() -> void:
	_start_wave(_current_wave + 1)


## Show the preview for the next upcoming wave without starting it.
func show_next_preview() -> void:
	var next := _current_wave + 1
	if next < _total_waves:
		for preview in _wave_previews:
			preview.show_preview(next)


func _start_wave(index: int) -> void:
	if index < 0 or index >= _total_waves:
		return

	_current_wave = index

	# Hide previews for the wave that's now starting
	for preview in _wave_previews:
		preview.hide_preview()

	# Tell every spawner to begin this wave
	for spawner in _spawners:
		if index < spawner.get_wave_count():
			spawner.begin_wave(index)

	wave_started.emit(index)

	# Schedule next wave (if not the last and delay is positive)
	if index < wave_delays.size():
		var delay: float = wave_delays[index]
		if delay > 0:
			$WaveDelayTimer.wait_time = delay
			$WaveDelayTimer.start()

			# Schedule preview to appear before next wave
			var preview_time := delay - preview_lead_time
			if preview_time > 0:
				$PreviewTimer.wait_time = preview_time
				$PreviewTimer.start()
			else:
				# Lead time exceeds delay — show preview immediately
				_show_preview_for_next_wave()


func _on_wave_delay_timer_timeout() -> void:
	_start_wave(_current_wave + 1)


func _on_preview_timer_timeout() -> void:
	_show_preview_for_next_wave()


func _show_preview_for_next_wave() -> void:
	var next := _current_wave + 1
	if next < _total_waves:
		for preview in _wave_previews:
			preview.show_preview(next)


func _on_spawner_all_waves_exhausted() -> void:
	_spawners_finished += 1
	if _spawners_finished >= _spawners.size():
		_all_spawning_done = true
		all_waves_complete.emit()
		_check_level_end()


func _check_level_end() -> void:
	if not _all_spawning_done:
		return
	if get_tree().get_nodes_in_group("Alive-Enemies").size() == 0:
		level_ended.emit()
	else:
		get_tree().create_timer(1.0).timeout.connect(_check_level_end)


# --- Player Health (temporary — extract to PlayerHealth node later) ---

func _on_damage_area_entered(area: Area2D) -> void:
	if area.is_in_group("Zombie"):
		area.die()
		subtract_health()


func subtract_health() -> void:
	health_points -= 1
	var purple = get_tree().get_first_node_in_group("Purple")
	var green = get_tree().get_first_node_in_group("Green")
	if purple and purple.has_method("get_health_ui"):
		purple.get_health_ui().text = str(health_points)
	if green and green.has_method("get_health_ui"):
		green.get_health_ui().text = str(health_points)
	if health_points <= 0:
		_lose()


func _lose() -> void:
	for child in get_parent().get_children():
		if "LevelSwitcher" in child.name:
			child.lose()
			child.visible = true
	get_tree().paused = true
