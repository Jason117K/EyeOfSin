extends Node2D
#ZombieSpawner

# Path to the base zombie scene
var base_zombie_scene = preload("res://Scenes/ZombieScenes/BasicZombie.tscn")  
var cone_zombie_scene = preload("res://Scenes/ZombieScenes/ConeHeadZombie.tscn") 
var bucket_zombie_scene = preload("res://Scenes/ZombieScenes/BucketHeadZombie.tscn") 
var screendoor_zombie_scene = preload("res://Scenes/ZombieScenes/ScreenDoorZombie.tscn") 
var dancer_zombie_scene = preload("res://Scenes/ZombieScenes/DancerZombie.tscn") 
var poleVault_zombie_scene = preload("res://Scenes/ZombieScenes/PoleVaultZombie.tscn") 
var ticker_zombie_scene = preload("res://Scenes/ZombieScenes/TickerZombie.tscn") 

# Array to hold zombie types
var wave1_zombies = []  
var wave2_zombies = []  
var wave3_zombies = []  

export var Round1_Zombies = {"Base": 1, "ConeHead": 1, "BucketHead" : 1, 
							"ScreenDoor" : 1, "Dancer" : 1, "PoleVault" : 1,
							"Ticker" : 1}
							
export var Round2_Zombies = {"Base": 1, "ConeHead": 1, "BucketHead" : 1, 
							"ScreenDoor" : 1, "Dancer" : 1, "PoleVault" : 1,
							"Ticker" : 1}
							
export var Round3_Zombies = {"Base": 1, "ConeHead": 1, "BucketHead" : 1, 
							"ScreenDoor" : 1, "Dancer" : 1, "PoleVault" : 1,
							"Ticker" : 1}

var baseZombies = []


# The current wave we are on
var numWave = 0

var random_adjustment = rand_range(-1.0, 1.0)
export var waveDelay = 0.5

#Onready var???
var baseZombieLabel 
var coneZombieLabel 
var bucketZombieLabel 

func _ready():
	
	populate_zombies(Round1_Zombies.get("Base") , Round1_Zombies.get("ConeHead"), 
	Round1_Zombies.get("BucketHead") , Round1_Zombies.get("ScreenDoor"),
	Round1_Zombies.get("Dancer"),Round1_Zombies.get("PoleVault"),
	Round1_Zombies.get("Ticker"),
	 wave1_zombies)
	
	populate_zombies(Round2_Zombies.get("Base") , Round2_Zombies.get("ConeHead"), 
	Round2_Zombies.get("BucketHead") , Round2_Zombies.get("ScreenDoor"), 
	Round2_Zombies.get("Dancer"),Round2_Zombies.get("PoleVault"),
	Round2_Zombies.get("Ticker"),
	 wave2_zombies)
	
	populate_zombies(Round3_Zombies.get("Base") , Round3_Zombies.get("ConeHead"),
	Round3_Zombies.get("BucketHead") , Round3_Zombies.get("ScreenDoor"),
	Round3_Zombies.get("Dancer"), Round3_Zombies.get("PoleVault"),
	Round2_Zombies.get("Ticker"),
	 wave3_zombies)

	$WaveDelay.wait_time = waveDelay



func start_spawn_zombie():
	random_adjustment = rand_range(-0.5, 0.5)
	$WaveDelay.wait_time = waveDelay + random_adjustment
	$WaveDelay.start()
	
func spawn_zombie():
	
	match numWave:
		1:
			if(wave1_zombies.size() > 0):
				wave1_zombies.shuffle()

				var zombie_type = wave1_zombies.pop_front()
				var zombie_instance = zombie_type.instance()
				zombie_instance.position = self.position #Adjust position as needed
				get_parent().add_child(zombie_instance)  # Add to the GameLayer
				
				

		2:
			if(wave2_zombies.size() > 0):
				wave2_zombies.shuffle()
				var zombie_type = wave2_zombies.pop_front()
				var zombie_instance = zombie_type.instance()
				zombie_instance.position = self.position + Vector2(-30,0)  #Adjust position as needed
				get_parent().add_child(zombie_instance)  # Add to the GameLayer
				#print("Spawn wave 2")
		

		3:
			if(wave3_zombies.size() > 0):
				wave3_zombies.shuffle()
				var zombie_type = wave3_zombies.pop_front()
				var zombie_instance = zombie_type.instance()
				zombie_instance.position = self.position + Vector2(-10,0) #Adjust position as needed
				get_parent().add_child(zombie_instance)  # Add to the GameLayer
				#print("Spawn wave 3")
		_:
			print("Value is something else")
	
# Function to populate the zombies array based on numbers provided
func populate_zombies(base_zombie_count: int, conehead_zombie_count: int, 
					buckethead_zombie_count: int, screendoor_zombie_count: int, 
					dancer_zombie_count: int, poleVault_zombie_count: int,
					ticker_zombie_count: int,
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
				
func increase_wave():
	numWave = numWave + 1


func _on_WaveDelay_timeout():
	spawn_zombie()
	$WaveDelay.stop()
