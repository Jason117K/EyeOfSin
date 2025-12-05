extends Control
# level_0_2.gd - Level 0-2 Tutorial Controller
# Implements forced tutorial system with state machine and input filtering

enum TutorialState {
	INIT,
	FORCE_SELECT_SPYDER,
	FORCE_SELECT_SUNFLOWER,
	FORCE_PLACE_PLANT,
	EXPLAIN_BLOOD_COST,
	EXPLAIN_BLOOD_GENERATION,
	WAVE_1_ACTIVE,
	FORCE_PRESS_Y,
	EXPLAIN_GREEN_DIMENSION,
	WAVE_2_ACTIVE,
	TUTORIAL_COMPLETE
}

var tutorial_state: TutorialState = TutorialState.FORCE_SELECT_SUNFLOWER
var wave_1_active: bool = false
var wave_1_complete: bool = false

# Node references
#@onready var toolTips = $ToolTips
@onready var toolTips = $"../ToolTips"
@onready var plantManager = $PlantManager
@onready var plantSelectionMenu = $PlantSelectionMenu
@onready var waveManager = $GameLayer/WaveManager
@onready var spotlight_overlay = $"../SpotlightOverlay"  # Reference to CanvasLayer

# Text file paths
#const TUTORIAL_SELECT_SPYDER = "res://Assets/Text/TextFiles/Level0_1_Tutorial_SelectSpyder.txt"
const TUTORIAL_SELECT_SUNFLOWER = "res://Assets/Text/TextFiles/Level0_2_Tutorial_SelectSunflower.txt"
const TUTORIAL_PLACE_SPYDER = "res://Assets/Text/TextFiles/Level0_2_Tutorial_PlaceSunflower.txt"
const TUTORIAL_PLACE_SUNFLOWER = "res://Assets/Text/TextFiles/Level0_2_Tutorial_PlaceSunflower.txt"

const TUTORIAL_BLOOD_COST = "res://Assets/Text/TextFiles/Level0_1_Tutorial_BloodCost.txt"
const TUTORIAL_BLOOD_GEN = "res://Assets/Text/TextFiles/Level0_2_Tutorial_BloodGen.txt"
const TUTORIAL_PRESS_Y = "res://Assets/Text/TextFiles/Level0_1_Tutorial_PressY.txt"
const TUTORIAL_GREEN_DIMENSION = "res://Assets/Text/TextFiles/Level0_1_Tutorial_GreenDimension.txt"


func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	toolTips.set_text(TUTORIAL_SELECT_SUNFLOWER)
	toolTips.noButtonShow()
	Global.resetSunflowerCount()

	# Connect signals
	toolTips.connect("ToolTipHid", Callable(self, "_on_tooltip_hidden"))
	#plantManager.connect("spyder_placed", Callable(self, "_on_spyder_placed"))
	plantManager.connect("plant_placed", Callable(self, "_on_sunflower_placed"))
	waveManager.connect("wave1Started", Callable(self, "_on_wave_1_started"))

	# Connect to Spyder button directly
	#var spyder_button = plantSelectionMenu.get_node("PanelContainer/VBoxContainer/HBoxContainer/Peashooter/PeashooterButton2")
	#spyder_button.connect("pressed", Callable(self, "_on_spyder_button_pressed"))
	var sunflower_button = plantSelectionMenu.get_node("PanelContainer/VBoxContainer/HBoxContainer/Sunflower/SunflowerButton")
	sunflower_button.connect("pressed", Callable(self, "_on_sunflower_button_pressed"))
	# Start tutorial
	_transition_to_state(TutorialState.FORCE_SELECT_SUNFLOWER)
	#toolTips.connect("ToolTipHid",Callable(self, "_on_tooltip_hidden"))


# Input filtering system - intercepts input based on tutorial state
func _input(event):
	match tutorial_state:
		TutorialState.FORCE_SELECT_SUNFLOWER:
			_handle_force_select_sunflower_input(event)

		TutorialState.FORCE_PLACE_PLANT:
			_handle_force_place_plant_input(event)

		TutorialState.FORCE_PRESS_Y:
			_handle_force_press_y_input(event)

		# Other states allow normal input
		_:
			pass


