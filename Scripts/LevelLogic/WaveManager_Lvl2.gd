extends Node
#WaveManager2

	
	
var current_wave = 1                # Current wave number
var zombies_per_wave = 2           # Number of zombies in the current wave
var spawn_interval = 3.0            # Time interval between each zombie spawn
var time_between_waves = 20.0       # Delay before starting a new wave

var wave_active = false             # Whether a wave is currently active
var zombies_spawned = 0             # Counter for spawned zombies
var zombie_scene = preload("res://Scenes/ZombieScenes/BasicZombie.tscn")  # Path to the zombie scene

var spawners = []  # Array to hold all ZombieSpawner nodes
var timers = [] # Array to hold all the timers in the WavePreview nodes
var wavePreviewIcons = [] # Array to hold all of the WavePreviewIcons


export var StartDelay = 10
#Amount of Time it Takes a wave to spawn after previous done
export var Wave2StartTime = 20
export var Wave3StartTime = 30

#Time In Between Spawns In a Wave? #Look at More
export var Wave1_Interval = 7.5
export var Wave2_Interval = 9
export var Wave3_Interval = 5.5

var checkEndLevel = false

var numWave = 0

var health = 5

#Make this runtimeDynamic
var new_scene# = preload("res://Scenes/LevelScenes/Level2--3.tscn")  # Load the Main scene

var retry_scene #= preload("res://Scenes/LevelScenes/RestartScene2.tscn")
#

func _physics_process(_delta):
	if(checkEndLevel):
		print("Enemies Left : ", get_tree().get_nodes_in_group("Alive-Enemies").size())
		if get_tree().get_nodes_in_group("Alive-Enemies").size() == 0:
			end_level()
			pass

func end_level():

	print("CHANGE - 2")
	# Switch to the Transition Scene scene
	assert(get_tree().change_scene_to(new_scene) ==OK)
	pass
	
	
	
func _ready():
	var root = get_parent().get_parent().get_name()
	if root == "Level2":
		new_scene = preload("res://Scenes/LevelScenes/Level2--3.tscn")  
		retry_scene = preload("res://Scenes/LevelScenes/RestartScene2.tscn")

	elif root == "Level3":
		#new_scene = preload("res://Scenes/LevelScenes/EndScreen.tscn")  
		#retry_scene = preload("res://Scenes/LevelScenes/RestartScene3.tscn")
		pass
		
	$Wave1.wait_time = Wave1_Interval
	$Wave2.wait_time = Wave2_Interval
	for child in get_parent().get_parent().get_node("GameLayer").get_children():
		if "ZombieSpawner" in child.name:
			spawners.append(child)
			#print("Child is " + child.get_name())
			#print("Child Kid is " + child.get_child(1).get_child(3).get_name())
			timers.append(child.get_child(1).get_child(2))
			wavePreviewIcons.append(child.get_child(1))
			
	$ProceedGame.wait_time = StartDelay
	for timer in timers:
		timer.wait_time = StartDelay
		timer.start()
	$ProceedGame.start()
		
			
			
func _on_ProceedGame_timeout():
	$ProceedGame.stop()
	print("ProceedGameTimeout")
	for spawner in spawners:
		spawner.increase_wave()
	
	match numWave:
		0:
			$ProceedGame.wait_time = Wave2StartTime
			$ProceedGame.start()
			$Wave1.start()
			numWave = numWave + 1
			
			for timer in timers:
				timer.wait_time = $ProceedGame.wait_time - 10
				timer.start()
		1:
			$Wave2.start()
			$ProceedGame.wait_time = Wave3StartTime
			$ProceedGame.start()
			numWave = numWave + 1
			for icon in wavePreviewIcons:
				icon.swap_Visibility()
			for timer in timers:
				timer.wait_time = $ProceedGame.wait_time - 10
				timer.start()

			# thing.callFunc(pass)
		2:
			for icon in wavePreviewIcons:
				icon.swap_Visibility()
			$Wave3.start()
			$ProceedGame.stop()
		_:
			print("Value is something else")


func _on_Wave1_timeout():
	
	var wave_Interval = Wave1_Interval
	var random_adjustment = rand_range(-1.0,0.1)
	wave_Interval = wave_Interval + random_adjustment
	
	#print("Wave 1 Interval is : ", wave_Interval)
	$Wave1.wait_time = wave_Interval
	
	for spawner in spawners:
		spawner.start_spawn_zombie()


func _on_Wave2_timeout():
	var wave_Interval = Wave2_Interval
	
	var random_adjustment = rand_range(-1.0,0.1)
	
	wave_Interval = wave_Interval + random_adjustment
	
	$Wave2.wait_time = wave_Interval
	
	
	for spawner in spawners:
		spawner.start_spawn_zombie()


func _on_Wave3_timeout():
	var wave_Interval = Wave3_Interval
	var random_adjustment = rand_range(-1.0,0.1)
	wave_Interval = wave_Interval + random_adjustment
	
	$Wave3.wait_time = wave_Interval
	
	for spawner in spawners:
		spawner.start_spawn_zombie()
		
	checkEndLevel = true



#Code Taking Damage Here 
func _on_Area2D_area_entered(area):
	print(area.name, " :entered home base")
	if "Zombie" in area.name:
		#Go to Restart Scene 
		get_parent().get_tree().change_scene_to(retry_scene)
		#assert(get_tree().change_scene_to(retry_scene))
		
		
		
		
		
		
