extends LevelTemplate

enum TutorialState {
	FORCE_SELECT_HIVE,
	FORCE_PLACE_HIVE,
	EXPLAIN_ERUPTER_ZOMBIE,
	TUTORIAL_P1_DONE,
	TUTORIAL_P2_DONE,
	EXPLAIN_LANCER_ZOMBIE
}


var thisLevel := "res://Scenes/LevelScenes/Level0-5.tscn"
var thisAltLevel := "res://Scenes/LevelScenes/Level0-5_Alternate.tscn"

var level05 = "res://Scenes/LevelScenes/Level0-5.tscn"
var level05Alt = "res://Scenes/LevelScenes/Level0-5_Alternate.tscn"
var tutorial_state: TutorialState = TutorialState.FORCE_SELECT_HIVE
var erupterExplained := false 
var lancerExplained := false
var erupter_zombie_demo_scene = preload("res://_UI/GameDemonstrations/ZombieTutorials/erupter_zombie_demo.tscn")
var lancer_zombie_demo_scene = preload("res://_UI/GameDemonstrations/ZombieTutorials/lancer_zombie_demo.tscn")
var level06 = "res://Scenes/LevelScenes/Level0-6.tscn"
var level06Alt = "res://Scenes/LevelScenes/Level0-6_Alternate.tscn"

const TUTORIAL_SELECT_HIVE = "res://_Assets/Text/TextFiles/Level0-5_Tutorial_SelectHive.txt"
const TUTORIAL_PLACE_HIVE = "res://_Assets/Text/TextFiles/Level0-5_Tutorial_PlaceHive.txt"
const TUTORIAL_EXPLAIN_ERUPTER = "res://_Assets/Text/TextFiles/ZombieDescriptions/tickerZombieDescription.txt"
const TUTORIAL_EXPLAIN_LANCER = "res://_Assets/Text/TextFiles/ZombieDescriptions/poleVaultZombieDescription.txt"



func _ready():
	Dialogic.Inputs.auto_skip.enabled = true 
	waveManager = get_parent().get_node("WaveManager")
	waveManager.set_dialog_end(new_end_dialog)
	
	waveManager.Wave2StartTime = 35
	waveManager.Wave3StartTime = 45
	
	pause_Button.set_restart_levels(level05,level05Alt)
	process_mode = Node.PROCESS_MODE_ALWAYS
	toolTips.set_text(TUTORIAL_SELECT_HIVE)
	toolTips.noButtonShow()
	Global.resetSunflowerCount()
	
	attach_script_to_sway_children("res://Scripts/Environment/sway.gd")
	
	
	toolTips.connect("ToolTipHid", Callable(self, "_on_tooltip_hidden"))
	waveManager.connect("wave1Started", Callable(self, "_on_wave_1_started"))
	waveManager.connect("wave2Started", Callable(self, "_on_wave_2_started"))
	waveManager.connect("wave3Started", Callable(self, "_on_wave_3_started"))
	plantManager.connect("wasp_placed", Callable(self, "_on_hive_placed"))
	
	# Connect to button presses
	var hive_button = plantSelectionMenu.get_node("PanelContainer/VBoxContainer/HBoxContainer/Hive/HiveButton")
	hive_button.connect("pressed", Callable(self, "_on_hive_button_pressed"))
	toolTips.hide()
	Dialogic.timeline_ended.connect(finish_ready)
	#Dialogic.start("res://Assets/Dialog/level_05_start_dialog.dtl")
	finish_ready()
	# Start tutorial
	#_transition_to_state(TutorialState.FORCE_SELECT_HIVE)
	#
	#
	#levelSwitcher.update_level(level06,level06Alt)
	#
	#Global.unHidePlantSelectionMenu()

func finish_ready():
	print("Skipped Dialog")
	# Start tutorial
	toolTips.show()
	_transition_to_state(TutorialState.FORCE_SELECT_HIVE)
	levelSwitcher.update_level(level06,level06Alt)
	levelSwitcher.update_current_level(thisLevel,thisAltLevel)
	Global.unHidePlantSelectionMenu()
		
func getIsPurpleDimension():
	return 
	
func start_game():
	show_all_plant_buttons()
	plantSelectionMenu.canSwapScenes = true
	#green_dimension = get_parent().get_node("Level03Alternate")
	#var possibleGreenDimension
	for node in get_parent().get_children():
		if node.has_method("getIsGreenDimension"):
			green_dimension = node
	print("Green D is ", green_dimension)
	if waveManager.canStartGame == true:
		return
	
	waveManager.canStartGame = true
	green_dimension.start_game()
	
# Input filtering system - intercepts input based on tutorial state
func _input(event):
	match tutorial_state:
		TutorialState.FORCE_SELECT_HIVE:
			_handle_force_select_hive_input(event)
		TutorialState.FORCE_PLACE_HIVE:
			_start_force_place_hive()
		TutorialState.EXPLAIN_ERUPTER_ZOMBIE:
			if erupterExplained:
				pass
			else:
				_start_explain_erupter_zombie()
		TutorialState.EXPLAIN_LANCER_ZOMBIE:
			if lancerExplained:
				pass
			else:
				_start_explain_lancer_zombie()


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
		#print("Script attached to: ", child.name)	
		