func _handle_force_select_sunflower_input(event):
	# Only allow clicking Spyder button, block all keyboard input
	if event is InputEventKey:
		get_viewport().set_input_as_handled()
	# Mouse input: Spyder button gets clicks via visibility, others hidden


func _handle_force_place_plant_input(event):
	# Allow mouse clicks for placement, block X key (deselect) and Y key (swap)
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_X or event.keycode == KEY_Y:
			get_viewport().set_input_as_handled()


func _handle_force_press_y_input(event):
	# Only allow Y key
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_Y:
			# Swap to green dimension
			Global.game_controller.swap_scenes()
			# Transition to explanation state
			_transition_to_state(TutorialState.EXPLAIN_GREEN_DIMENSION)
			return
		else:
			get_viewport().set_input_as_handled()
	elif event is InputEventMouseButton:
		get_viewport().set_input_as_handled()


# State transition system
func _transition_to_state(new_state: TutorialState):
	print("[Tutorial] Transition: ", TutorialState.keys()[tutorial_state], " → ", TutorialState.keys()[new_state])
	tutorial_state = new_state

	match new_state:
		TutorialState.FORCE_SELECT_SPYDER:
			#_start_force_select_spyder()
			pass
		TutorialState.FORCE_SELECT_SUNFLOWER:
			_start_force_select_sunflower()
		TutorialState.FORCE_PLACE_PLANT:
			_start_force_place_plant()
		TutorialState.EXPLAIN_BLOOD_COST:
			_start_explain_blood_cost()
		TutorialState.EXPLAIN_BLOOD_GENERATION:
			_start_explain_blood_gen()
		TutorialState.WAVE_1_ACTIVE:
			_start_wave_1_purple_only()
		TutorialState.FORCE_PRESS_Y:
			_start_force_press_y()
		TutorialState.EXPLAIN_GREEN_DIMENSION:
			_start_explain_green_dimension()
		TutorialState.WAVE_2_ACTIVE:
			_start_wave_2_both_dimensions()


# State entry methods




func _start_explain_blood_cost():
	toolTips.set_text_pause(TUTORIAL_BLOOD_COST)
	toolTips.showButton()
		
	show_spotlight_at_position(Vector2(10,0))
	
func _start_explain_blood_gen():
	toolTips.set_text_pause(TUTORIAL_BLOOD_GEN)
	toolTips.showButton()
		
	show_spotlight_at_position(Vector2(10,0))

func _start_wave_1_purple_only():
	# Game unpauses when ToolTips button clicked
	waveManager.canStartGame = true
	show_all_plant_buttons()
	wave_1_active = false
	wave_1_complete = false


func _start_force_press_y():
	toolTips.set_text(TUTORIAL_PRESS_Y)
	toolTips.noButtonShow()


func _start_explain_green_dimension():
	# Brief delay for dimension swap visual
	#await get_tree().create_timer(0.5).timeout
	print("Tutorial Explain Green Dimension")
	toolTips.set_text_pause(TUTORIAL_GREEN_DIMENSION)
	toolTips.showButton()


func _start_wave_2_both_dimensions():
	print("========== PURPLE DIMENSION ACTIVATING WAVE 2 FOR BOTH ==========")
	print("[PURPLE] Current time: ", Time.get_ticks_msec())
	print("[PURPLE] waveManager.numWave BEFORE: ", waveManager.numWave)

	# Start Wave 2 in green dimension
	var green_dimension = get_parent().get_node("Level0-1_Alternate")
	print("[PURPLE] Green dimension node found: ", green_dimension != null)
	if green_dimension and green_dimension.has_method("start_wave_2"):
		print("[PURPLE] Calling green_dimension.start_wave_2()...")
		green_dimension.start_wave_2()
		print("[PURPLE] Green dimension start_wave_2() completed")
	else:
		print("[PURPLE] ERROR: Could not find green dimension or start_wave_2 method!")

	# CRITICAL: Spawners need to be at wave 2 to spawn wave2_zombies
	# Purple dimension completed Wave 1, so spawners are at 1
	# Need to increment once: 1→2
	print("[PURPLE] Incrementing spawner waves from 1 to 2...")
	for spawner in waveManager.spawners:
		print("[PURPLE] Spawner ", spawner.name, " numWave BEFORE: ", spawner.numWave)
		spawner.increase_wave()  # 1→2
		print("[PURPLE] Spawner ", spawner.name, " numWave AFTER: ", spawner.numWave)

	# Start Wave 2 in purple dimension
	print("[PURPLE] About to call waveManager.startSecondWave()...")
	waveManager.startSecondWave()
	print("[PURPLE] waveManager.numWave AFTER startSecondWave: ", waveManager.numWave)
	print("[PURPLE] waveManager.$Wave2.is_stopped(): ", waveManager.get_node("Wave2").is_stopped())

	# Enable dimension swapping
	plantSelectionMenu.canSwapScenes = true
	print("[PURPLE] Dimension swapping enabled")

	tutorial_state = TutorialState.TUTORIAL_COMPLETE
	print("========== PURPLE DIMENSION WAVE 2 ACTIVATION COMPLETED ==========")


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

