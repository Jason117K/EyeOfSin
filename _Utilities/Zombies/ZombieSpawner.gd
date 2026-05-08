extends Node2D
class_name ZombieSpawner

signal wave_exhausted
signal all_waves_exhausted

## Each entry is a Dictionary mapping zombie type name to count.
## e.g. [{"Reborn": 3, "Severed": 2}, {"Unhallower": 1, "Reborn": 5}]
@export var waves: Array[Dictionary] = []
@export var make_green: bool = false

@export_group("Spawn Timing")
@export var large_gap_min: float = 0.8
@export var large_gap_max: float = 1.9
@export var large_gap_weight: float = 80.0
@export var small_gap_min: float = 0.3
@export var small_gap_max: float = 0.65
@export var small_gap_weight: float = 20.0

var _current_wave: int = -1
var _spawn_pool: Array[PackedScene] = []


func _ready():
	add_to_group("ZombieSpawners")
	$SpawnTimer.timeout.connect(_on_spawn_timer_timeout)


func get_wave_count() -> int:
	return waves.size()


func get_current_wave() -> int:
	return _current_wave


func get_wave_config(index: int) -> Dictionary:
	if index >= 0 and index < waves.size():
		return waves[index]
	return {}


func get_wave_preview() -> Node:
	return $WavePreview


func begin_wave(wave_index: int) -> void:
	_current_wave = wave_index
	_spawn_pool = _build_pool(wave_index)
	_spawn_pool.shuffle()
	$SpawnTimer.wait_time = randf_range(0.1, 0.5)
	$SpawnTimer.start()


func _build_pool(wave_index: int) -> Array[PackedScene]:
	var pool: Array[PackedScene] = []
	var config := get_wave_config(wave_index)
	for type_name in config:
		var count: int = config[type_name]
		if count <= 0:
			continue
		var scene: PackedScene = ZombieRegistry.SCENES.get(type_name)
		if scene == null:
			push_warning("ZombieSpawner: unknown zombie type '%s'" % type_name)
			continue
		for _i in range(count):
			pool.append(scene)
	return pool


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

	get_parent().add_child(zombie)

	if make_green:
		zombie.add_to_group("Green")
		zombie.collision_layer = 3
		zombie.set_hue_shift(125)
		zombie._ready()
	else:
		zombie.add_to_group("Purple")
		zombie.set_hue_shift(-86)

	if not _spawn_pool.is_empty():
		$SpawnTimer.wait_time = _get_weighted_spawn_delay()
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
	for type_name in ZombieRegistry.Y_OFFSETS:
		if type_name in zombie_name:
			return type_name
	return ""


func _get_weighted_spawn_delay() -> float:
	var total_weight := large_gap_weight + small_gap_weight
	var roll := randf() * total_weight
	if roll <= large_gap_weight:
		return randf_range(large_gap_min, large_gap_max)
	else:
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