# State transition system
func _transition_to_state(new_state: TutorialState):
	#print("[Tutorial] Transition: ", TutorialState.keys()[tutorial_state], " → ", TutorialState.keys()[new_state])
	tutorial_state = new_state

	match new_state:
		TutorialState.FORCE_SELECT_HIVE:
			_start_force_select_hive()
		TutorialState.FORCE_PLACE_HIVE:
			_start_force_place_hive()
		TutorialState.EXPLAIN_ERUPTER_ZOMBIE:
			pass
			#_start_explain_chimera()
		TutorialState.TUTORIAL_P2_DONE:
			toolTips._on_Button_pressed()
			

func _on_tooltip_hidden():
	hide_spotlight()
	#print("########## TOOLTIP HIDDEN ##########")
	#print("[Tutorial] Current state: ", TutorialState.keys()[tutorial_state])
	#print("[Tutorial] Current time: ", Time.get_ticks_msec())
	match tutorial_state:
		TutorialState.FORCE_SELECT_HIVE:
			pass
		TutorialState.FORCE_PLACE_HIVE:
			#print("UNPPAUSE HERE")
			get_tree().paused = false
		TutorialState.EXPLAIN_ERUPTER_ZOMBIE:
			#print("[Tutorial] Erupter explained - waiting for Wave 2")
			#print("UNPPAUSE HERE")
			get_tree().paused = false  # Unpause game
			
		TutorialState.EXPLAIN_LANCER_ZOMBIE:
		#	print("[Tutorial] Lancer explained")
		#	print("UNPPAUSE HERE")
			get_tree().paused = false  # Unpause game
			
func _on_wave_1_started():
	#print("[Tutorial] Wave 1 started")
	_transition_to_state(TutorialState.EXPLAIN_LANCER_ZOMBIE)
	
	
func _on_wave_2_started():
	#print("[Tutorial] Wave 2 started")
	_transition_to_state(TutorialState.EXPLAIN_ERUPTER_ZOMBIE)

func _on_wave_3_started():
	#print("[Tutorial] Wave 3 Started")
	pass



	

func _handle_force_select_hive_input(event):
	# Only allow clicking hive button, block all keyboard input
	if event is InputEventKey:
		get_viewport().set_input_as_handled()
	# Mouse input: hive button gets clicks via visibility, others hidden	
	
func _handle_force_place_hive_input(event):
	# Allow mouse clicks for placement, block X key (deselect)
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_X:
			get_viewport().set_input_as_handled()
			
func _start_force_select_hive():
	toolTips.set_text(TUTORIAL_SELECT_HIVE)
	toolTips.noButtonShow()

	hide_all_plant_buttons_except_hive()
	highlight_hive_button()

	# ADD THIS: Show spotlight on Hive button
	var hive_button = plantSelectionMenu.get_node("PanelContainer/VBoxContainer/HBoxContainer/Hive/HiveButton")
	show_spotlight_at_node(hive_button)

	waveManager.canStartGame = false
	plantSelectionMenu.canSwapScenes = false
	
func _start_force_place_hive():
	#print("[Tutorial] Starting FORCE_PLACE_HIVE")
	toolTips.set_text(TUTORIAL_PLACE_HIVE)
	toolTips.noButtonShow()

	# Remove walnut highlight
	var hive_button = plantSelectionMenu.get_node("PanelContainer/VBoxContainer/HBoxContainer/Hive/HiveButton")
	plantSelectionMenu.remove_button_highlight(hive_button)

	# Hide spotlight (grid too large)
	hide_spotlight()

func _on_hive_button_pressed():
	#print("[Tutorial] Hive button pressed in state: ", TutorialState.keys()[tutorial_state])
	if tutorial_state == TutorialState.FORCE_SELECT_HIVE:
		_transition_to_state(TutorialState.FORCE_PLACE_HIVE)

func _on_codex_button_pressed():
	#print("[Tutorial] Codex button pressed in state: ", TutorialState.keys()[tutorial_state])
	_transition_to_state(TutorialState.TUTORIAL_P2_DONE)
	

func _on_hive_placed(grid_pos: Vector2):
	#print("[Tutorial] Hive placed at grid: ", grid_pos, " in state: ", TutorialState.keys()[tutorial_state])
	pass

	if tutorial_state == TutorialState.FORCE_PLACE_HIVE:
		#print("[Tutorial] Hive placement complete - tutorial initial part finished")
		toolTips.hide()
		_transition_to_state(TutorialState.TUTORIAL_P1_DONE)
		show_all_plant_buttons()
		plantSelectionMenu.canSwapScenes = true
		#start_game()
		# Tutorial complete - no further forced actions
		
func highlight_hive_button():
	var hive_button = plantSelectionMenu.get_node("PanelContainer/VBoxContainer/HBoxContainer/Hive/HiveButton")
	plantSelectionMenu.add_button_highlight(hive_button)	
	
	
