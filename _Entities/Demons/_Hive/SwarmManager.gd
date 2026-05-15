extends Node2D

const DroneScene = preload("res://_Entities/Demons/_Hive/Drone.tscn")

var max_drones: int = 3
var available_drones: Array = []
var drone_assignments: Dictionary = {}
var enemy_queue: Array = []
var active_enemies: Array = []
var drone_rest_positions: Dictionary = {}
var drones_to_respawn: int = 0
var is_maw_buffed: bool = false
var drone_damage

@onready var hive: Node = get_parent()
@onready var respawn_timer: Timer = get_parent().get_node("DroneRespawnTimer")


func initialize(wait_time: float):
	respawn_timer.wait_time = wait_time
	spawn_initial_drones()


func get_available_drones() -> Array:
	return available_drones


func set_max_drones(new_max: int):
	max_drones = new_max


func set_maw_buffed(buffed: bool):
	is_maw_buffed = buffed


func set_respawn_wait_time(time: float):
	respawn_timer.wait_time = time


func kill_all_and_respawn():
	kill_all_drones()
	spawn_initial_drones()


func kill_all_drones():
	for enemy in drone_assignments.keys():
		for drone in drone_assignments[enemy]:
			if is_instance_valid(drone):
				drone.die()
	for drone in available_drones:
		if is_instance_valid(drone):
			drone.die()
	available_drones.clear()
	drone_assignments.clear()
	drone_rest_positions.clear()
	drones_to_respawn = 0


func get_total_drone_count() -> int:
	var count = available_drones.size()
	for drones in drone_assignments.values():
		count += drones.size()
	return count


func calculate_rest_position(index: int) -> Vector2:
	var angle = (2 * PI * index) / max_drones
	return Vector2(cos(angle), sin(angle)) * 10


func spawn_initial_drones():
	for i in range(max_drones):
		var drone = DroneScene.instantiate()
		drone.name = "Drone_%d" % i
		hive.get_parent().add_child(drone)
		if hive.is_in_group("Green"):
			drone.add_to_group("Green")
		else:
			drone.add_to_group("Purple")
		available_drones.append(drone)

		var rest_pos = calculate_rest_position(i)
		drone_rest_positions[drone] = rest_pos
		drone.global_position = hive.global_position + rest_pos
		drone.rest_position = rest_pos

		drone.connect("drone_died", Callable(self, "_on_drone_died"))
		if is_maw_buffed:
			drone.doubleDamage()


func _on_enemy_entered(area):
	if area.is_in_group("Zombie"):
		enemy_queue.append(area)
		active_enemies.append(area)
		area.connect("enemy_died", Callable(self, "_on_enemy_died"))
		optimize_drone_assignments()


func _on_enemy_exited(area):
	if area.is_in_group("Zombie"):
		enemy_queue.erase(area)
		active_enemies.erase(area)

		if area in drone_assignments:
			var freed_drones = drone_assignments[area]
			available_drones.append_array(freed_drones)
			drone_assignments.erase(area)

		for drone in available_drones:
			drone.setAnimation("idle")

		optimize_drone_assignments()

		if enemy_queue.is_empty():
			return_drones_to_rest()


func _on_enemy_died(enemy):
	_on_enemy_exited(enemy)


func return_drones_to_rest():
	for drone in available_drones:
		if is_instance_valid(drone):
			drone.return_to_position(hive.global_position + drone_rest_positions[drone])
			drone.setAnimation("idle")


func _on_drone_died(drone):
	available_drones.erase(drone)

	for enemy in drone_assignments.keys():
		if drone in drone_assignments[enemy]:
			drone_assignments[enemy].erase(drone)

	drone_rest_positions.erase(drone)

	drones_to_respawn += 1
	if respawn_timer.is_stopped():
		respawn_timer.start()


func optimize_drone_assignments():
	var all_drones = []
	for drones in drone_assignments.values():
		all_drones.append_array(drones)
	all_drones.append_array(available_drones)

	drone_assignments.clear()
	available_drones = all_drones

	if enemy_queue.is_empty():
		return_drones_to_rest()
		return

	var enemies_to_assign = enemy_queue.slice(0, min(enemy_queue.size(), max_drones))
	if enemies_to_assign.is_empty():
		return

	var drones_per_enemy = int(max_drones / enemies_to_assign.size())
	var extra_drones = max_drones % enemies_to_assign.size()

	var dimension_parent = hive.get_parent().get_parent()
	for enemy in enemies_to_assign:
		if enemy.get_parent().get_parent() != dimension_parent:
			continue
		var num_drones = drones_per_enemy
		if extra_drones > 0:
			num_drones += 1
			extra_drones -= 1
		drone_assignments[enemy] = []
		for _i in range(num_drones):
			if available_drones.is_empty():
				break
			var drone = available_drones.pop_front()
			drone_assignments[enemy].append(drone)
			command_drone_to_attack(drone, enemy)


func command_drone_to_attack(drone, enemy):
	if is_instance_valid(enemy) and not enemy.is_queued_for_deletion():
		drone.enable_hurtbox()
		drone.attack_target(enemy)

func set_damage(newDroneDamage):
	drone_damage = newDroneDamage
	
	
	
	
	
	
func _on_DroneRespawnTimer_timeout():
	if drones_to_respawn <= 0 or get_total_drone_count() >= max_drones:
		drones_to_respawn = 0
		return

	var new_drone = DroneScene.instantiate()
	new_drone.set_damage(drone_damage)
	hive.get_parent().add_child(new_drone)
	available_drones.append(new_drone)
	if hive.is_in_group("Green"):
		new_drone.add_to_group("Green")
	else:
		new_drone.add_to_group("Purple")

	var rest_pos = calculate_rest_position(available_drones.size() - 1)
	drone_rest_positions[new_drone] = rest_pos
	new_drone.global_position = hive.global_position + rest_pos
	new_drone.rest_position = rest_pos
	new_drone.connect("drone_died", Callable(self, "_on_drone_died"))

	if is_maw_buffed:
		new_drone.doubleDamage()

	drones_to_respawn -= 1
	if drones_to_respawn > 0 and get_total_drone_count() < max_drones:
		respawn_timer.start()

	optimize_drone_assignments()
