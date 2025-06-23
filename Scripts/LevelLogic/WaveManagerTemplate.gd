extends Node

class_name WaveManagerTemplate
#Template for All Wave Managers to Extend

# Define custom signals
signal level_start(custom_message)
#signal blood_tutorial(custom_message)
signal wave2started(custom_message)

signal wave1Started
signal wave2AlmostStart
signal wave2Started
signal wave3Started

var current_wave = 1                # Current wave number
var zombies_per_wave = 2            # Number of zombies in the current wave
var spawn_interval = 3.0            # Time interval between each zombie spawn
var time_between_waves = 20.0       # Delay before starting a new wave
var startWave2 : bool = false 

var wave_active = false             # Whether a wave is currently active
var zombies_spawned = 0             # Counter for spawned zombies
var zombie_scene = preload("res://Scenes/ZombieScenes/BasicZombie.tscn")  # Path3D to the zombie scene

var spawners = []  # Array to hold all ZombieSpawner nodes
var timers = [] # Array to hold all the timers in the WavePreview nodes
var wavePreviewIcons = [] # Array to hold all of the WavePreviewIcons
var health_points = 10 

@export var StartDelay = 10
#Amount of Time it Takes a wave to spawn after previous done
@export var Wave2StartTime = 20
@export var Wave3StartTime = 30

#Time In Between Spawns In a Wave? #Look at More
@export var Wave1_Interval = 7.5
@export var Wave2_Interval = 9
@export var Wave3_Interval = 5.5
@export var canStartGame : bool = false 

@export var checkEndLevel = false

var numWave = 0
var health = 5

var root
var new_scene
var retry_scene
var plant_manager


func _physics_process(_delta):
	#New game start 
	
	if canStartGame:
		print("Starting All timers this once")
		for timer in timers:
			if timer != null:
				print("Timer is ", timer)
				timer.wait_time = StartDelay
				timer.start()
		$ProceedGame.start()
		
		canStartGame = false
		
	if(checkEndLevel):
		if get_tree().get_nodes_in_group("Alive-Enemies").size() == 0:
			end_level()

func end_level():
	#print("Attempting End Level")
	#assert(get_tree().change_scene_to_packed(new_scene) == OK) # Switch to earlier defined new_scene
	for child in get_parent().get_parent().get_children():
		if "LevelSwitcher" in child.name:
			child.visible = true
	get_tree().paused = true

	
func _ready():
	plant_manager = get_parent().get_parent().get_node("PlantManager")
	$Area2D.connect("area_entered",player_take_damage)
	
	
	# Get the root node of the current scene
	root = get_tree().current_scene

	$Wave1.wait_time = Wave1_Interval
	$Wave2.wait_time = Wave2_Interval
	for child in get_parent().get_parent().get_node("GameLayer").get_children():
		if "ZombieSpawner" in child.name:
			#print("Spawners.append ", child.name)
			spawners.append(child)
			#print("Timers.append child.get_child(1) : ",child.find_child("WavePreview").name)
			#print(".get_child(2): , ", child.find_child("WavePreview").get_child(2).name)
			timers.append(child.find_child("WavePreview").get_child(2))
			#print("WavePreviewIcons.append : ",child.find_child("WavePreview").name)
			wavePreviewIcons.append(child.find_child("WavePreview"))
	#Connect done spawning
	for spawner in spawners:
		spawner.doneSpawning.connect(_done_spawning)
		
				
	$ProceedGame.wait_time = StartDelay
	#for timer in timers:
	#	timer.wait_time = StartDelay
	#	timer.start()
		
	#TODO Game starts here just don't forget 
	#$ProceedGame.start()
	
	#if self.has_method("setScenes"):
		#self.setScenes()
		
			
func setScenes():
	pass
			
func startSecondWave():
	print("Second Wave Started")
	$Wave2.start()
	$ProceedGame.wait_time = Wave3StartTime
	$ProceedGame.start()
	numWave = numWave + 1
	for icon in wavePreviewIcons:
		print("Icon is ", icon.name)
		icon.swap_Visibility()
	for timer in timers:
		if timer != null:
			timer.wait_time = $ProceedGame.wait_time - 10
			timer.start()
		
