extends Node2D
class_name ZombieSpawner

signal wave_exhausted
signal all_waves_exhausted
signal show_preview_icon

## Each entry is a WaveData resource mapping zombie type name to count.
@export var waves: Array[WaveData] = []
@export var make_green: bool = false

@export_group("Spawn Timing")
@export var default_spawn_wait_time := 1
@export var large_gap_min: float = 0.9
@export var large_gap_max: float = 2.6
@export var large_gap_weight: float = 75.0
@export var small_gap_min: float = 0.1
@export var small_gap_max: float = 0.9
@export var small_gap_weight: float = 25.0

var _current_wave: int = -1
var _spawn_pool: Array[PackedScene] = []


func _ready() -> void:
	add_to_group("ZombieSpawners")
	$SpawnTimer.timeout.connect(_on_spawn_timer_timeout)

	

func get_preview_icon_panel()->Control:
	return get_child(1).get_preview_icon_panel()

func get_wave_count() -> int:
	return waves.size()


func get_current_wave() -> int:
	return _current_wave


func get_wave_config(index: int) -> Dictionary:
	if index >= 0 and index < waves.size():
		return waves[index].to_dict()
	return {}


func get_wave_preview() -> Node:
	return $WavePreview


## Set waves from an array of Dictionaries (for code-based configuration).
## e.g. set_waves_from_dicts([{"Reborn": 3, "Severed": 2}, {"Unhallower": 1}])
func set_waves_from_dicts(data: Array) -> void:
	waves = []
	for d:Dictionary in data:
		waves.append(WaveData.from_dict(d))
	if get_parent().get_parent().name.containsn("Level0-1"):
		pass
	else:
		return
		for child in get_children():
			if child is not Timer:
				child._on_Area2D_mouse_entered()

func begin_wave(wave_index: int) -> void:
	_current_wave = wave_index
	_spawn_pool = _build_pool(wave_index)
	_spawn_pool.shuffle()
	$SpawnTimer.wait_time = _get_weighted_spawn_delay()
	$SpawnTimer.start()


func _build_pool(wave_index: int) -> Array[PackedScene]:
	var pool: Array[PackedScene] = []
	if wave_index < 0 or wave_index >= waves.size():
		return pool
	var wave: WaveData = waves[wave_index]
	for type_name:String in ZombieRegistry.SCENES:
		var count: int = wave.get(type_name)
		if count <= 0:
			continue
		var scene: PackedScene = ZombieRegistry.SCENES[type_name]
		for _i in range(count):
			pool.append(scene)
	if get_parent().get_parent().name.containsn("Level0-1"):
		pass
	else:
		return pool
		for child in get_children():
			if child is not Timer:
				child._on_Area2D_mouse_entered()
	return pool

func emit_show_preview():
	show_preview_icon.emit()

func _spawn_next() -> void:
	if _spawn_pool.is_empty():
		if _current_wave >= waves.size() - 1:
			all_waves_exhausted.emit()
		else:
			wave_exhausted.emit()
		return

	var scene: PackedScene = _spawn_pool.pop_front()
	var zombie: Node2D = scene.instantiate()
	zombie.name = _generate_unique_name(zombie.name)

	var y_offset: float = ZombieRegistry.Y_OFFSETS.get(_get_type_key(zombie.name), 0.0)
	zombie.position = self.position + Vector2(25, y_offset)
	zombie.add_to_group("Zombie")
	

	if make_green:
		zombie.add_to_group("Green")
		get_parent().add_child(zombie)
		#zombie.collision_layer = 3
		zombie.set_hue_shift(125)
		#zombie._ready()
	else:
		zombie.add_to_group("Purple")
		get_parent().add_child(zombie)
		zombie.set_hue_shift(-86)
		
	
	if not _spawn_pool.is_empty():
		#$SpawnTimer.wait_time = _get_weighted_spawn_delay()
		$SpawnTimer.wait_time = default_spawn_wait_time + abs(_get_small_weighted_spawn_delay())
		$SpawnTimer.start()
	else:
		if _current_wave >= waves.size() - 1:
			all_waves_exhausted.emit()
		else:
			wave_exhausted.emit()


func _on_spawn_timer_timeout() -> void:
	_spawn_next()
	Global.start_wave_1()


func _get_type_key(zombie_name: String) -> String:
	for type_name : String in ZombieRegistry.Y_OFFSETS:
		if type_name in zombie_name:
			#print("Will Return ", zombie_name, " with type name ", type_name)
			return type_name
		else:
			pass
			#print(type_name ," was not right NAME")
	#print("Not Retunring NOTHING FOUND NO NAME FOR ", zombie_name)
	return ""


func _get_weighted_spawn_delay() -> float:
	var total_weight := large_gap_weight + small_gap_weight
	var roll := randf() * total_weight
	if roll <= large_gap_weight:
		return randf_range(large_gap_min, large_gap_max)
	else:
		return randf_range(small_gap_min, small_gap_max)
		
func _get_small_weighted_spawn_delay() -> float:
	return randf_range(small_gap_min, small_gap_max)

func _generate_unique_name(base_name: String) -> String:
	var used_numbers: Array[int] = []
	for child in get_parent().get_children():
		if child.name.begins_with(base_name):
			var suffix := child.name.substr(base_name.length())
			if suffix.is_valid_int():
				used_numbers.append(suffix.to_int())
	used_numbers.sort()
	var candidate := 1
	for num in used_numbers:
		if candidate < num:
			break
		if candidate == num:
			candidate = num + 1
	return base_name + str(candidate)
