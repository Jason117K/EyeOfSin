extends Control

enum TutorialState {
	TUTORIAL_P1_DONE,
	TUTORIAL_P2_DONE,
	EXPLAIN_AMALGAM_ZOMBIE
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




var tutorial_state: TutorialState = TutorialState.TUTORIAL_P1_DONE
var amalgamExplained := false
var wave2Started := false
var amalgam_zombie_demo_scene = preload("res://Scenes/Tutorials/amalgam_zombie_demo.tscn")
var level06 = "res://Scenes/LevelScenes/Level0-6.tscn"
var level06Alt = "res://Scenes/LevelScenes/Level0-6_Alternate.tscn"
var gameStarted := false 
var endScreen = "res://Scenes/LevelScenes/EndScreen.tscn"
var endScreenAlt = "res://Scenes/LevelScenes/EndScreen.tscn"

const TUTORIAL_EXPLAIN_AMALGAM = "res://Assets/Text/TextFiles/ZombieDescriptions/ScreenDoorZombieDescription.txt"

@export var new_end_dialog = "res://Assets/Dialog/level_06_end_dialog.dtl"


func _ready():
	waveManager = get_parent().get_node("WaveManager")
	waveManager.set_dialog_end(new_end_dialog)
	setup_plant_selection_menu()
	pause_Button.set_restart_levels(level06,level06Alt)
	process_mode = Node.PROCESS_MODE_ALWAYS
	Global.resetSunflowerCount()
	
	attach_script_to_sway_children("res://Scripts/Environment/sway.gd")
	toolTips.connect("ToolTipHid", Callable(self, "_on_tooltip_hidden"))
	waveManager.connect("wave1Started", Callable(self, "_on_wave_1_started"))
	waveManager.connect("wave2Started", Callable(self, "_on_wave_2_started"))
	waveManager.connect("wave3Started", Callable(self, "_on_wave_3_started"))

	Dialogic.timeline_ended.connect(finish_ready)
	Dialogic.start("res://Assets/Dialog/level_06_start_dialog.dtl")
		#
	#levelSwitcher.update_level(endScreen,endScreenAlt)
	#
	#Global.unHidePlantSelectionMenu()
	#plantSelectionMenu.canSwapScenes = true
	#start_game()
	
func finish_ready():
	print("Skipped Dialog")
	levelSwitcher.update_level(endScreen,endScreenAlt)
	Global.unHidePlantSelectionMenu()
	plantSelectionMenu.canSwapScenes = true
	
	
func getIsPurpleDimension():
	return 
	
	
func start_game():
	print("Game Is Starting")
	#show_all_plant_buttons()
	plantSelectionMenu.canSwapScenes = true
	#green_dimension = get_parent().get_node("Level03Alternate")
	#var possibleGreenDimension
	for node in get_parent().get_children():
		if node.has_method("getIsGreenDimension"):
			green_dimension = node
			print("Green D FOUND ")
	print("Green D is ", green_dimension)
	if waveManager.canStartGame == true:
		return
	
	waveManager.canStartGame = true
	green_dimension.start_game()
	gameStarted = true 
	
# Input filtering system - intercepts input based on tutorial state
func _input(event):
	match tutorial_state:
		TutorialState.TUTORIAL_P1_DONE:
			if !gameStarted:
				#start_game()
				show_all_plant_buttons()
				pass
		TutorialState.EXPLAIN_AMALGAM_ZOMBIE:
			if amalgamExplained:
				pass
			else:
				_start_explain_amalgam_zombie()

func setup_plant_selection_menu():
	pass
	plantSelectionMenu.get_node("PanelContainer/VBoxContainer/HBoxContainer/Maw").visible = true
	plantSelectionMenu.get_node("PanelContainer/VBoxContainer/HBoxContainer/WorldSwap").visible = true
	plantSelectionMenu.get_node("PanelContainer/VBoxContainer/HBoxContainer/RemovePlant").visible = true
	plantSelectionMenu.get_node("PanelContainer/VBoxContainer/HBoxContainer/Codex").visible = true
	plantSelectionMenu.get_node("PanelContainer/VBoxContainer/HBoxContainer/Sunflower").visible = true
	plantSelectionMenu.get_node("PanelContainer/VBoxContainer/HBoxContainer/Walnut").visible = true
	plantSelectionMenu.get_node("PanelContainer/VBoxContainer/HBoxContainer/Egg").visible = true
	plantSelectionMenu.get_node("PanelContainer/VBoxContainer/HBoxContainer/Hive").visible = true
	


# State transition system
func _transition_to_state(new_state: TutorialState):
	print("[Tutorial] Transition: ", TutorialState.keys()[tutorial_state], " → ", TutorialState.keys()[new_state])
	tutorial_state = new_state