func hide_all_plant_buttons_except_hive():
	# Hide all buttons except Spyder
	plantSelectionMenu.get_node("PanelContainer/VBoxContainer/HBoxContainer/Sunflower/SunflowerButton").visible = false
	plantSelectionMenu.get_node("PanelContainer/VBoxContainer/HBoxContainer/Sunflower/SunFlowerLabel").visible = false

	plantSelectionMenu.get_node("PanelContainer/VBoxContainer/HBoxContainer/Walnut/WalnutButton").visible = false
	plantSelectionMenu.get_node("PanelContainer/VBoxContainer/HBoxContainer/Walnut/WalnutLabel").visible = false

	plantSelectionMenu.get_node("PanelContainer/VBoxContainer/HBoxContainer/Egg/EggButton").visible = false
	plantSelectionMenu.get_node("PanelContainer/VBoxContainer/HBoxContainer/Egg/EggLabel").visible = false 
	
	plantSelectionMenu.get_node("PanelContainer/VBoxContainer/HBoxContainer/Peashooter/PeashooterButton2").visible = false
	plantSelectionMenu.get_node("PanelContainer/VBoxContainer/HBoxContainer/Peashooter/PeashooterLabel").visible = false
	
	

	plantSelectionMenu.get_node("PanelContainer/VBoxContainer/HBoxContainer/Hive/HiveButton").visible = true
	plantSelectionMenu.get_node("PanelContainer/VBoxContainer/HBoxContainer/Hive/HiveLabel").visible = true
	plantSelectionMenu.get_node("PanelContainer/VBoxContainer/HBoxContainer/Hive").visible = true


	plantSelectionMenu.get_node("PanelContainer/VBoxContainer/HBoxContainer/Maw/MawButton").visible = false
	plantSelectionMenu.get_node("PanelContainer/VBoxContainer/HBoxContainer/Maw/MawLabel").visible = false


func show_all_plant_buttons():
	# Show Sunflower
	plantSelectionMenu.get_node("PanelContainer/VBoxContainer/HBoxContainer/Sunflower/SunflowerButton").visible = true
	plantSelectionMenu.get_node("PanelContainer/VBoxContainer/HBoxContainer/Sunflower/SunFlowerLabel").visible = true
	plantSelectionMenu.get_node("PanelContainer/VBoxContainer/HBoxContainer/Sunflower").visible = true
	# Show Spyder
	plantSelectionMenu.get_node("PanelContainer/VBoxContainer/HBoxContainer/Peashooter/PeashooterButton2").visible = true
	plantSelectionMenu.get_node("PanelContainer/VBoxContainer/HBoxContainer/Peashooter/PeashooterLabel").visible = true	
	
	#Show Walnut
	plantSelectionMenu.get_node("PanelContainer/VBoxContainer/HBoxContainer/Walnut/WalnutButton").visible = true
	plantSelectionMenu.get_node("PanelContainer/VBoxContainer/HBoxContainer/Walnut/WalnutLabel").visible = true	
	plantSelectionMenu.get_node("PanelContainer/VBoxContainer/HBoxContainer/Walnut").visible = true	
	
	plantSelectionMenu.get_node("PanelContainer/VBoxContainer/HBoxContainer/Maw/MawButton").visible = true 
	plantSelectionMenu.get_node("PanelContainer/VBoxContainer/HBoxContainer/Maw/MawLabel").visible = true 
	plantSelectionMenu.get_node("PanelContainer/VBoxContainer/HBoxContainer/Maw").visible = true 
	
	plantSelectionMenu.get_node("PanelContainer/VBoxContainer/HBoxContainer/Egg/EggButton").visible = true
	plantSelectionMenu.get_node("PanelContainer/VBoxContainer/HBoxContainer/Egg/EggLabel").visible = true 
	plantSelectionMenu.get_node("PanelContainer/VBoxContainer/HBoxContainer/Egg").visible = true 
	
	plantSelectionMenu.get_node("PanelContainer/VBoxContainer/HBoxContainer/WorldSwap").visible = true 
	plantSelectionMenu.get_node("PanelContainer/VBoxContainer/HBoxContainer/Codex").visible = true 

# Spotlight helper functions 
func _start_explain_erupter_zombie():
	erupterExplained = true 
	#print("[TUTORIAL] Start Explain Erupter Zombie")
	toolTips.setComplexSceneTextPause(TUTORIAL_EXPLAIN_ERUPTER)
	toolTips.setComplexScene(erupter_zombie_demo_scene)
	toolTips.showButton()	
	
func _start_explain_lancer_zombie():
	lancerExplained = true 
	#print("[TUTORIAL] Start Explain Lancer Zombie")
	toolTips.setComplexSceneTextPause(TUTORIAL_EXPLAIN_LANCER)
	toolTips.setComplexScene(lancer_zombie_demo_scene)
	toolTips.showButton()	





	


func show_guide():
	$GameLayer/GridManager/TileMapLayer.place_rectangles_on_rows(2, 8)
	
