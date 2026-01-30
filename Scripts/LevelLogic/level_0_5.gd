extends Control

enum TutorialState {
	FORCE_SELECT_HIVE,
	FORCE_PLACE_HIVE,
	EXPLAIN_ERUPTER_ZOMBIE,
	TUTORIAL_P1_DONE,
	TUTORIAL_P2_DONE,
	EXPLAIN_LANCER_ZOMBIE
}

@onready var toolTips = $"../ToolTips"
@onready var plantManager = $PlantManager
@onready var plantSelectionMenu = $"../PlantSelectionMenu"
#@onready var waveManager = $GameLayer/WaveManager
var waveManager 
@onready var levelSwitcher = 	$"../LevelSwitcher"
@onready var spotlight_overlay = $"../SpotlightOverlay"  # Reference to CanvasLayer
@onready var green_dimension = $CurrentScene/Level03Alternate
@onready var pause_Button = $"../PauseButton"



var level05 = "res://Scenes/LevelScenes/Level0-5.tscn"
var level05Alt = "res://Scenes/LevelScenes/Level0-5_Alternate.tscn"
var tutorial_state: TutorialState = TutorialState.FORCE_SELECT_HIVE
var erupterExplained := false 
var lancerExplained := false
var wave2Started := false
var erupter_zombie_demo_scene = preload( "res://Scenes/Tutorials/erupter_zombie_demo.tscn")
var lancer_zombie_demo_scene = preload("res://Scenes/Tutorials/lancer_zombie_demo.tscn")
var level06 = "res://Scenes/LevelScenes/Level0-6.tscn"
var level06Alt = "res://Scenes/LevelScenes/Level0-6_Alternate.tscn"

const TUTORIAL_SELECT_HIVE = "res://Assets/Text/TextFiles/Level0-5_Tutorial_SelectHive.txt"
const TUTORIAL_PLACE_HIVE = "res://Assets/Text/TextFiles/Level0-5_Tutorial_PlaceHive.txt"
const TUTORIAL_EXPLAIN_ERUPTER = "res://Assets/Text/TextFiles/ZombieDescriptions/tickerZombieDescription.txt"
const TUTORIAL_EXPLAIN_LANCER = "res://Assets/Text/TextFiles/ZombieDescriptions/poleVaultZombieDescription.txt"



func _ready():
	waveManager = get_parent().get_node("WaveManager")
	pause_Button.set_restart_levels(level05,level05Alt)
	process_mode = Node.PROCESS_MODE_ALWAYS
	toolTips.set_text(TUTORIAL_SELECT_HIVE)
	toolTips.noButtonShow()
	Global.resetSunflowerCount()
	
	
	toolTips.connect("ToolTipHid", Callable(self, "_on_tooltip_hidden"))
	waveManager.connect("wave1Started", Callable(self, "_on_wave_1_started"))
	waveManager.connect("wave2Started", Callable(self, "_on_wave_2_started"))
	waveManager.connect("wave3Started", Callable(self, "_on_wave_3_started"))
	plantManager.connect("wasp_placed", Callable(self, "_on_hive_placed"))
	
	# Connect to button presses
	var hive_button = plantSelectionMenu.get_node("PanelContainer/VBoxContainer/HBoxContainer/Hive/HiveButton")
	hive_button.connect("pressed", Callable(self, "_on_hive_button_pressed"))
	# Start tutorial
	_transition_to_state(TutorialState.FORCE_SELECT_HIVE)
	
	
	levelSwitcher.update_level(level06,level06Alt)
	
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




# State transition system
func _transition_to_state(new_state: TutorialState):
	print("[Tutorial] Transition: ", TutorialState.keys()[tutorial_state], " → ", TutorialState.keys()[new_state])
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
	print("########## TOOLTIP HIDDEN ##########")
	print("[Tutorial] Current state: ", TutorialState.keys()[tutorial_state])
	print("[Tutorial] Current time: ", Time.get_ticks_msec())
	match tutorial_state:
		TutorialState.FORCE_SELECT_HIVE:
			pass
		TutorialState.FORCE_PLACE_HIVE:
			print("UNPPAUSE HERE")
			get_tree().paused = false
		TutorialState.EXPLAIN_ERUPTER_ZOMBIE:
			print("[Tutorial] Erupter explained - waiting for Wave 2")
			print("UNPPAUSE HERE")
			get_tree().paused = false  # Unpause game
			
		TutorialState.EXPLAIN_LANCER_ZOMBIE:
			print("[Tutorial] Lancer explained")
			print("UNPPAUSE HERE")
			get_tree().paused = false  # Unpause game
			
