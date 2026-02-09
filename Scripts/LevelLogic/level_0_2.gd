extends Control
# level_0_2.gd - Level 0-2 Tutorial Controller
# Implements forced tutorial system with state machine and input filtering

enum TutorialState {
	FORCE_SELECT_SUNFLOWER,
	FORCE_SELECT_WALNUT,
	FORCE_PLACE_PLANT,
	FORCE_PLACE_WALNUT,
	EXPLAIN_BLOOD_GENERATION,
	FORCE_SELECT_SPYDER_AFTER_BLOOD,
	FORCE_PLACE_SPYDER_BEHIND,
	EXPLAIN_BLOOD_BUFFS,
	EXPLAIN_BLOOD_BUFFS_2,
	WAVE_1_ACTIVE,
	EXPLAIN_BUCKETHEAD_ZOMBIE
}

var tutorial_state: TutorialState = TutorialState.FORCE_SELECT_SUNFLOWER
var wave_1_active: bool = false
var wave_1_complete: bool = false

# Tutorial blood generation tracking
var tutorial_sunflower = null
var waiting_for_blood = false
var bucketHeadExplained = false
var sun_before_pickup = 0
var tutorial_sunflower_grid_pos: Vector2 = Vector2.ZERO
var tutorial_sun_instance: Node2D = null

# Node references
#@onready var toolTips = $ToolTips
@onready var toolTips = $"../ToolTips"
@onready var plantManager = $PlantManager
@onready var plantSelectionMenu = $"../PlantSelectionMenu" #$PlantSelectionMenu
#@onready var waveManager = $GameLayer/WaveManager
var waveManager 
@onready var levelSwitcher = 	$"../LevelSwitcher"
@onready var pause_Button = $"../PauseButton"

var level03 = "res://Scenes/LevelScenes/Level0-3.tscn"
var level03Alt = "res://Scenes/LevelScenes/Level0-3_Alternate.tscn"

var green_dimension
@onready var spotlight_overlay = $"../SpotlightOverlay"  # Reference to CanvasLayer

# Text file paths
const TUTORIAL_SELECT_SUNFLOWER = "res://Assets/Text/TextFiles/Level0_2_Tutorial_SelectSunflower.txt"
const TUTORIAL_PLACE_SUNFLOWER = "res://Assets/Text/TextFiles/Level0_2_Tutorial_PlaceSunflower.txt"
const TUTORIAL_PLACE_WALNUT = "res://Assets/Text/TextFiles/PlantDescriptions/WalnutDescription.txt"

const TUTORIAL_BLOOD_GEN = "res://Assets/Text/TextFiles/Level0_2_Tutorial_BloodGen.txt"
const TUTORIAL_SELECT_SPYDER_AFTER = "res://Assets/Text/TextFiles/Level0_2_Tutorial_SelectSpyder.txt"
const TUTORIAL_PLACE_SPYDER = "res://Assets/Text/TextFiles/Level0_2_Tutorial_PlaceSpyder.txt"
var tutorial_place_spyder =  "res://Assets/Text/TextFiles/Level0_2_Tutorial_PlaceSpyder.txt"

const TUTORIAL_BLOOD_BUFFS = "res://Assets/Text/TextFiles/Level0_2_Tutorial_BloodBuffs.txt"
const TUTORIAL_BLOOD_BUFFS_2 = "res://Assets/Text/TextFiles/Level0_2_Tutorial_BloodBuffs_2.txt"

const TUTORIAL_INVALID_SPYDER = "res://Assets/Text/TextFiles/Level0_2_Tutorial_InvalidSpyderPlacement.txt"
#const TUTORIAL_PRESS_Y = "res://Assets/Text/TextFiles/Level0_1_Tutorial_PressY.txt"
#const TUTORIAL_GREEN_DIMENSION = "res://Assets/Text/TextFiles/Level0_1_Tutorial_GreenDimension.txt"
const TUTORIAL_EXPLAIN_BUCKETHEAD_ZOMBIE = "res://Assets/Text/TextFiles/ZombieDescriptions/bucketHeadZombieDescription.txt"

