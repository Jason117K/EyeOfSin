extends Node2D
#ZombieSpawner

signal spawnNextWave 

# Path to the base zombie scene
var base_zombie_scene = preload("res://Scenes/ZombieScenes/BasicZombie.tscn")  
var cone_zombie_scene = preload("res://Scenes/ZombieScenes/ConeHeadZombie.tscn") 
var bucket_zombie_scene = preload("res://Scenes/ZombieScenes/BucketHeadZombie.tscn") 
var screendoor_zombie_scene = preload("res://Scenes/ZombieScenes/ScreenDoorZombie.tscn") 
var dancer_zombie_scene = preload("res://Scenes/ZombieScenes/DancerZombie.tscn") 
var poleVault_zombie_scene = preload("res://Scenes/ZombieScenes/PoleVaultZombie.tscn") 
var ticker_zombie_scene = preload("res://Scenes/ZombieScenes/TickerZombie.tscn") 
var football_zombie_scene = preload("res://Scenes/ZombieScenes/FootballZombie.tscn")

# Array to hold zombie types
var wave1_zombies = []  
var wave2_zombies = []  
var wave3_zombies = []  

#Arrays to track amount of zombies by types per round 
@export var Round1_Zombies = {"Base": 0, "ConeHead": 0, "BucketHead" : 0, 
							"ScreenDoor" : 0, "Dancer" : 0, "PoleVault" : 0,
							"Ticker" : 0, "Football" : 0}
							
@export var Round2_Zombies = {"Base": 0, "ConeHead": 0, "BucketHead" : 0, 
							"ScreenDoor" : 0, "Dancer" : 0, "PoleVault" : 0,
							"Ticker" : 0, "Football" : 0}
							
@export var Round3_Zombies =  {"Base": 0, "ConeHead": 0, "BucketHead" : 0, 
							"ScreenDoor" : 0, "Dancer" : 0, "PoleVault" : 0,
							"Ticker" : 0, "Football" : 0}

var baseZombies = []

signal doneSpawning


# The current wave we are on
var numWave = 0

#Slight random position adjustmnet 
var random_adjustment = randf_range(-1.0, 1.0)
var random_adjustment2 = randf_range(-0.6, 0.6)

#Adjustble delay between waves 
@export var waveDelay = 0.5

# Alternative: Manual weight ranges
@export_group("Weight Ranges")
@export var large_gap_min: float = 0.4
@export var large_gap_max: float = 0.9
@export var large_gap_weight: float = 80.0  # Percentage chance for large gap

@export var small_gap_min: float = 0.1
@export var small_gap_max: float = 0.39
@export var small_gap_weight: float = 20.0  # Percentage chance for small gap 

var waveManager

# Populates the apprioate arrays with current zombie counts by type 
func _ready():
	
	waveManager = get_parent().get_node("WaveManager")
	
	var wave_manager = get_parent().get_node("WaveManager")
	spawnNextWave.connect(wave_manager._on_spawn_next_wave)
	
	populate_zombies(Round1_Zombies.get("Base") , Round1_Zombies.get("ConeHead"), 
	Round1_Zombies.get("BucketHead") , Round1_Zombies.get("ScreenDoor"),
	Round1_Zombies.get("Dancer"),Round1_Zombies.get("PoleVault"),
	Round1_Zombies.get("Ticker"),Round1_Zombies.get("Football"),
	 wave1_zombies)
	
	populate_zombies(Round2_Zombies.get("Base") , Round2_Zombies.get("ConeHead"), 
	Round2_Zombies.get("BucketHead") , Round2_Zombies.get("ScreenDoor"), 
	Round2_Zombies.get("Dancer"),Round2_Zombies.get("PoleVault"),
	Round2_Zombies.get("Ticker"),Round1_Zombies.get("Football"),
	 wave2_zombies)
	
	populate_zombies(Round3_Zombies.get("Base") , Round3_Zombies.get("ConeHead"),
	Round3_Zombies.get("BucketHead") , Round3_Zombies.get("ScreenDoor"),
	Round3_Zombies.get("Dancer"), Round3_Zombies.get("PoleVault"),
	Round2_Zombies.get("Ticker"),Round1_Zombies.get("Football"),
	 wave3_zombies)

	$WaveDelay.wait_time = waveDelay


# Starts spawning the zombies with slight random timing adjustment 
func start_spawn_zombie():
	random_adjustment = randf_range(-0.5, 0.5)
	$WaveDelay.wait_time = waveDelay + random_adjustment
	$WaveDelay.start()
	print("Start SPawn Zombie Called")
	
