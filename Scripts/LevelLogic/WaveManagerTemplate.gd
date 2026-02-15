extends Node

class_name WaveManagerTemplate
#Template for All Wave Managers to Extend

# Define custom signals
signal level_start(custom_message)
#signal blood_tutorial(custom_message)
signal wave2started(custom_message)

signal wave1Started
var wave1IsStarted = false 
signal wave2AlmostStart
signal wave2Started
signal wave3Started

var current_wave = 1                # Current wave number
var zombies_per_wave = 2            # Number of zombies in the current wave
var spawn_interval = 3.0            # Time interval between each zombie spawn
var time_between_waves = 20.0       # Delay before starting a new wave
var startWave2 : bool = true 

var wave_active = false             # Whether a wave is currently active
var zombies_spawned = 0             # Counter for spawned zombies
var zombie_scene = preload("res://Scenes/ZombieScenes/BasicZombie.tscn")  # Path3D to the zombie scene

var spawners = []  # Array to hold all ZombieSpawner nodes
var timers = [] # Array to hold all the timers in the WavePreview nodes
var wavePreviewIcons = [] # Array to hold all of the WavePreviewIcons
var health_points = 100 

@export var StartDelay = 0
#Amount of Time it Takes a wave to spawn after previous done
@export var Wave2StartTime = 25
@export var Wave3StartTime = 40

#Time In Between Spawns In a Wave? #Look at More #I think its extra delay between waves??
@export var Wave1_Interval = 0.5
@export var Wave2_Interval = 0.5
@export var Wave3_Interval = 0.5
@export var canStartGame : bool = false 

@export var checkEndLevel = false
var levelOver = false 
var numWave = 0
var health = 5

var root
var new_scene
var retry_scene
var plant_manager
var levelChildren = []

func _physics_process(_delta):
	#New game start 
	
	if canStartGame:
		print("Starting All timers this onceFF")
		for timer in timers:
			if timer != null:
				print("Timer isFF ", timer)
				timer.wait_time = StartDelay
				timer.start()
		
		if $ProceedGame.is_stopped():
			print("Proceed Game is StartingNowFF ",$ProceedGame.wait_time )
			$ProceedGame.start()
		else:
			print("Proceed Game is StoppedFF")
		
		canStartGame = false
		
	if(checkEndLevel):
		print("Alive Enemies is ", get_tree().get_nodes_in_group("Alive-Enemies").size())
		if levelOver != true :
			if get_tree().get_nodes_in_group("Alive-Enemies").size() == 0:
				end_level()
				levelOver = true

func end_level():
	print("Attempting End Level")
	
	for child in get_parent().get_parent().get_parent().get_children():
		if "LevelSwitcher" in child.name:
			child.visible = true
	print("PAUSE GAME")
	get_tree().paused = true

	
	
func _ready():
	spawners = []
	print("Spawners is now ", spawners)
	timers = []
	wavePreviewIcons = []
	print("Wave Preview Icons is now ", spawners)
	checkEndLevel = false
	levelOver = false
	numWave = 0
	wave1IsStarted = false
	startWave2 = true
	health_points = 10
	canStartGame = false
	plant_manager = get_parent().get_parent().get_node("PlantManager")
	$Area2D.connect("area_entered",player_take_damage)
	
	
	# Get the root node of the current scene
	root = get_tree().current_scene

	$Wave1.wait_time = Wave1_Interval
	$Wave2.wait_time = Wave2_Interval
	#for child in get_parent().get_parent().get_node("GameLayer").get_children():
	var levelChildren = []
	print("THE CHILDREN ARE ", get_parent().get_children())
	for child in get_parent().get_children():
		#print("CHILD is " , child)
		if child.is_in_group("PurpleLevel") or child.is_in_group("GreenLevel"):
			levelChildren.append(child)
			#print("LevelChild is " , child)
	for level_child in levelChildren:
		for child in level_child.get_children():
			#print("Child is ", child)
			if "GameLayer" in child.name:
				print("Childddd is ", child)
				for new_child in child.get_children():
					#print("New Child is ", new_child)
					if "ZombieSpawner" in new_child.name:
						print("Spawners.append ", new_child.name)
						spawners.append(new_child)
						#print("Child Spawner to append is ", new_child)
						#print("Timers.append new_child.get_child(1) : ",new_child.find_child("WavePreview").name)
						#print(".get_child(2): , ", new_child.find_child("WavePreview").get_child(2).name)
						#Appends toggle visibility here toggleV
						timers.append(new_child.find_child("WavePreview").get_child(2))
						print("WavePreviewIcons.append : ",new_child.find_child("WavePreview").name)
						wavePreviewIcons.append(new_child.find_child("WavePreview"))
	#Connect done spawning
	for spawner in spawners:
		if spawner != null:
			spawner.doneSpawning.connect(_done_spawning)
		
				
	$ProceedGame.wait_time = StartDelay
	$ProceedGame.wait_time = 0
	print("Proceed Game Wait Time is ", 0)
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
	if startWave2 == true:
		startWave2 = false #Only One Wave 2 Can be Started
		print("---------- WAVE MANAGER startSecondWave() CALLED ----------")
		print("[WM] Current time: ", Time.get_ticks_msec())
		print("[WM] numWave BEFORE increment: ", numWave)
		print("[WM] $Wave2.is_stopped() BEFORE: ", $Wave2.is_stopped())

		$Wave2.start()
		print("[WM] $Wave2.start() called")
		print("[WM] $Wave2.is_stopped() AFTER start: ", $Wave2.is_stopped())
		print("[WM] $Wave2.wait_time: ", $Wave2.wait_time)
		print("[WM] $Wave2.time_left: ", $Wave2.time_left)

		$ProceedGame.wait_time = Wave3StartTime
		$ProceedGame.start()

		numWave = numWave + 1
		print("[WM] numWave AFTER increment: ", numWave)

		for icon in wavePreviewIcons:
			print("[WM] Swapping visibility for icon: ", icon.name)
			if icon != null:
				icon.swap_Visibility()

		for timer in timers:
			if timer != null:
				timer.wait_time = $ProceedGame.wait_time - 10
				timer.start()

		print("[WM] Number of spawners: ", spawners.size())
		for spawner in spawners:
			print("[WM] Spawner: ", spawner.name, " - numWave: ", spawner.numWave)

		print("---------- WAVE MANAGER startSecondWave() COMPLETED ----------")
		