var hive_egg_buff_scene = preload("res://Scenes/Tutorials/egg_spine_buff.tscn")
var spyder_sun_buff_scene = preload("res://Scenes/Tutorials/sunflower_spyder_buff.tscn")
var sun_spyder_buff_scene = preload("res://Scenes/Tutorials/spyder_sunflower_buff.tscn")
var buff_demo_scene = preload("res://Scenes/Tutorials/blood_buff_demo.tscn")
var buckethead_zombie_demo_scene = preload("res://Scenes/Tutorials/buckethead_zombie_demo.tscn")
var level02 = "res://Scenes/LevelScenes/Level0-2.tscn"
var level02Alt = "res://Scenes/LevelScenes/Level0-2_Alternate.tscn"
@export var new_end_dialog = "res://Assets/Dialog/level_02_end_dialog.dtl"

func _ready():
	#Dialogic.Inputs.auto_skip.enabled = true 
	levelSwitcher.visible = false
	plantSelectionMenu.visible = false
	print("UNPAUSE GAME")
	get_tree().paused = false
	waveManager = get_parent().get_node("WaveManager")
	waveManager.set_dialog_end(new_end_dialog)
	waveManager.Wave2StartTime = 35
	waveManager.Wave3StartTime = 55
	attach_script_to_sway_children("res://Scripts/Environment/sway.gd")
	
	setup_plant_selection_menu()
	pause_Button.set_restart_levels(level02,level02Alt)
	process_mode = Node.PROCESS_MODE_ALWAYS
	toolTips.set_text(TUTORIAL_SELECT_SUNFLOWER)
	toolTips.noButtonShow()
	Global.resetSunflowerCount()
	call_deferred("_find_green_dimension")

	# Connect signals
	toolTips.connect("ToolTipHid", Callable(self, "_on_tooltip_hidden"))
	plantManager.connect("plant_placed", Callable(self, "_on_sunflower_placed"))
	plantManager.connect("spyder_placed", Callable(self, "_on_spyder_placed"))
	plantManager.connect("walnut_placed", Callable(self, "_on_walnut_placed"))
	waveManager.connect("wave1Started", Callable(self, "_on_wave_1_started"))
	waveManager.connect("wave2Started", Callable(self, "_on_wave_2_started"))
	waveManager.connect("wave3Started", Callable(self, "_on_wave_3_started"))

	# Connect to button presses
	var sunflower_button = plantSelectionMenu.get_node("PanelContainer/VBoxContainer/HBoxContainer/Sunflower/SunflowerButton")
	sunflower_button.connect("pressed", Callable(self, "_on_sunflower_button_pressed"))

	var spyder_button = plantSelectionMenu.get_node("PanelContainer/VBoxContainer/HBoxContainer/Peashooter/PeashooterButton2")
	spyder_button.connect("pressed", Callable(self, "_on_spyder_button_pressed"))
	
	var walnut_button = plantSelectionMenu.get_node("PanelContainer/VBoxContainer/HBoxContainer/Walnut/WalnutButton")
	walnut_button.connect("pressed", Callable(self, "_on_walnut_button_pressed"))
	toolTips.hide()
	Dialogic.timeline_ended.connect(finish_ready)
	Dialogic.start("res://Assets/Dialog/level_02_start_dialog.dtl")
	
	# Start tutorial
	#_transition_to_state(TutorialState.FORCE_SELECT_SUNFLOWER)
	##toolTips.connect("ToolTipHid",Callable(self, "_on_tooltip_hidden"))
	#
	#levelSwitcher.update_level(level03,level03Alt)
	#
	#Global.unHidePlantSelectionMenu()

func _find_green_dimension():
	green_dimension = get_parent().get_node("Level0-2_Alternate")