func show_all_plant_buttons():
	# For Level0-1 tutorial, only show Spyder
	# Other buttons remain hidden (this is a tutorial level)
	pass


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
		TutorialState.EXPLAIN_BLOOD_COST:
			print("[Tutorial] Transitioning from EXPLAIN_BLOOD_COST to WAVE_1_ACTIVE")
			_transition_to_state(TutorialState.WAVE_1_ACTIVE)
		TutorialState.EXPLAIN_GREEN_DIMENSION:
			print("[Tutorial] Transitioning from EXPLAIN_GREEN_DIMENSION to WAVE_2_ACTIVE")
			_transition_to_state(TutorialState.WAVE_2_ACTIVE)

	print("########## TOOLTIP HIDDEN HANDLER COMPLETED ##########")


func _on_spyder_placed():
	print("[Tutorial] Spyder placed in state: ", TutorialState.keys()[tutorial_state])
	if tutorial_state == TutorialState.FORCE_PLACE_PLANT:
		_transition_to_state(TutorialState.EXPLAIN_BLOOD_COST)
		
func _on_sunflower_placed():
	print("[Tutorial] Eye placed in state: ", TutorialState.keys()[tutorial_state])
	if tutorial_state == TutorialState.FORCE_PLACE_PLANT:
		_transition_to_state(TutorialState.EXPLAIN_BLOOD_GENERATION)

func _on_sunflower_button_pressed():
	print("[Tutorial] Sunflower button pressed in state: ", TutorialState.keys()[tutorial_state])
	if tutorial_state == TutorialState.FORCE_SELECT_SUNFLOWER:
		_transition_to_state(TutorialState.FORCE_PLACE_PLANT)


func _on_wave_1_started():
	print("[Tutorial] Wave 1 started")
	wave_1_active = true


# Wave Completion Detection
func _physics_process(_delta):
	if tutorial_state == TutorialState.WAVE_1_ACTIVE and not wave_1_complete:
		# Check if all Wave 1 zombies are dead
		var alive_zombies = get_tree().get_nodes_in_group("Alive-Enemies")

		# Filter to only purple dimension zombies (not green)
		var purple_zombies = []
		for zombie in alive_zombies:
			if not zombie.is_in_group("Green"):
				purple_zombies.append(zombie)

		# If wave has started and all purple zombies are dead, advance
		if purple_zombies.size() == 0 and wave_1_active:
			print("[Tutorial] Wave 1 complete - all zombies dead")
			wave_1_complete = true
			_transition_to_state(TutorialState.FORCE_PRESS_Y)


# Helper Methods
func make_camera_current():
	$Camera2D.make_current()


func place_empty_blocker_plant(grid_pos):
	plantManager.place_empty_blocker_plant(grid_pos)


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
	show_spotlight_at_node(sunflower_button)

	waveManager.canStartGame = false
	plantSelectionMenu.canSwapScenes = false
	
	
func _start_force_place_plant():
	toolTips.set_text(TUTORIAL_PLACE_SUNFLOWER)
	toolTips.noButtonShow()

	unhighlight_spyder_button()

	# ADD THIS: Hide spotlight (grid too large for effective spotlight)
	hide_spotlight()