func _on_wave_1_started():
	print("[Tutorial] Wave 1 started")
	_transition_to_state(TutorialState.EXPLAIN_LANCER_ZOMBIE)
	
	
func _on_wave_2_started():
	print("[Tutorial] Wave 2 started")
	_transition_to_state(TutorialState.EXPLAIN_ERUPTER_ZOMBIE)

func _on_wave_3_started():
	print("[Tutorial] Wave 3 Started")



	

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
	print("[Tutorial] Starting FORCE_PLACE_HIVE")
	toolTips.set_text(TUTORIAL_PLACE_HIVE)
	toolTips.noButtonShow()

	# Remove walnut highlight
	var hive_button = plantSelectionMenu.get_node("PanelContainer/VBoxContainer/HBoxContainer/Hive/HiveButton")
	plantSelectionMenu.remove_button_highlight(hive_button)

	# Hide spotlight (grid too large)
	hide_spotlight()

func _on_hive_button_pressed():
	print("[Tutorial] Hive button pressed in state: ", TutorialState.keys()[tutorial_state])
	if tutorial_state == TutorialState.FORCE_SELECT_HIVE:
		_transition_to_state(TutorialState.FORCE_PLACE_HIVE)

func _on_codex_button_pressed():
	print("[Tutorial] Codex button pressed in state: ", TutorialState.keys()[tutorial_state])
	_transition_to_state(TutorialState.TUTORIAL_P2_DONE)
	

func _on_hive_placed(grid_pos: Vector2):
	print("[Tutorial] Hive placed at grid: ", grid_pos, " in state: ", TutorialState.keys()[tutorial_state])

	if tutorial_state == TutorialState.FORCE_PLACE_HIVE:
		print("[Tutorial] Hive placement complete - tutorial initial part finished")
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

	plantSelectionMenu.get_node("PanelContainer/VBoxContainer/HBoxContainer/Eye/EyeButton").visible = false
	plantSelectionMenu.get_node("PanelContainer/VBoxContainer/HBoxContainer/Eye/EyeLabel").visible = false

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
	print("[TUTORIAL] Start Explain Erupter Zombie")
	toolTips.setComplexSceneTextPause(TUTORIAL_EXPLAIN_ERUPTER)
	toolTips.setComplexScene(erupter_zombie_demo_scene)
	toolTips.showButton()	
	
func _start_explain_lancer_zombie():
	lancerExplained = true 
	print("[TUTORIAL] Start Explain Lancer Zombie")
	toolTips.setComplexSceneTextPause(TUTORIAL_EXPLAIN_LANCER)
	toolTips.setComplexScene(lancer_zombie_demo_scene)
	toolTips.showButton()	
	
## Shows spotlight centered on a Control node
func show_spotlight_at_node(target_node: Control, size_multiplier: float = 1.0):
	if not target_node or not spotlight_overlay:
		print("NOT SHOWING SPOTLIGHT")
		return
	print("Showing Spotlight", target_node, size_multiplier)

	# Get center of target in screen coordinates
	var global_rect = target_node.get_global_rect()
	var center = global_rect.get_center()

	# Calculate appropriate spotlight size based on button size
	var viewport_size = get_viewport().get_visible_rect().size
	var button_diagonal = global_rect.size.length()
	var uv_size = (button_diagonal / viewport_size.y) * 0.6 * size_multiplier

	show_spotlight_at_position(center, uv_size)

## Shows spotlight at specific screen position
func show_spotlight_at_position(screen_pos: Vector2, size: float = 0.15):
	if not spotlight_overlay:
		return
	var viewport_size = get_viewport().get_visible_rect().size
	var uv_pos = screen_pos / viewport_size
	print("[SPOTLIGHT] Screen pos: ", screen_pos, " → UV: ", uv_pos, " Size: ", size)
	#var viewport_size = get_viewport().get_visible_rect().size
	#var uv_pos = screen_pos / viewport_size

	var spotlight_rect = spotlight_overlay.get_node("SpotlightRect")
	spotlight_rect.material.set_shader_parameter("circle_position", uv_pos)
	spotlight_rect.material.set_shader_parameter("circle_size", size)
	spotlight_overlay.visible = true

## Hides spotlight overlay
func hide_spotlight():
	if spotlight_overlay:
		spotlight_overlay.visible = false


func place_empty_blocker_plant(grid_pos):
	plantManager.place_empty_blocker_plant(grid_pos)
	
func remove_empty_blocker_plant(grid_pos):
	plantManager.clear_space_alt(grid_pos)