#Spawns a different amount of zombies depending on the wave 
func spawn_zombie():
	
	#For each wave, shuffle the zombies, and then spawn them at the spawner positon 
	#TODO Add slight variation in spawn y axis 
	match numWave:
		1: 
			if(wave1_zombies.size() > 0):
				wave1_zombies.shuffle()

				var zombie_type = wave1_zombies.pop_front()
				var zombie_instance = zombie_type.instantiate()
				zombie_instance.name = generate_unique_name(zombie_instance.name)
				zombie_instance.position = self.position #Adjust position as needed
				get_parent().add_child(zombie_instance)  # Add to the GameLayer
				#$WaveDelay.start()
				print("Spawn Wave 1")
				random_adjustment2 = get_weighted_range_speed()
				$WaveInterval.wait_time = 10 #random_adjustment2
				$WaveInterval.start()
			else:
				pass
				#TODO Spawn Next Wave Here 
				spawnNextWave.emit()
				

		2:
			if(wave2_zombies.size() > 0):
				wave2_zombies.shuffle()
				var zombie_type = wave2_zombies.pop_front()
				var zombie_instance = zombie_type.instantiate()
				zombie_instance.position = self.position + Vector2(-30,0)  #Adjust position as needed
				get_parent().add_child(zombie_instance)  # Add to the GameLayer
				print("Spawn wave 2")
				random_adjustment2 = get_weighted_range_speed()
				$WaveInterval.wait_time = random_adjustment2
				$WaveInterval.start()
		

		3:
			if(wave3_zombies.size() > 0):
				wave3_zombies.shuffle()
				var zombie_type = wave3_zombies.pop_front()
				var zombie_instance = zombie_type.instantiate()
				zombie_instance.position = self.position + Vector2(-10,0) #Adjust position as needed
				get_parent().add_child(zombie_instance)  # Add to the GameLayer
				print("Spawn wave 3")
				random_adjustment2 = get_weighted_range_speed()
				$WaveInterval.wait_time = random_adjustment2
				$WaveInterval.start()
				$WaveInterval.start()
			else:
				doneSpawning.emit()
				

		_:
			print("Value is something else")
	
	
# Function to populate the zombies array based on numbers provided
func populate_zombies(base_zombie_count: int, conehead_zombie_count: int, 
					buckethead_zombie_count: int, screendoor_zombie_count: int, 
					dancer_zombie_count: int, poleVault_zombie_count: int,
					ticker_zombie_count: int,football_zombie_count : int,
					zombie_wave: Array):
						
						
	# Add base zombies to the array
	for _i in range(base_zombie_count):
		zombie_wave.append(base_zombie_scene)
	# Add conehead zombies to the array
	for _i in range(conehead_zombie_count):
		zombie_wave.append(cone_zombie_scene)
		# Add buckethead zombies to the array
	for _i in range(buckethead_zombie_count):
		zombie_wave.append(bucket_zombie_scene)
		#Add screen door 
	for _i in range(screendoor_zombie_count):
		zombie_wave.append(screendoor_zombie_scene)
		#Add Dancer
	for _i in range(dancer_zombie_count):
		zombie_wave.append(dancer_zombie_scene)
	# Add pole vault zombies
	for _i in range(poleVault_zombie_count):
		zombie_wave.append(poleVault_zombie_scene)
	# Add ticker zombies
	for _i in range(ticker_zombie_count):
		zombie_wave.append(ticker_zombie_scene)
	#Add football
	for _i in range(football_zombie_count):
		zombie_wave.append(football_zombie_scene)
	
#Increments the current wave 				
func increase_wave():
	numWave = numWave + 1

#TODO Trace Back 
#Starts the next round of zombie spawning 
func _on_WaveDelay_timeout():
	print("Zombie Spawning Starting Here")
	spawn_zombie()
	$WaveDelay.stop()

#TODO Trace Back 
func _on_wave_interval_timeout() -> void:
	print("About call spawn zombie ")
	spawn_zombie()


# Helper function to generate sequential names
func generate_unique_name(base_name: String) -> String:
	var used_numbers = []
	# Collect all existing numbers from siblings
	for child in get_parent().get_children():
		#print("PPChild is ", child.name)
		if child.name.begins_with(base_name):
			var suffix = child.name.substr(base_name.length())
			#print("PPSuffix Is ", suffix)
			if suffix.is_valid_int():
				used_numbers.append(suffix.to_int())
					
	used_numbers.sort()
	#print("Used PP Numbers is ",used_numbers )
	# Find first available number (fills gaps)
	var candidate = 1
	for num in used_numbers: 
		if candidate < num:
			break  # Gap found
		if candidate == num:
			candidate = num + 1
	#print("Will Return PP ", base_name + str(candidate))
	return base_name + str(candidate)


#Weighted ranges - explicitly define speed ranges with weights
func get_weighted_range_speed() -> float:
	var total_weight = large_gap_weight + small_gap_weight
	var random_weight = randf() * total_weight
	
	if random_weight <= large_gap_weight:
		# Pick from large gap weight range
		return randf_range(large_gap_min, large_gap_max)
	else:
		# Pick from small gap weight range 
		return randf_range(small_gap_min, small_gap_max)