func finish_ready():
	print("Skipped Dialog")
	toolTips.show()
	_transition_to_state(TutorialState.FORCE_SELECT_SUNFLOWER)
	#toolTips.connect("ToolTipHid",Callable(self, "_on_tooltip_hidden"))
	#levelSwitcher.visible = false
	levelSwitcher.update_level(level03,level03Alt)
	levelSwitcher.visible = false
	Global.unHidePlantSelectionMenu()
	
	
# Input filtering system - intercepts input based on tutorial state
func _input(event):
	match tutorial_state:
		TutorialState.FORCE_SELECT_WALNUT:
			_handle_force_select_walnut_input(event)
		TutorialState.FORCE_SELECT_SUNFLOWER:
			_handle_force_select_sunflower_input(event)

		TutorialState.FORCE_SELECT_SPYDER_AFTER_BLOOD:
			_handle_force_select_spyder_input(event)

		TutorialState.FORCE_PLACE_PLANT:
			_handle_force_place_plant_input(event)
		
		TutorialState.FORCE_PLACE_WALNUT:
			_handle_force_place_plant_input(event)

		TutorialState.FORCE_PLACE_SPYDER_BEHIND:
			_handle_force_place_spyder_input(event)
		TutorialState.EXPLAIN_BUCKETHEAD_ZOMBIE:
			if bucketHeadExplained:
				pass
			else:
				_start_explain_buckethead_zombie()

		# Other states allow normal input
		_:
			pass
func setup_plant_selection_menu():
	pass
	plantSelectionMenu.get_node("PanelContainer/VBoxContainer/HBoxContainer/Sunflower").visible = true
	
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
	
	
func _start_explain_buckethead_zombie():
	bucketHeadExplained = true 
	print("[TUTORIAL] Start Explain Buckethead Zombie")
	toolTips.setComplexSceneTextPause(TUTORIAL_EXPLAIN_BUCKETHEAD_ZOMBIE)
	toolTips.setComplexScene(buckethead_zombie_demo_scene)
	toolTips.showButton()	

func _handle_force_select_walnut_input(event):
	# Only allow clicking Walnut button, block all keyboard input
	if event is InputEventKey:
		get_viewport().set_input_as_handled()
	# Mouse input: Walnut button gets clicks via visibility, others hidden	

func _handle_force_select_sunflower_input(event):
	# Only allow clicking Spyder button, block all keyboard input
	if event is InputEventKey:
		get_viewport().set_input_as_handled()
	# Mouse input: Spyder button gets clicks via visibility, others hidden


func _handle_force_place_plant_input(event):
	# Allow mouse clicks for placement, block X key (deselect) and Y key (swap)
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_X: #or event.keycode == KEY_Y:
			get_viewport().set_input_as_handled()




func _handle_force_select_spyder_input(event):
	# Only allow clicking Spyder button, block all keyboard input
	if event is InputEventKey:
		get_viewport().set_input_as_handled()
	# Mouse input: Spyder button gets clicks via visibility, others hidden


func _handle_force_place_spyder_input(event):
	# Allow mouse clicks for placement, block X key (deselect)
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_X:
			get_viewport().set_input_as_handled()


# State transition system
func _transition_to_state(new_state: TutorialState):
	print("[Tutorial] Transition: ", TutorialState.keys()[tutorial_state], " → ", TutorialState.keys()[new_state])
	tutorial_state = new_state

	match new_state:
		TutorialState.FORCE_SELECT_SUNFLOWER:
			_start_force_select_sunflower()
		TutorialState.FORCE_SELECT_WALNUT:
			_start_force_select_walnut()
		TutorialState.FORCE_PLACE_PLANT:
			_start_force_place_plant()
		TutorialState.FORCE_PLACE_WALNUT:
			_start_force_place_walnut()
		TutorialState.EXPLAIN_BLOOD_GENERATION:
			_start_explain_blood_gen()
		TutorialState.FORCE_SELECT_SPYDER_AFTER_BLOOD:
			_start_force_select_spyder_after_blood()
		TutorialState.FORCE_PLACE_SPYDER_BEHIND:
			_start_force_place_spyder_behind()
		TutorialState.EXPLAIN_BLOOD_BUFFS:
			_start_explain_blood_buffs()
		TutorialState.EXPLAIN_BLOOD_BUFFS_2:
			_start_explain_blood_buffs_2()
		TutorialState.WAVE_1_ACTIVE:
			plantSelectionMenu.canSwapScenes = true
			pass
			#_start_wave_1()
			#green_dimension.start_game()