func _on_ProceedGame_timeout():
	$ProceedGame.stop()
	print("ProceedGameTimeout",numWave)
	for spawner in spawners:
		if spawner != null:
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
			if startWave2 : 
				$Wave2.start()
				$ProceedGame.wait_time = Wave3StartTime
				$ProceedGame.start()
				numWave = numWave + 1
				print("Wave Preview Icons Is ",wavePreviewIcons)
				for icon in wavePreviewIcons:
					if icon != null:
						icon.swap_Visibility()
				for timer in timers:
					timer.wait_time = $ProceedGame.wait_time - 10
					timer.start()

			# thing.callFunc(pass)
		2:
			print("Start Wave 3")
			for icon in wavePreviewIcons:
				if icon != null:
					icon.swap_Visibility()
			$Wave3.start()
			$ProceedGame.stop()
		_:
			print("Value is something else")

# Spawn the first wave 
func _on_Wave1_timeout():
	#print("Spawning first wave")
	#wave1Started.emit()
	var wave_Interval = Wave1_Interval
	var random_adjustment = randf_range(-1.0,0.1)
	wave_Interval = wave_Interval + random_adjustment
	$Wave1.wait_time = wave_Interval
	
	for spawner in spawners:
		if spawner != null:
			print("Calling Wave 1 Start Spawn Zombie")
			print("Spawners is ", spawners)
			spawner.start_spawn_zombie()
	#wave1Started.emit()
	#Global.start_wave_1()

# Spawn the Second Wave
func _on_Wave2_timeout():
	print("********** WAVE 2 TIMEOUT - SPAWNING ZOMBIES **********")
	print("[WM-W2] Current time: ", Time.get_ticks_msec())
	print("[WM-W2] numWave: ", numWave)
	print("[WM-W2] Number of spawners: ", spawners.size())

	wave2Started.emit()
	print("[WM-W2] wave2Started signal emitted")

	var wave_Interval = Wave2_Interval
	var random_adjustment = randf_range(-1.0,0.1)
	wave_Interval = wave_Interval + random_adjustment
	$Wave2.wait_time = wave_Interval
	print("[WM-W2] Next Wave2 interval set to: ", wave_Interval)

	for spawner in spawners:
		if spawner != null:
			print("[WM-W2] Calling start_spawn_zombie() on spawner: ", spawner.name)
			print("[WM-W2] Spawner numWave before call: ", spawner.numWave)
			spawner.start_spawn_zombie()
			print("[WM-W2] Spawner numWave after call: ", spawner.numWave)

	print("********** WAVE 2 TIMEOUT COMPLETED **********")

# Spawn the last wave and start checking for the end of the wave 
func _on_Wave3_timeout():
	print("Spawning third wave")
	wave3Started.emit()
	var wave_Interval = Wave3_Interval
	var random_adjustment = randf_range(-1.0,0.1)
	wave_Interval = wave_Interval + random_adjustment
	$Wave3.wait_time = wave_Interval
	
	for spawner in spawners:
		if spawner != null:
			print("Calling Wave 3 Start Spawn Zombie")
			spawner.start_spawn_zombie()
		
	#checkEndLevel = true

func _done_spawning():
	print("Done Spawning")
	checkEndLevel = true

#TODO Taking Damage
func player_take_damage(area: Area2D) -> void:
	#print("AAAAAAGGGGGGGG: ",area.name)
	if area.is_in_group("Zombie"):
		print("Subtracting Health")
		area.die()

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
	if wave1IsStarted == false:
		wave1Started.emit()
		wave1IsStarted = true 
	
#Damage the Player 
func subtract_health():
	health_points -= 1 
	#get_tree().get_first_node_in_group("Purple").get_health_ui().text = "Health: " + str(health_points)
	get_tree().get_first_node_in_group("Purple").get_health_ui().text = str(health_points)
	get_tree().get_first_node_in_group("Green").get_health_ui().text = str(health_points)
	#get_parent().get_parent().get_node("CurrentScene/Level0-4/UILayer/HBoxContainer2/Health").text = str(health_points)
	#get_parent().get_parent().get_node("UILayer/SunCounter/HBoxContainer/HealthPoints").text = "Health: " + str(health_points)
	print(get_tree().get_first_node_in_group("Purple").get_health_ui(),"Health is ",health_points)
	if health_points <= 0:
		lose()

func lose():
	for child in get_parent().get_parent().get_children():
		if "LevelSwitcher" in child.name:
			child.lose()
			child.visible = true
	get_tree().paused = true
