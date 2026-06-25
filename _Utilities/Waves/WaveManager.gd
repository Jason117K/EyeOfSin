
class_name WaveManager extends Node2D

signal wave_started(wave_index: int)
signal all_waves_complete
signal level_ended

## Delay before wave i+1 starts after wave i begins.
## Length determines total wave count: total_waves = wave_delays.size() + 1.
## A value <= 0 means that wave requires manual start via start_next_wave().
@export var wave_delays: Array = []

## Seconds before a wave starts that the preview icon appears.
@export var preview_lead_time: float = 20.0

## Player health — will be extracted to a separate node later.
@export var health_points: int = 9999

@onready var waveDelayTimer := $WaveDelayTimer
@onready var previewTimer := $PreviewTimer
@onready var take_damage_area := $Area2D
@onready var danger_zone_area := $DangerZone

var can_start: bool = true

var _spawners: Array = []
var _wave_previews: Array = [Node]
var _current_wave: int = -1
var _total_waves: int = 0
@onready var _spawners_finished: int = 0
var _all_spawning_done: bool = false

var zombie_close : bool = false 

var elapsed_time_preview_on_screen : float

func _ready() -> void:
	Global.register_wave_manager(self)
	call_deferred("_setup")


func _setup() -> void:
	waveDelayTimer.stop()
	previewTimer.stop()
	_spawners_finished = 0
	_all_spawning_done = false
	
	_current_wave = -1
	_total_waves = wave_delays.size() + 1

	_spawners = get_tree().get_nodes_in_group("ZombieSpawners")
	

	_wave_previews = []
	for spawner:Node in _spawners:
		var preview : Node = spawner.get_wave_preview()
		if preview != null:
			_wave_previews.append(preview)
			preview.game_start_requested.connect(_on_game_start_requested)
			preview.call_wave_early_requested.connect(_on_call_early_wave_requested)
			preview.set_preview_lead_time(preview_lead_time)
			preview.set_green()

		spawner.all_waves_exhausted.connect(_on_spawner_all_waves_exhausted)
		
	if not take_damage_area.area_entered.is_connected(_on_damage_area_entered):
		take_damage_area.connect("area_entered", _on_damage_area_entered)
		
	if not danger_zone_area.area_entered.is_connected(_on_danger_zone_area_entered):
		danger_zone_area.connect("area_entered", _on_danger_zone_area_entered)
		
	# Show wave 0 preview with start button so the player can begin
	for preview:Node in _wave_previews:
		pass
		preview.show_preview(0, true)
	if not waveDelayTimer.timeout.is_connected(_on_wave_delay_timer_timeout):
		waveDelayTimer.timeout.connect(_on_wave_delay_timer_timeout)
	if not previewTimer.timeout.is_connected(_on_preview_timer_timeout):
		previewTimer.timeout.connect(_on_preview_timer_timeout)

	#var purple = get_tree().get_first_node_in_group("Purple")
	#var green = get_tree().get_first_node_in_group("Green")
	#if purple and purple.has_method("get_health_ui"):
		#purple.get_health_ui().text = str(health_points)
	#if green and green.has_method("get_health_ui"):
		#green.get_health_ui().text = str(health_points)
	


func get_wave_count() -> int:
	return _total_waves


func get_current_wave() -> int:
	return _current_wave


## Called when the player clicks the Start button (gated by can_start).
func _on_game_start_requested() -> void:
	#print("START REEEEEEE")
	if not can_start:
		#print("CANNOT START")
		return
	_start_wave(0)

func _on_call_early_wave_requested() -> void:
	ScoreManager.wave_called_early()
	#print("Requested Early Wave, current wave is ",_current_wave )
	#_start_wave(_current_wave + 1)
	if (_current_wave + 1) < wave_delays.size():
		wave_delays[_current_wave + 1] = wave_delays[_current_wave + 1] \
										- (waveDelayTimer.time_left)
	_start_wave(_current_wave + 1)
	Global.add_blood_from_wave(25)
	#_start_wave(_current_wave + 1)


## Manually start the next wave (for tutorial-controlled progression).
func start_next_wave() -> void:
	#print("Manual Call Start Next Wave")
	_start_wave(_current_wave + 1)



func _start_wave(index: int) -> void:
	print("START WAVEEEEEEEEE ", index)
	if index < 0 or index >= _total_waves:
		return
	Global.add_blood_from_wave(25)
	_current_wave = index

	# Hide previews for the wave that's now starting
	for preview:Node in _wave_previews:
		preview.hide_preview()

	# Tell every spawner to begin this wave
	for spawner:Node in _spawners:
		if index < spawner.get_wave_count():
			spawner.begin_wave(index)
	
	wave_started.emit(index)

	# Schedule next wave (if not the last and delay is positive)
	if index < wave_delays.size():
		print("Index Is ",index, " & wave_delays.size() is ",wave_delays.size() )
		var delay: float = wave_delays[index]
		if delay > 0:
			#print("Wave Delay Timer At Index ", index, " has a wait time of ", delay)
			waveDelayTimer.wait_time = delay
			waveDelayTimer.start()

			# Schedule preview to appear before next wave
			var preview_time := delay - preview_lead_time
			if preview_time > 0:
				$PreviewTimer.wait_time = preview_time
				$PreviewTimer.start()
			else:
				# Lead time exceeds delay — show preview immediately
				_show_preview_for_next_wave()


func _on_wave_delay_timer_timeout() -> void:
	#print("Start Da Wave Here")
	_start_wave(_current_wave + 1)


func _on_preview_timer_timeout() -> void:
	_show_preview_for_next_wave()


func _show_preview_for_next_wave() -> void:
	var next := _current_wave + 1
	if next < _total_waves:
		#print("Wave Previews Is ", _wave_previews)
		for preview : Node in _wave_previews:
			pass
			preview.show_preview(next,true)
			if Global.game_controller.on_purple_scene():
				if preview.is_green:
					preview.hide()
			else:
				if preview.is_green:
					preview.show()


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
		print("Emitting Level End Cos No Enmeies In Group")
		level_ended.emit()
	else:
		get_tree().create_timer(1.0).timeout.connect(_check_level_end)


		
	

# --- Player Health (temporary — extract to PlayerHealth node later) ---
func _on_danger_zone_area_entered(area: Area2D)->void:
	if area.is_in_group("Zombie"):
		Global.make_pip_glow()
		
func _on_damage_area_entered(area: Area2D) -> void:
	if area.is_in_group("Zombie"):
		if area.has_method("true_death"):
			area.true_death()
		else:
			area.die()
		subtract_health()


func subtract_health() -> void:
	ScoreManager.set_lives_lost()
	health_points -= 1
	var purple : Node = get_tree().get_first_node_in_group("Purple")
	var green : Node = get_tree().get_first_node_in_group("Green")
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


func _on_check_danger_zone_timer_timeout() -> void:
	zombie_close = false 
	for area : Area2D in danger_zone_area.get_overlapping_areas():
		if area.is_in_group("Zombie"):
			if area.is_in_group("Purple") && !Global.is_on_purple_scene():
				zombie_close = true 
				Global.make_pip_glow()
			if area.is_in_group("Green") && Global.is_on_purple_scene():
				zombie_close = true 
				Global.make_pip_glow()
	if zombie_close == false :
		Global.stop_pip_glow()
