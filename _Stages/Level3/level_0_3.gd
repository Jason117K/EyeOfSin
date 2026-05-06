extends LevelTemplate

enum TutorialState {
	FORCE_SELECT_MAW,
	FORCE_PLACE_MAW,
	EXPLAIN_CODEX,
	EXPLAIN_FLESHEATER_ZOMBIE,
	TUTORIAL_P1_DONE,
	TUTORIAL_P2_DONE
}

@onready var toolTips = $"../ToolTips"
@onready var plantManager = $PlantManager
@onready var plantSelectionMenu = $"../DemonSelectionMenu"
#@onready var waveManager = $GameLayer/WaveManager
var waveManager 
@onready var levelSwitcher = 	$"../LevelSwitcher"
@onready var spotlight_overlay = $"../SpotlightOverlay"  # Reference to CanvasLayer
@onready var green_dimension = $CurrentScene/Level03Alternate
@onready var pause_Button = $"../../PauseButton"

var thisLevel := "res://_Stages/Level3/Level0-3.tscn"
var thisAltLevel := "res://_Stages/Level3/Level0-3_Alternate.tscn"

var level04 = "res://_Stages/Level4/Level0-4.tscn"
var level04Alt = "res://_Stages/Level4/Level0-4_Alternate.tscn"
var tutorial_state: TutorialState = TutorialState.FORCE_SELECT_MAW
var fleshEaterExplained := false 
var wave2Started := false 
var fleshEater_zombie_demo_scene = preload("res://_UI/GameDemonstrations/ZombieTutorials/fleshEater_zombie_demo.tscn")

var level03 = "res://_Stages/Level3/Level0-3.tscn"
var level03Alt = "res://_Stages/Level3/Level0-3_Alternate.tscn"

const TUTORIAL_SELECT_MAW = "res://_Assets/Text/TextFiles/Level0-3_Tutorial_SelectMaw.txt"
const TUTORIAL_PLACE_MAW = "res://_Assets/Text/TextFiles/Level0-3_Tutorial_PlaceMaw.txt"
const TUTORIAL_EXPLAIN_FLESHEATER = "res://_Assets/Text/TextFiles/ZombieDescriptions/footBallZombieDescription.txt"
const TUTORIAL_SELECT_CODEX = "res://_Assets/Text/TextFiles/CodexSelectExplain.txt"
@export var new_end_dialog = "res://_Assets/Dialog/level_03_end_dialog.dtl"



func _ready():
	#Dialogic.Inputs.auto_skip.enabled = true 
	waveManager = get_parent().get_node("WaveManager")
	waveManager.set_dialog_end(new_end_dialog)
	waveManager.Wave2StartTime = 37
	waveManager.Wave3StartTime = 50

	setup_plant_selection_menu()
	pause_Button.set_restart_levels(level03,level03Alt)
	process_mode = Node.PROCESS_MODE_ALWAYS
	toolTips.set_text(TUTORIAL_SELECT_MAW)
	toolTips.noButtonShow()
	Global.resetSunflowerCount()
	Global.reset_swap_ability()
	
	
	toolTips.connect("ToolTipHid", Callable(self, "_on_tooltip_hidden"))
	waveManager.connect("wave1Started", Callable(self, "_on_wave_1_started"))
	waveManager.connect("wave2Started", Callable(self, "_on_wave_2_started"))
	waveManager.connect("wave3Started", Callable(self, "_on_wave_3_started"))
	plantManager.connect("maw_placed", Callable(self, "_on_maw_placed"))
	plantSelectionMenu.connect("codex_clicked", Callable(self, "_on_codex_button_pressed"))
	
	# Connect to button presses
	var maw_button = plantSelectionMenu.get_node("PanelContainer/VBoxContainer/HBoxContainer/Maw/MawButton")
	maw_button.connect("pressed", Callable(self, "_on_maw_button_pressed"))
	toolTips.hide()
	Dialogic.timeline_ended.connect(finish_ready)
	#Dialogic.start("res://Assets/Dialog/level_03_start_dialog.dtl")
	finish_ready()
	
	## Start tutorial
	#_transition_to_state(TutorialState.FORCE_SELECT_MAW)
	#
	#
	#levelSwitcher.update_level(level04,level04Alt)
	#
	#Global.unHidePlantSelectionMenu()

	
func finish_ready():
	print("Skipped Dialog")
	# Start tutorial
	toolTips.show()
	_transition_to_state(TutorialState.FORCE_SELECT_MAW)
	levelSwitcher.update_level(level04,level04Alt)
	levelSwitcher.update_current_level(thisLevel,thisAltLevel)
	Global.unHidePlantSelectionMenu()
	
	
func getIsPurpleDimension():
	return 

func start_game():
	print(self, " starting game")
	show_all_plant_buttons()
	#hide_Codex()
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
		TutorialState.FORCE_SELECT_MAW:
			_handle_force_select_maw_input(event)
		TutorialState.FORCE_PLACE_MAW:
			_start_force_place_maw()
		TutorialState.EXPLAIN_FLESHEATER_ZOMBIE:
			if fleshEaterExplained:
				pass
			else:
				_start_explain_fleshEater_zombie()
			#_start_explain_chimera()
		TutorialState.EXPLAIN_CODEX:
			pass
			#_start_explain_codex()