# State entry methods




func _start_explain_blood_gen():
	toolTips.set_text(TUTORIAL_BLOOD_GEN)  # Don't pause - let player collect blood
	toolTips.noButtonShow()  # No button - waits for blood pickup

	# Set up blood pickup detection
	waiting_for_blood = true
	sun_before_pickup = plantManager.sun_points
	print("[TUTORIAL] Waiting for blood pickup. Current sun: ", sun_before_pickup)

	# Optional: show spotlight at blood position if needed
	# show_spotlight_at_position(Vector2(10,0))


func start_game():
	_start_wave_1()
	
	
func _start_wave_1():
	print("Starting Wave 111")
	plantSelectionMenu.canSwapScenes = true
	# Game unpauses when ToolTips button clicked
	waveManager.canStartGame = true
	green_dimension.start_game()
	show_all_plant_buttons()
	wave_1_active = false
	wave_1_complete = false


func _start_force_select_walnut():
	print("[Tutorial] Starting FORCE_SELECT_WALNUT")
	toolTips.set_text(TUTORIAL_PLACE_WALNUT)
	toolTips.noButtonShow()

	# Hide all, show only Walnut
	hide_all_plant_buttons_except_walnut()
	highlight_walnut_button()

	# Spotlight on Walnut button
	var walnut_button = plantSelectionMenu.get_node("PanelContainer/VBoxContainer/HBoxContainer/Walnut/WalnutButton")
	show_spotlight_at_node(walnut_button)
	plantManager.add_sun(50.0) 
	green_dimension.add_sun(50.0) 

func _start_force_place_walnut():
	print("[Tutorial] Starting FORCE_PLACE_WALNUT")
	toolTips.set_text(TUTORIAL_PLACE_WALNUT)
	toolTips.noButtonShow()
	#plantManager.add_sun(50.0) 
	# Remove walnut highlight
	var walnut_button = plantSelectionMenu.get_node("PanelContainer/VBoxContainer/HBoxContainer/Walnut/WalnutButton")
	plantSelectionMenu.remove_button_highlight(walnut_button)

	# Hide spotlight (grid too large)
	hide_spotlight()


func _start_force_select_spyder_after_blood():
	print("[Tutorial] Starting FORCE_SELECT_SPYDER_AFTER_BLOOD")
	toolTips.set_text(TUTORIAL_SELECT_SPYDER_AFTER)
	toolTips.noButtonShow()

	# Hide Sunflower, show only Spyder
	hide_all_plant_buttons_except_spyder()
	highlight_spyder_button()

	# Spotlight on Spyder button
	var spyder_button = plantSelectionMenu.get_node("PanelContainer/VBoxContainer/HBoxContainer/Peashooter/PeashooterButton2")
	show_spotlight_at_node(spyder_button)

	# Keep game running
	waveManager.canStartGame = false
	plantSelectionMenu.canSwapScenes = false
	print("PAUSE GAME")
	get_tree().paused = true 


func _start_force_place_spyder_behind():
	print("[Tutorial] Starting FORCE_PLACE_SPYDER_BEHIND")
	#toolTips.set_text(TUTORIAL_PLACE_SPYDER)
	toolTips.setComplexSceneText(tutorial_place_spyder)
	toolTips.setComplexScene(buff_demo_scene)
	toolTips.noButtonShow()

	unhighlight_spyder_button()

	# Show spotlight on valid placement position (one cell left of sunflower)
	var valid_pos = tutorial_sunflower_grid_pos - Vector2(32, 0)
	show_spotlight_at_position(valid_pos, 0.12)