func _on_ProceedGame_timeout():
	$ProceedGame.stop()
	print("ProceedGameTimeout")
	for spawner in spawners:
		spawner.increase_wave()
	
	match numWave:
		0:
			#TODO make dynamic start
			$ProceedGame.wait_time = Wave2StartTime
			#$ProceedGame.start()
			$Wave1.start()
			numWave = numWave + 1
			
			for timer in timers:
				if timer != null:
					timer.wait_time = $ProceedGame.wait_time - 10
					#timer.start()
		1:
			wave2AlmostStart.emit()
			print("AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA")
			print("Emitting Wave2Almost Start Signal")
			#if startWave2 : 
				#$Wave2.start()
				#$ProceedGame.wait_time = 30
				#$ProceedGame.start()
				#numWave = numWave + 1
				#for icon in wavePreviewIcons:
					#icon.swap_Visibility()
				#for timer in timers:
					#timer.wait_time = $ProceedGame.wait_time - 10
					#timer.start()

			# thing.callFunc(pass)
		2:
			print("Start Wave 3")
			for icon in wavePreviewIcons:
				icon.swap_Visibility()
			$Wave3.start()
			$ProceedGame.stop()
		_:
			print("Value is something else")

# Spawn the first wave 
func _on_Wave1_timeout():
	#print("Spawning first wave")
	wave1Started.emit()
	var wave_Interval = Wave1_Interval
	var random_adjustment = randf_range(-1.0,0.1)
	wave_Interval = wave_Interval + random_adjustment
	$Wave1.wait_time = wave_Interval
	
	for spawner in spawners:
		print("Calling Wave 1 Start Spawn Zombie")
		spawner.start_spawn_zombie()

# Spawn the Second Wave 
func _on_Wave2_timeout():
	print("Will now spawn second wave")
	wave2Started.emit()
	var wave_Interval = Wave2_Interval
	var random_adjustment = randf_range(-1.0,0.1)
	wave_Interval = wave_Interval + random_adjustment
	$Wave2.wait_time = wave_Interval
	
	for spawner in spawners:
		print("Calling Wave 2 Start Spawn Zombie")
		spawner.start_spawn_zombie()

# Spawn the last wave and start checking for the end of the wave 
func _on_Wave3_timeout():
	print("Spawning third wave")
	wave3Started.emit()
	var wave_Interval = Wave3_Interval
	var random_adjustment = randf_range(-1.0,0.1)
	wave_Interval = wave_Interval + random_adjustment
	$Wave3.wait_time = wave_Interval
	
	for spawner in spawners:
		print("Calling Wave 3 Start Spawn Zombie")
		spawner.start_spawn_zombie()
		
	#checkEndLevel = true

func _done_spawning():
	print("Done Spawing")
	checkEndLevel = true

#TODO Taking Damage
func player_take_damage(area: Area2D) -> void:
	#print("AAAAAAGGGGGGGG: ",area.name)
	if area.is_in_group("Zombie"):
		print("Subtracting Health")

		subtract_health()  # Subtract Heath
		#TODO Play DMG Sound
			#plant_manager.play_sun_collect()
		#print("AAAAZZZOIHOHQWDIOHWDI()") 
		
func _on_spawn_next_wave():
	print("Received spawn next wave signal!")
	print("Proceed Game Wait Time is ",$ProceedGame.wait_time )
	$ProceedGame.start()
	for timer in timers:
		if timer != null:
			#timer.wait_time = $ProceedGame.wait_time - 10
			timer.start()
	
#Damage the Player 
func subtract_health():
	health_points -= 1 
	get_parent().get_parent().get_node("UILayer/SunCounter/HealthPoints").text = "Health: " + str(health_points)
	print("Health is ",health_points)
	if health_points <= 0:
		lose()

func lose():
	for child in get_parent().get_parent().get_children():
		if "LevelSwitcher" in child.name:
			child.lose()
			child.visible = true
	get_tree().paused = true
