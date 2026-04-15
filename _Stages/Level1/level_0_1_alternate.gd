extends Control
# level_0_1_alternate.gd - Green Dimension Controller for Level 0-1
# Waits for purple dimension to activate Wave 2

#@onready var waveManager = $GameLayer/WaveManager
var waveManager 
@onready var plantManager = $PlantManager
@onready var plantSelectionMenu = $"../DemonSelectionMenu" 

func _ready():
	waveManager = get_parent().get_node("WaveManager")
	process_mode = Node.PROCESS_MODE_ALWAYS

	# Keep waves disabled until purple dimension activates us
	waveManager.canStartGame = false
	attach_script_to_sway_children("res://Scripts/Environment/sway.gd")
	print("[Level0-1 Alternate] Green dimension loaded, waiting for Wave 2 activation")

func attach_script_to_sway_children(script_path: String) -> void:

	# Find the Coral node
	var coral_node = get_node("Environment/Coral")
	
	if coral_node == null:
		push_error("Coral node not found at Environment/Coral")
		return
	
	
	# Load the script to attach
	var script_to_attach = load(script_path)
	
	if script_to_attach == null:
		push_error("Failed to load script at: " + script_path)
		return
	
	# Iterate through all children and attach the script
	for child in coral_node.get_children():
		child.set_script(script_to_attach)
		if child.is_inside_tree() and child.has_method("_ready"):
			#if self.is_in_group("Green"):
				#child.make_green()
			child._ready()
		print("Script attached to: ", child.name)	
	
	
func start_wave_2():
	
	hide_all_plant_buttons_except_spyder()
	print("========== GREEN DIMENSION START_WAVE_2 CALLED ==========")
	print("[GREEN] Current time: ", Time.get_ticks_msec())
	print("[GREEN] waveManager.numWave BEFORE: ", waveManager.numWave)

	waveManager.numWave = 1             # Initialize wave state for Wave 2

	# CRITICAL: Spawners need to be at wave 2 to spawn wave2_zombies
	# Green dimension skipped Wave 1, so spawners are still at 0
	# Need to increment twice: 0→1→2
	print("[GREEN] Incrementing spawner waves from 0 to 2...")
	for spawner in waveManager.spawners:
		if spawner.make_green == true:
			print("[GREEN] Spawner ", spawner.name, " numWave BEFORE: ", spawner.numWave)
			#spawner.increase_wave()  # 0→1
			#spawner.increase_wave()  # 1→2
			print("[GREEN] Spawner ", spawner.name, " numWave AFTER: ", spawner.numWave)

	print("[GREEN] About to call startSecondWave()...")
	waveManager.startSecondWave()       # This increments numWave to 2

	print("[GREEN] waveManager.numWave AFTER startSecondWave: ", waveManager.numWave)
	print("[GREEN] waveManager.$Wave2.is_stopped(): ", waveManager.get_node("Wave2").is_stopped())
	print("========== GREEN DIMENSION START_WAVE_2 COMPLETED ==========")


func place_empty_blocker_plant(grid_pos):
	plantManager.place_empty_blocker_plant(grid_pos)

func remove_empty_blocker_plant(grid_pos):
	plantManager.clear_space_alt(grid_pos) 
func make_camera_current():
	$Camera2D.make_current()



func hide_all_plant_buttons_except_spyder():
	# Hide all buttons except Spyder
	plantSelectionMenu.get_node("PanelContainer/VBoxContainer/HBoxContainer/Sunflower/SunflowerButton").visible = false
	plantSelectionMenu.get_node("PanelContainer/VBoxContainer/HBoxContainer/Sunflower/SunFlowerLabel").visible = false

	plantSelectionMenu.get_node("PanelContainer/VBoxContainer/HBoxContainer/Walnut/WalnutButton").visible = false
	plantSelectionMenu.get_node("PanelContainer/VBoxContainer/HBoxContainer/Walnut/WalnutLabel").visible = false

	plantSelectionMenu.get_node("PanelContainer/VBoxContainer/HBoxContainer/Egg/EggButton").visible = false
	plantSelectionMenu.get_node("PanelContainer/VBoxContainer/HBoxContainer/Egg/EggLabel").visible = false

	plantSelectionMenu.get_node("PanelContainer/VBoxContainer/HBoxContainer/Maw/MawButton").visible = false
	plantSelectionMenu.get_node("PanelContainer/VBoxContainer/HBoxContainer/Maw/MawLabel").visible = false

	plantSelectionMenu.get_node("PanelContainer/VBoxContainer/HBoxContainer/Hive/HiveButton").visible = false
	plantSelectionMenu.get_node("PanelContainer/VBoxContainer/HBoxContainer/Hive/HiveLabel").visible = false

	# Keep Spyder visible
	plantSelectionMenu.get_node("PanelContainer/VBoxContainer/HBoxContainer/Peashooter/PeashooterButton2").visible = true
	plantSelectionMenu.get_node("PanelContainer/VBoxContainer/HBoxContainer/Peashooter/PeashooterLabel").visible = true


func show_guide():
	$GameLayer/GridManager/TileMapLayer.place_rectangles_on_rows(4, 4)
	
func hide_guide():
	$GameLayer/GridManager/TileMapLayer.clear_rectangles()		
func get_health_ui():
	return $UILayer.get_the_health()