func _start_explain_blood_buffs():
	print("[Tutorial] Starting EXPLAIN_BLOOD_BUFFS")
	print("PAUSE GAME")
	get_tree().paused = true
	#toolTips.set_text_pause(TUTORIAL_BLOOD_BUFFS)
	toolTips.setComplexSceneText(TUTORIAL_BLOOD_BUFFS)
	toolTips.setComplexScene(spyder_sun_buff_scene)
	toolTips.showButton()
	
func _start_explain_blood_buffs_2():
	print("[Tutorial] Starting EXPLAIN_BLOOD_BUFFS_2")
	print("PAUSE GAME")
	get_tree().paused = true
	#toolTips.set_text_pause(TUTORIAL_BLOOD_BUFFS)
	toolTips.setComplexSceneText(TUTORIAL_BLOOD_BUFFS_2)
	toolTips.setComplexScene(sun_spyder_buff_scene)
	toolTips.showButton()



# UI Control Methods

func hide_all_plant_buttons_except_sunflower():
	# Hide all buttons except Spyder
	plantSelectionMenu.get_node("PanelContainer/VBoxContainer/HBoxContainer/Sunflower/SunflowerButton").visible = true
	plantSelectionMenu.get_node("PanelContainer/VBoxContainer/HBoxContainer/Sunflower/SunFlowerLabel").visible = true

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
	plantSelectionMenu.get_node("PanelContainer/VBoxContainer/HBoxContainer/Peashooter/PeashooterButton2").visible = false
	plantSelectionMenu.get_node("PanelContainer/VBoxContainer/HBoxContainer/Peashooter/PeashooterLabel").visible = false

func hide_all_plant_buttons_except_walnut():
	# Hide all buttons except Walnut
	plantSelectionMenu.get_node("PanelContainer/VBoxContainer/HBoxContainer/Sunflower/SunflowerButton").visible = false
	plantSelectionMenu.get_node("PanelContainer/VBoxContainer/HBoxContainer/Sunflower/SunFlowerLabel").visible = false

	plantSelectionMenu.get_node("PanelContainer/VBoxContainer/HBoxContainer/Walnut/WalnutButton").visible = true
	plantSelectionMenu.get_node("PanelContainer/VBoxContainer/HBoxContainer/Walnut/WalnutLabel").visible = true

	plantSelectionMenu.get_node("PanelContainer/VBoxContainer/HBoxContainer/Eye/EyeButton").visible = false
	plantSelectionMenu.get_node("PanelContainer/VBoxContainer/HBoxContainer/Eye/EyeLabel").visible = false

	plantSelectionMenu.get_node("PanelContainer/VBoxContainer/HBoxContainer/Egg/EggButton").visible = false
	plantSelectionMenu.get_node("PanelContainer/VBoxContainer/HBoxContainer/Egg/EggLabel").visible = false

	plantSelectionMenu.get_node("PanelContainer/VBoxContainer/HBoxContainer/Maw/MawButton").visible = false
	plantSelectionMenu.get_node("PanelContainer/VBoxContainer/HBoxContainer/Maw/MawLabel").visible = false

	plantSelectionMenu.get_node("PanelContainer/VBoxContainer/HBoxContainer/Hive/HiveButton").visible = false
	plantSelectionMenu.get_node("PanelContainer/VBoxContainer/HBoxContainer/Hive/HiveLabel").visible = false

	# Keep Walnut visible
	plantSelectionMenu.get_node("PanelContainer/VBoxContainer/HBoxContainer/Peashooter/PeashooterButton2").visible = false
	plantSelectionMenu.get_node("PanelContainer/VBoxContainer/HBoxContainer/Peashooter/PeashooterLabel").visible = false
	

