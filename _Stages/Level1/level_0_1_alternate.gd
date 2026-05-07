extends LevelTemplate

# Waits for purple dimension to activate Wave 2
 

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	waveManager.canStartGame = false
	attach_script_to_sway_children("res://Scripts/Environment/sway.gd")
	print("[Level0-1 Alternate] Green dimension loaded, waiting for Wave 2 activation")

	
func start_wave_2():
	hide_all_plant_buttons_except_spyder()
	print("========== GREEN DIMENSION START_WAVE_2 CALLED ==========")
	print("[GREEN] Current time: ", Time.get_ticks_msec())
	print("[GREEN] waveManager.numWave BEFORE: ", waveManager.numWave)

	waveManager.numWave = 1             # Initialize wave state for Wave 2
	waveManager.startSecondWave()       # This increments numWave to 2

	print("[GREEN] waveManager.numWave AFTER startSecondWave: ", waveManager.numWave)
	print("[GREEN] waveManager.$Wave2.is_stopped(): ", waveManager.get_node("Wave2").is_stopped())
	print("========== GREEN DIMENSION START_WAVE_2 COMPLETED ==========")








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
	