func setup_plant_selection_menu():
	pass
	plantSelectionMenu.get_node("PanelContainer/VBoxContainer/HBoxContainer/Maw").visible = true
	plantSelectionMenu.get_node("PanelContainer/VBoxContainer/HBoxContainer/WorldSwap").visible = true
	plantSelectionMenu.get_node("PanelContainer/VBoxContainer/HBoxContainer/RemovePlant").visible = true
	plantSelectionMenu.get_node("PanelContainer/VBoxContainer/HBoxContainer/Codex").visible = true
	

# State transition system
func _transition_to_state(new_state: TutorialState):
	print("[Tutorial] Transition: ", TutorialState.keys()[tutorial_state], " → ", TutorialState.keys()[new_state])
	tutorial_state = new_state

	match new_state:
		TutorialState.FORCE_SELECT_MAW:
			_start_force_select_maw()
		TutorialState.FORCE_PLACE_MAW:
			_start_force_place_maw()
		TutorialState.EXPLAIN_FLESHEATER_ZOMBIE:
			pass
			#_start_explain_chimera()
		TutorialState.EXPLAIN_CODEX:
			var codex_buton = plantSelectionMenu.get_node("PanelContainer/VBoxContainer/HBoxContainer/Codex/CodexButton")
			plantSelectionMenu.get_node("PanelContainer/VBoxContainer/HBoxContainer/Codex").visible = true 
			codex_buton.visible = true  
			_start_explain_codex()
		TutorialState.TUTORIAL_P2_DONE:
			toolTips._on_Button_pressed()
			

func _on_tooltip_hidden():
	hide_spotlight()
	print("########## TOOLTIP HIDDEN ##########")
	print("[Tutorial] Current state: ", TutorialState.keys()[tutorial_state])
	print("[Tutorial] Current time: ", Time.get_ticks_msec())
	match tutorial_state:
		TutorialState.FORCE_SELECT_MAW:
			pass
		TutorialState.FORCE_PLACE_MAW:
			print("UNPPAUSE HERE")
			get_tree().paused = false
		TutorialState.EXPLAIN_FLESHEATER_ZOMBIE:
			print("[Tutorial] FleshEater explained - waiting for Wave 2")
			print("UNPPAUSE HERE")
			get_tree().paused = false  # Unpause game

		TutorialState.EXPLAIN_CODEX:
			
			_start_explain_codex()	
	
	
func _on_wave_2_started():
	print("[Tutorial] Wave 2 started")
	_transition_to_state(TutorialState.EXPLAIN_FLESHEATER_ZOMBIE)

func _on_wave_3_started():
	print("[Tutorial] Wave 3 Started")
	_transition_to_state(TutorialState.EXPLAIN_CODEX)

	
func _start_explain_codex():
	toolTips.set_text(TUTORIAL_SELECT_CODEX)
	toolTips.noButtonShow()
	#Show spotlight on Codex button
	var codex_buton = plantSelectionMenu.get_node("PanelContainer/VBoxContainer/HBoxContainer/Codex/CodexButton")
	show_spotlight_at_node(codex_buton)
			
func _handle_force_select_maw_input(event):
	# Only allow clicking Maw button, block all keyboard input
	if event is InputEventKey:
		get_viewport().set_input_as_handled()
	# Mouse input: Maw button gets clicks via visibility, others hidden	
	
func _handle_force_place_maw_input(event):
	# Allow mouse clicks for placement, block X key (deselect)
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_X:
			get_viewport().set_input_as_handled()
			
func _start_force_select_maw():
	toolTips.set_text(TUTORIAL_SELECT_MAW)
	toolTips.noButtonShow()

	hide_all_plant_buttons_except_maw()
	highlight_maw_button()

	# ADD THIS: Show spotlight on Maw button
	var maw_button = plantSelectionMenu.get_node("PanelContainer/VBoxContainer/HBoxContainer/Maw/MawButton")
	show_spotlight_at_node(maw_button)

	waveManager.canStartGame = false
	plantSelectionMenu.canSwapScenes = false
	
func _start_force_place_maw():
	print("[Tutorial] Starting FORCE_PLACE_MAW")
	toolTips.set_text(TUTORIAL_PLACE_MAW)
	toolTips.noButtonShow()

	# Remove walnut highlight
	var maw_button = plantSelectionMenu.get_node("PanelContainer/VBoxContainer/HBoxContainer/Maw/MawButton")
	plantSelectionMenu.remove_button_highlight(maw_button)

	# Hide spotlight (grid too large)
	hide_spotlight()

func _on_maw_button_pressed():
	print("[Tutorial] Maw button pressed in state: ", TutorialState.keys()[tutorial_state])
	if tutorial_state == TutorialState.FORCE_SELECT_MAW:
		_transition_to_state(TutorialState.FORCE_PLACE_MAW)

func _on_codex_button_pressed():
	print("[Tutorial] Codex button pressed in state: ", TutorialState.keys()[tutorial_state])
	_transition_to_state(TutorialState.TUTORIAL_P2_DONE)
	