func show_all_plant_buttons():
	# Show Sunflower
	plantSelectionMenu.get_node("PanelContainer/VBoxContainer/HBoxContainer/Sunflower/SunflowerButton").visible = true
	plantSelectionMenu.get_node("PanelContainer/VBoxContainer/HBoxContainer/Sunflower/SunFlowerLabel").visible = true

	# Show Spyder
	plantSelectionMenu.get_node("PanelContainer/VBoxContainer/HBoxContainer/Peashooter/PeashooterButton2").visible = true
	plantSelectionMenu.get_node("PanelContainer/VBoxContainer/HBoxContainer/Peashooter/PeashooterLabel").visible = true



func hide_all_plant_buttons_except_spyder():
	# Hide Sunflower
	plantSelectionMenu.get_node("PanelContainer/VBoxContainer/HBoxContainer/Sunflower/SunflowerButton").visible = false
	plantSelectionMenu.get_node("PanelContainer/VBoxContainer/HBoxContainer/Sunflower/SunFlowerLabel").visible = false

	# Show Spyder
	plantSelectionMenu.get_node("PanelContainer/VBoxContainer/HBoxContainer/Peashooter/PeashooterButton2").visible = true
	plantSelectionMenu.get_node("PanelContainer/VBoxContainer/HBoxContainer/Peashooter/PeashooterLabel").visible = true

	# Keep others hidden
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

func highlight_walnut_button():
	var button = plantSelectionMenu.get_node("PanelContainer/VBoxContainer/HBoxContainer/Walnut/WalnutButton")
	button.visible = true 
	plantSelectionMenu.get_node("PanelContainer/VBoxContainer/HBoxContainer/Walnut").visible = true 
	plantSelectionMenu.add_button_highlight(button)	

func highlight_spyder_button():
	var button = plantSelectionMenu.get_node("PanelContainer/VBoxContainer/HBoxContainer/Peashooter/PeashooterButton2")
	plantSelectionMenu.add_button_highlight(button)

func highlight_sunflower_button():
	var button = plantSelectionMenu.get_node("PanelContainer/VBoxContainer/HBoxContainer/Sunflower/SunflowerButton")
	plantSelectionMenu.add_button_highlight(button)

func unhighlight_spyder_button():
	var button = plantSelectionMenu.get_node("PanelContainer/VBoxContainer/HBoxContainer/Peashooter/PeashooterButton2")
	plantSelectionMenu.remove_button_highlight(button)

func unhighlight_sunflower_button():
	var button = plantSelectionMenu.get_node("PanelContainer/VBoxContainer/HBoxContainer/Sunflower/SunflowerButton")
	plantSelectionMenu.remove_button_highlight(button)

# Signal Handlers
func _on_tooltip_hidden():
	hide_spotlight()
	print("########## TOOLTIP HIDDEN ##########")
	print("[Tutorial] Current state: ", TutorialState.keys()[tutorial_state])
	print("[Tutorial] Current time: ", Time.get_ticks_msec())

	match tutorial_state:
		# EXPLAIN_BLOOD_GENERATION handled by blood pickup detection in _physics_process
		TutorialState.EXPLAIN_BLOOD_BUFFS:
			print("[Tutorial] Transitioning from EXPLAIN_BLOOD_BUFFS to EXPLAIN_BLOOD_BUFFS_2")
			print("UNPAUSE GAME")
			get_tree().paused = false  # Unpause game
			_transition_to_state(TutorialState.EXPLAIN_BLOOD_BUFFS_2)
		TutorialState.EXPLAIN_BLOOD_BUFFS_2:
			print("[Tutorial] Transitioning from EXPLAIN_BLOOD_BUFFS to WAVE_1_ACTIVE")
			print("UNPAUSE GAME")
			get_tree().paused = false  # Unpause game
			_transition_to_state(TutorialState.WAVE_1_ACTIVE)
			plantSelectionMenu.get_node("PanelContainer/VBoxContainer/HBoxContainer/WorldSwap").visible = true

		TutorialState.EXPLAIN_BUCKETHEAD_ZOMBIE:
			print("[Tutorial] Buckethead explained - waiting for Wave 3")
			print("UNPAUSE GAME")
			get_tree().paused = false  # Unpause game
			# No state transition - wait for wave3Started signal

		# Handle invalid placement error - return to placement state
		TutorialState.FORCE_PLACE_SPYDER_BEHIND:
			print("[Tutorial] Error acknowledged - returning to Spyder placement")
			print("UNPAUSE GAME")
			get_tree().paused = false
			# State already FORCE_PLACE_SPYDER_BEHIND - player can try again

	print("########## TOOLTIP HIDDEN HANDLER COMPLETED ##########")


