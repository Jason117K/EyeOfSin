extends Control
# level_0_1_alternate.gd - Green Dimension Controller for Level 0-1
# Waits for purple dimension to activate Wave 2

@onready var waveManager = $GameLayer/WaveManager
@onready var plantManager = $PlantManager
@onready var plantSelectionMenu = $"../PlantSelectionMenu" 

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS

	# Keep waves disabled until purple dimension activates us
	waveManager.canStartGame = false
	print("[Level0-1 Alternate] Green dimension loaded, waiting for Wave 2 activation")


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
		print("[GREEN] Spawner ", spawner.name, " numWave BEFORE: ", spawner.numWave)
		spawner.increase_wave()  # 0→1
		spawner.increase_wave()  # 1→2
		print("[GREEN] Spawner ", spawner.name, " numWave AFTER: ", spawner.numWave)

	print("[GREEN] About to call startSecondWave()...")
	waveManager.startSecondWave()       # This increments numWave to 2

	print("[GREEN] waveManager.numWave AFTER startSecondWave: ", waveManager.numWave)
	print("[GREEN] waveManager.$Wave2.is_stopped(): ", waveManager.get_node("Wave2").is_stopped())
	print("========== GREEN DIMENSION START_WAVE_2 COMPLETED ==========")


func place_empty_blocker_plant(grid_pos):
	plantManager.place_empty_blocker_plant(grid_pos)


func make_camera_current():
	$Camera2D.make_current()



func hide_all_plant_buttons_except_spyder():
	# Hide all buttons except Spyder
	plantSelectionMenu.get_node("PanelContainer/VBoxContainer/HBoxContainer/Sunflower/SunflowerButton").visible = false
	plantSelectionMenu.get_node("PanelContainer/VBoxContainer/HBoxContainer/Sunflower/SunFlowerLabel").visible = false

	plantSelectionMenu.get_node("PanelContainer/VBoxContainer/HBoxContainer/Walnut/WalnutButton").visible = false
	plantSelectionMenu.get_node("PanelContainer/VBoxContainer/HBoxContainer/Walnut/WalnutLabel").visible = false

	plantSelectionMenu.get_node("PanelContainer/VBoxContainer/HBoxContainer/Eye/EyeButton").visible = false
	plantSelectionMenu.get_node("PanelContainer/VBoxContainer/HBoxContainer/Eye/EyeLabel").visible = false

	plantSelectionMenu.get_node("PanelContainer/VBoxContainer/HBoxContainer/Egg/EggButton").visible = false
	plantSelectionMenu.get_node("PanelContainer/VBoxContainer/HBoxContainer/Egg/EggLabel").visible = false

	plantSelectionMenu.get_node("PanelContainer/VBoxContainer/HBoxContainer/Maw/MawButton").visible = false
	plantSelectionMenu.get_node("PanelContainer/VBoxContainer/HBoxContainer/Maw/MawLabel").visible = false

	plantSelectionMenu.get_node("PanelContainer/VBoxContainer/HBoxContainer/Hive/HiveButton").visible = false
	plantSelectionMenu.get_node("PanelContainer/VBoxContainer/HBoxContainer/Hive/HiveLabel").visible = false

	# Keep Spyder visible
	plantSelectionMenu.get_node("PanelContainer/VBoxContainer/HBoxContainer/Peashooter/PeashooterButton2").visible = true
	plantSelectionMenu.get_node("PanelContainer/VBoxContainer/HBoxContainer/Peashooter/PeashooterLabel").visible = true