func _on_maw_placed(grid_pos: Vector2):
	print("[Tutorial] Maw placed at grid: ", grid_pos, " in state: ", TutorialState.keys()[tutorial_state])

	if tutorial_state == TutorialState.FORCE_PLACE_MAW:
		print("[Tutorial] Maw placement complete - tutorial initial part finished")
		toolTips.hide()
		_transition_to_state(TutorialState.TUTORIAL_P1_DONE)
		show_all_plant_buttons()
		plantSelectionMenu.canSwapScenes = true
		#start_game()
		# Tutorial complete - no further forced actions
		
func highlight_maw_button():
	var maw_button = plantSelectionMenu.get_node("PanelContainer/VBoxContainer/HBoxContainer/Maw/MawButton")
	plantSelectionMenu.add_button_highlight(maw_button)	
	
	
func hide_all_plant_buttons_except_maw():
	# Hide all buttons except Spyder
	plantSelectionMenu.get_node("PanelContainer/VBoxContainer/HBoxContainer/Sunflower/SunflowerButton").visible = false
	plantSelectionMenu.get_node("PanelContainer/VBoxContainer/HBoxContainer/Sunflower/SunFlowerLabel").visible = false

	plantSelectionMenu.get_node("PanelContainer/VBoxContainer/HBoxContainer/Walnut/WalnutButton").visible = false
	plantSelectionMenu.get_node("PanelContainer/VBoxContainer/HBoxContainer/Walnut/WalnutLabel").visible = false

	plantSelectionMenu.get_node("PanelContainer/VBoxContainer/HBoxContainer/Egg/EggButton").visible = false
	plantSelectionMenu.get_node("PanelContainer/VBoxContainer/HBoxContainer/Egg/EggLabel").visible = false
	
	plantSelectionMenu.get_node("PanelContainer/VBoxContainer/HBoxContainer/Peashooter/PeashooterButton2").visible = false
	plantSelectionMenu.get_node("PanelContainer/VBoxContainer/HBoxContainer/Peashooter/PeashooterLabel").visible = false
	
	

	plantSelectionMenu.get_node("PanelContainer/VBoxContainer/HBoxContainer/Hive/HiveButton").visible = false
	plantSelectionMenu.get_node("PanelContainer/VBoxContainer/HBoxContainer/Hive/HiveLabel").visible = false

	# Keep Maw visible
	plantSelectionMenu.get_node("PanelContainer/VBoxContainer/HBoxContainer/Maw/MawButton").visible = true
	plantSelectionMenu.get_node("PanelContainer/VBoxContainer/HBoxContainer/Maw/MawLabel").visible = true


func show_all_plant_buttons():
	# Show Sunflower
	plantSelectionMenu.get_node("PanelContainer/VBoxContainer/HBoxContainer/Sunflower/SunflowerButton").visible = true
	plantSelectionMenu.get_node("PanelContainer/VBoxContainer/HBoxContainer/Sunflower/SunFlowerLabel").visible = true
	plantSelectionMenu.get_node("PanelContainer/VBoxContainer/HBoxContainer/Sunflower").visible = true

	# Show Spyder
	plantSelectionMenu.get_node("PanelContainer/VBoxContainer/HBoxContainer/Peashooter/PeashooterButton2").visible = true
	plantSelectionMenu.get_node("PanelContainer/VBoxContainer/HBoxContainer/Peashooter/PeashooterLabel").visible = true	
	plantSelectionMenu.get_node("PanelContainer/VBoxContainer/HBoxContainer/Peashooter").visible = true	

	#Show Walnut
	plantSelectionMenu.get_node("PanelContainer/VBoxContainer/HBoxContainer/Walnut/WalnutButton").visible = true
	plantSelectionMenu.get_node("PanelContainer/VBoxContainer/HBoxContainer/Walnut/WalnutLabel").visible = true	
	plantSelectionMenu.get_node("PanelContainer/VBoxContainer/HBoxContainer/Walnut").visible = true	


# Spotlight helper functions 
func _start_explain_fleshEater_zombie():
	fleshEaterExplained = true 
	print("[TUTORIAL] Start Explain FleshEater Zombie")
	toolTips.setComplexSceneTextPause(TUTORIAL_EXPLAIN_FLESHEATER)
	toolTips.setComplexScene(fleshEater_zombie_demo_scene)
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

func hide_Codex():
	var codex_buton = plantSelectionMenu.get_node("PanelContainer/VBoxContainer/HBoxContainer/Codex/CodexButton")
	codex_buton.visible = false 
	

func place_empty_blocker_plant(grid_pos):
	plantManager.place_empty_blocker_plant(grid_pos)

func remove_empty_blocker_plant(grid_pos):
	plantManager.clear_space_alt(grid_pos)


func show_guide():
	$GameLayer/GridManager/TileMapLayer.place_rectangles_on_rows(2, 19)
	
func hide_guide():
	$GameLayer/GridManager/TileMapLayer.clear_rectangles()		
func get_health_ui():
	return $UILayer.get_the_health()