func _on_spyder_placed(grid_pos: Vector2):
	print("[Tutorial] Spyder placed at grid: ", grid_pos, " in state: ", TutorialState.keys()[tutorial_state])

	if tutorial_state != TutorialState.FORCE_PLACE_SPYDER_BEHIND:
		return

	# Calculate expected position (one grid cell LEFT of sunflower)
	var expected_pos = tutorial_sunflower_grid_pos - Vector2(32, 0)
	print("[TUTORIAL] Expected Spyder position: ", expected_pos, " Actual: ", grid_pos)

	# Validate placement
	if grid_pos != expected_pos:
		print("[TUTORIAL] Invalid Spyder placement - deleting and showing error")
		# Wait for plant to enter tree
		await get_tree().create_timer(0.15).timeout

		# Delete the incorrectly placed Spyder (refunds cost automatically)
		plantManager.clear_space(grid_pos)
		plantManager.add_sun(50)

		# Show error message
		print("PAUSE GAME")
		get_tree().paused = true
		toolTips.set_text_pause(TUTORIAL_INVALID_SPYDER)
		toolTips.showButton()

		# Keep spotlight on valid position to guide retry
		show_spotlight_at_position(expected_pos, 0.12)
	else:
		print("[TUTORIAL] Valid Spyder placement - advancing to buff explanation")
		_transition_to_state(TutorialState.EXPLAIN_BLOOD_BUFFS)

func _on_walnut_placed(grid_pos: Vector2):
	print("[Tutorial] Walnut placed at grid: ", grid_pos, " in state: ", TutorialState.keys()[tutorial_state])

	if tutorial_state == TutorialState.FORCE_PLACE_WALNUT:
		print("[Tutorial] Walnut placement complete - tutorial finished")
		toolTips.hide()
		show_all_plant_buttons()
		# Tutorial complete - no further forced actions

func _on_sunflower_placed(grid_pos: Vector2):
	print("[Tutorial] Sunflower placed at grid: ", grid_pos, " in state: ", TutorialState.keys()[tutorial_state])
	if tutorial_state == TutorialState.FORCE_PLACE_PLANT:
		# Store grid position for Spyder placement validation
		tutorial_sunflower_grid_pos = grid_pos

		# Get the sunflower we just placed
		print("[TUTORIAL] Sunflower placed, waiting for instantiation...")
		await get_tree().create_timer(0.3).timeout

		# Find the sunflower instance from Plants group
		var sunflowers = get_tree().get_nodes_in_group("Plants")
		for plant in sunflowers:
			if "Sunflower" in plant.name:
				tutorial_sunflower = plant
				print("[TUTORIAL] Found tutorial sunflower: ", plant.name, " at grid: ", grid_pos)
				break

		# Force generate blood immediately and store reference
		if tutorial_sunflower and tutorial_sunflower.has_method("generate_sun"):
			print("[TUTORIAL] Forcing blood generation on ", tutorial_sunflower.name)
			tutorial_sun_instance = tutorial_sunflower.generate_sun()

			# Disable auto-pickup for tutorial blood
			if tutorial_sun_instance and tutorial_sun_instance.has_node("Auto_pick_up_timer"):
				tutorial_sun_instance.get_node("Auto_pick_up_timer").stop()
				print("[TUTORIAL] Disabled auto-pickup for tutorial blood")

			# Wait briefly for blood to enter scene tree, then spotlight it
			await get_tree().create_timer(0.15).timeout
			if tutorial_sun_instance:
				var sun_screen_pos = tutorial_sun_instance.global_position
				show_spotlight_at_position(sun_screen_pos, 0.12)
				print("[TUTORIAL] Spotlighting blood at: ", sun_screen_pos)
		else:
			print("[TUTORIAL ERROR] Could not find sunflower or generate_sun method!")

		# Transition to blood generation explanation
		_transition_to_state(TutorialState.EXPLAIN_BLOOD_GENERATION)

