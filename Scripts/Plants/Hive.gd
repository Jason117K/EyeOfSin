extends Area2D
#Hive.gd

# Hive Plant Script

#Export variables
@export var cost = 25
@export var health = 50

# Preload the drone scene
const DroneScene = preload("res://Scenes/PlantScenes/Drone.tscn")

# Constants
var MAX_DRONES = 3
var BUFF_MAX_DRONES = 4
#const MAX_DRONES = 3

# Drone management
var available_drones = []                          # Currently active but unassigned drones
var drone_assignments = {}                         # Dictionary mapping enemies to arrays of drones
var enemy_queue = []                               # Enemies in order of entry
var active_enemies = []                            # All enemies currently in range
var drone_rest_positions = {}                      # Dictionary to store rest positions for each drone

@onready var droneRespawnTimer = $DroneRespawnTimer # Respawn Timer 
var isBuffed = false                               # Tracks Current Buff State Of Drone  
var PlantManager                                   # RefCounted to PlantManager 


@onready var animSpriteComp = $AnimatedSpriteComp
 
func _ready():
	# Initialize drones & Plant Manager 
	spawn_initial_drones()
	PlantManager = get_parent().get_parent().get_node("PlantManager")
	animSpriteComp.animation = "spawn"
	
#Getter for plant cost 
func get_cost():
	return cost
	
#Handles receiving EggWorm & Peashooter Buffs, can only receive one at a time
func receiveBuff(bufferName):
	#Apply a double damage buff to every drone 
	if(bufferName.name == "EggWorm" && isBuffed == false):
		for drone in available_drones:
			drone.doubleDamage()
		isBuffed = true 
	#Make the drones explode if it's a peashooter buff 
	if(bufferName.name == "Peashooter" && isBuffed == false):
		for drone in available_drones:
			drone.makeExplode()
		isBuffed = true 

#Kill every drone if the Hive falls 
func kill_all_drones():
	# Kill all assigned drones
	for enemy in drone_assignments.keys():
		for drone in drone_assignments[enemy]:
			if is_instance_valid(drone):
				drone.die()
	
	# Kill all available drones
	for drone in available_drones:
		if is_instance_valid(drone):
			drone.die()
			
	# Clear all drone tracking
	available_drones.clear()
	drone_assignments.clear()
	drone_rest_positions.clear()
		
		
	
# Calculate evenly spaced resting positons for all drones 
func calculate_rest_position(index):
	var angle = (2 * PI * index) / MAX_DRONES
	return Vector2(cos(angle), sin(angle)) * 30

# Spawns an assembles the initial number of drones 	
func spawn_initial_drones():
	for i in range(MAX_DRONES):
		var drone = DroneScene.instantiate()
		add_child(drone)
		available_drones.append(drone)
		
		# Calculate and store rest position
		var rest_pos = calculate_rest_position(i)
		drone_rest_positions[drone] = rest_pos
		
		# Set initial position
		drone.position = rest_pos
		
		# Connect drone signals
		drone.connect("drone_died", Callable(self, "_on_drone_died"))
		if isBuffed:
			drone.doubleDamage()

#Assigns drones to enemies if able & then re-optimizes drone assignments 
func _on_enemy_entered(area):
	if area.is_in_group("Zombie"):
		#print("Hive Reporting," ,area.name, " entered.")
		# Add to tracking arrays
		enemy_queue.append(area)
		active_enemies.append(area)
		
		# Connect to enemy death signal
		area.connect("enemy_died", Callable(self, "_on_enemy_died"))
		
		# Optimize drone assignments
		optimize_drone_assignments()

#Handles redoing drone assignments when enemies leave or die 
func _on_enemy_exited(area):
	if area.is_in_group("Zombie"):
		# Remove from tracking
		enemy_queue.erase(area)
		active_enemies.erase(area)
		
		# Free up assigned drones
		if area in drone_assignments:
			var freed_drones = drone_assignments[area]
			available_drones.append_array(freed_drones)
			drone_assignments.erase(area)
		
		for drone in available_drones:
			drone.setAnimation("idle")
		
		# Optimize assignments with freed drones
		optimize_drone_assignments()
		
		# If no enemies remain, return drones to rest positions
		if enemy_queue.is_empty():
			return_drones_to_rest()

# Helper func to reassemble drones in resting position 
func return_drones_to_rest():
	for drone in available_drones:
		if is_instance_valid(drone):
			drone.return_to_position(drone_rest_positions[drone])
			drone.setAnimation("idle")

func _on_enemy_died(enemy):
	_on_enemy_exited(enemy)  # Reuse exit logic

#Handle assignment clean-up on drone death 
func _on_drone_died(drone):
	# Remove drone from assignments
	for enemy in drone_assignments.keys():
		if drone in drone_assignments[enemy]:
			drone_assignments[enemy].erase(drone)
	
	# Remove rest position
	drone_rest_positions.erase(drone)
	
	#Start Respawn Timer 
	droneRespawnTimer.start()

#Assigns the optimal number of drones based on availablity and enemy presence 
func optimize_drone_assignments():
	# Reset all drone assignments
	var all_drones = []
	for drones in drone_assignments.values():
		all_drones.append_array(drones)
	all_drones.append_array(available_drones)
	
	drone_assignments.clear()
	available_drones = all_drones
	
	# If no enemies, return all drones to rest positions
	if enemy_queue.is_empty():
		return_drones_to_rest()
		return
		
	# Calculate optimal distribution
	var enemies_to_assign = enemy_queue.slice(0, min(enemy_queue.size() - 1, MAX_DRONES - 1))
	if enemies_to_assign.is_empty():
		return
		
	var drones_per_enemy = int(MAX_DRONES / enemies_to_assign.size())
	var extra_drones = MAX_DRONES % enemies_to_assign.size()
	
	# Assign drones based on calculated distribution
	for enemy in enemies_to_assign:
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

#Tell a drone to attack a target
func command_drone_to_attack(drone, enemy):
	if is_instance_valid_and_alive(enemy):
		drone.attack_target(enemy)

#Handles the Hive taking damage 
func take_damage(damage):
	health = health - damage
	if(health <= 0):
		PlantManager.clear_space(self.global_position)
		queue_free()

#Respawns a drone and re-optimizes assignmnets 
func _on_DroneRespawnTimer_timeout():
	# Create new drone
	var new_drone = DroneScene.instantiate()
	add_child(new_drone)
	available_drones.append(new_drone)
	
	# Calculate and store rest position for new drone
	var rest_pos = calculate_rest_position(available_drones.size() - 1)
	
	drone_rest_positions[new_drone] = rest_pos
	new_drone.position = rest_pos
	
	new_drone.connect("drone_died", Callable(self, "_on_drone_died"))
	
	if isBuffed:
		new_drone.doubleDamage()
	
	# Optimize assignments with new drone
	optimize_drone_assignments()

# Add this helper function to scripts that deal with combat
func is_instance_valid_and_alive(node) -> bool:
	return is_instance_valid(node) and not node.is_queued_for_deletion()



# Stops Spawn Animation From Playing
func _on_AnimatedSpriteComp_animation_finished():
	if animSpriteComp.animation == "spawn":
		animSpriteComp.animation = "idle"
		animSpriteComp.play()