	match new_state:
			#_start_explain_chimera()
		TutorialState.TUTORIAL_P2_DONE:
			toolTips._on_Button_pressed()
			
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
	
	
	
func _on_tooltip_hidden():
	hide_spotlight()
	print("########## TOOLTIP HIDDEN ##########")
	print("[Tutorial] Current state: ", TutorialState.keys()[tutorial_state])
	print("[Tutorial] Current time: ", Time.get_ticks_msec())
	match tutorial_state:
			
		TutorialState.EXPLAIN_AMALGAM_ZOMBIE:
			print("[Tutorial] amalgam explained")
			print("UNPPAUSE HERE")
			get_tree().paused = false  # Unpause game
			
func _on_wave_1_started():
	print("[Tutorial] Wave 1 started")
	_transition_to_state(TutorialState.EXPLAIN_AMALGAM_ZOMBIE)
	
	
func _on_wave_2_started():
	print("[Tutorial] Wave 2 started")


func _on_wave_3_started():
	print("[Tutorial] Wave 3 Started")



	




func _on_codex_button_pressed():
	print("[Tutorial] Codex button pressed in state: ", TutorialState.keys()[tutorial_state])
	_transition_to_state(TutorialState.TUTORIAL_P2_DONE)
	

	
	



func show_all_plant_buttons():
	# Show Sunflower
	plantSelectionMenu.get_node("PanelContainer/VBoxContainer/HBoxContainer/Sunflower/SunflowerButton").visible = true
	plantSelectionMenu.get_node("PanelContainer/VBoxContainer/HBoxContainer/Sunflower/SunFlowerLabel").visible = true

	# Show Spyder
	plantSelectionMenu.get_node("PanelContainer/VBoxContainer/HBoxContainer/Peashooter/PeashooterButton2").visible = true
	plantSelectionMenu.get_node("PanelContainer/VBoxContainer/HBoxContainer/Peashooter/PeashooterLabel").visible = true	

	#Show Walnut
	plantSelectionMenu.get_node("PanelContainer/VBoxContainer/HBoxContainer/Walnut/WalnutButton").visible = true
	plantSelectionMenu.get_node("PanelContainer/VBoxContainer/HBoxContainer/Walnut/WalnutLabel").visible = true	

	plantSelectionMenu.get_node("PanelContainer/VBoxContainer/HBoxContainer/Maw/MawButton").visible = true 
	plantSelectionMenu.get_node("PanelContainer/VBoxContainer/HBoxContainer/Maw/MawLabel").visible = true 
	
	plantSelectionMenu.get_node("PanelContainer/VBoxContainer/HBoxContainer/Egg/EggButton").visible = true
	plantSelectionMenu.get_node("PanelContainer/VBoxContainer/HBoxContainer/Egg/EggLabel").visible = true 

# Spotlight helper functions 	
func _start_explain_amalgam_zombie():
	amalgamExplained = true 
	print("[TUTORIAL] Start Explain amalgam Zombie")
	toolTips.setComplexSceneTextPause(TUTORIAL_EXPLAIN_AMALGAM)
	toolTips.setComplexScene(amalgam_zombie_demo_scene)
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
	