func _on_walnut_button_pressed():
	print("[Tutorial] Walnut button pressed in state: ", TutorialState.keys()[tutorial_state])
	if tutorial_state == TutorialState.FORCE_SELECT_WALNUT:
		_transition_to_state(TutorialState.FORCE_PLACE_WALNUT)
			
func _on_sunflower_button_pressed():
	print("[Tutorial] Sunflower button pressed in state: ", TutorialState.keys()[tutorial_state])
	if tutorial_state == TutorialState.FORCE_SELECT_SUNFLOWER:
		_transition_to_state(TutorialState.FORCE_PLACE_PLANT)


func _on_spyder_button_pressed():
	print("[Tutorial] Spyder button pressed in state: ", TutorialState.keys()[tutorial_state])
	if tutorial_state == TutorialState.FORCE_SELECT_SPYDER_AFTER_BLOOD:
		_transition_to_state(TutorialState.FORCE_PLACE_SPYDER_BEHIND)


func _on_wave_1_started():
	print("[Tutorial] Wave 1 started")
	show_all_plant_buttons()
	wave_1_active = true

func _on_wave_2_started():
	print("[Tutorial] Wave 2 started")
	_transition_to_state(TutorialState.EXPLAIN_BUCKETHEAD_ZOMBIE)

func _on_wave_3_started():
	print("[Tutorial] Wave 3 started")
	_transition_to_state(TutorialState.FORCE_SELECT_WALNUT)


# Wave Completion Detection
func _physics_process(_delta):
	# Check for blood pickup during tutorial
	if waiting_for_blood and plantManager.sun_points > sun_before_pickup:
		print("[TUTORIAL] Blood picked up! New sun: ", plantManager.sun_points)
		waiting_for_blood = false
		toolTips.hide()
		hide_spotlight()
		print("UNPAUSE GAME")
		get_tree().paused = false  # Ensure game is unpaused
		_transition_to_state(TutorialState.FORCE_SELECT_SPYDER_AFTER_BLOOD)




# Helper Methods
func make_camera_current():
	$Camera2D.make_current()


func place_empty_blocker_plant(grid_pos):
	plantManager.place_empty_blocker_plant(grid_pos)

func remove_empty_blocker_plant(grid_pos):
	plantManager.clear_space(grid_pos)

# Spotlight helper functions - ADD THESE NEW FUNCTIONS

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





func _start_force_select_sunflower():
	toolTips.set_text(TUTORIAL_SELECT_SUNFLOWER)
	toolTips.noButtonShow()

	hide_all_plant_buttons_except_sunflower()
	highlight_sunflower_button()

	# ADD THIS: Show spotlight on Sunflower button
	var sunflower_button = plantSelectionMenu.get_node("PanelContainer/VBoxContainer/HBoxContainer/Sunflower/SunflowerButton")
	sunflower_button.visible = true 
	show_spotlight_at_node(sunflower_button)

	waveManager.canStartGame = false
	plantSelectionMenu.canSwapScenes = false
	
	
func _start_force_place_plant():
	toolTips.set_text(TUTORIAL_PLACE_SUNFLOWER)
	toolTips.noButtonShow()

	unhighlight_spyder_button()

	# ADD THIS: Hide spotlight (grid too large for effective spotlight)
	hide_spotlight()


func show_guide():
	$GameLayer/GridManager/TileMapLayer.place_rectangles_on_rows(3, 5)
	
func hide_guide():
	$GameLayer/GridManager/TileMapLayer.clear_rectangles()		
