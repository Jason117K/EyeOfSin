extends Control
# level_0_1.gd - Level 0-1 Tutorial Controller
# Implements forced tutorial system with state machine and input filtering

enum TutorialState {
	INIT,
	FORCE_SELECT_SPYDER,
	FORCE_PLACE_PLANT,
	EXPLAIN_BLOOD_COST,
	WAVE_1_ACTIVE,
	FORCE_PRESS_Y,
	EXPLAIN_GREEN_DIMENSION,
	WAVE_2_ACTIVE,
	TUTORIAL_COMPLETE
}

var tutorial_state: TutorialState = TutorialState.INIT
var wave_1_active: bool = false
var wave_1_complete: bool = false

# Node references
@onready var toolTips = $ToolTips
@onready var plantManager = $PlantManager
@onready var plantSelectionMenu = $PlantSelectionMenu
@onready var waveManager = $GameLayer/WaveManager

# Text file paths
const TUTORIAL_SELECT_SPYDER = "res://Assets/Text/TextFiles/Level0_1_Tutorial_SelectSpyder.txt"
const TUTORIAL_PLACE_SPYDER = "res://Assets/Text/TextFiles/Level0_1_Tutorial_PlaceSpyder.txt"
const TUTORIAL_BLOOD_COST = "res://Assets/Text/TextFiles/Level0_1_Tutorial_BloodCost.txt"
const TUTORIAL_PRESS_Y = "res://Assets/Text/TextFiles/Level0_1_Tutorial_PressY.txt"
const TUTORIAL_GREEN_DIMENSION = "res://Assets/Text/TextFiles/Level0_1_Tutorial_GreenDimension.txt"


func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	Global.resetSunflowerCount()

	# Connect signals
	toolTips.connect("ToolTipHid", Callable(self, "_on_tooltip_hidden"))
	plantManager.connect("spyder_placed", Callable(self, "_on_spyder_placed"))
	waveManager.connect("wave1Started", Callable(self, "_on_wave_1_started"))

	# Connect to Spyder button directly
	var spyder_button = plantSelectionMenu.get_node("PanelContainer/VBoxContainer/HBoxContainer/Peashooter/PeashooterButton2")
	spyder_button.connect("pressed", Callable(self, "_on_spyder_button_pressed"))

	# Start tutorial
	_transition_to_state(TutorialState.FORCE_SELECT_SPYDER)


# Input filtering system - intercepts input based on tutorial state
func _input(event):
	match tutorial_state:
		TutorialState.FORCE_SELECT_SPYDER:
			_handle_force_select_spyder_input(event)

		TutorialState.FORCE_PLACE_PLANT:
			_handle_force_place_plant_input(event)

		TutorialState.FORCE_PRESS_Y:
			_handle_force_press_y_input(event)

		TutorialState.WAVE_1_ACTIVE:
			# Block Y key during Wave 1
			if event is InputEventKey and event.pressed:
				if event.keycode == KEY_Y:
					get_viewport().set_input_as_handled()

		# Other states allow normal input
		_:
			pass


func _handle_force_select_spyder_input(event):
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
			_start_force_select_spyder()
		TutorialState.FORCE_PLACE_PLANT:
			_start_force_place_plant()
		TutorialState.EXPLAIN_BLOOD_COST:
			_start_explain_blood_cost()
		TutorialState.WAVE_1_ACTIVE:
			_start_wave_1_purple_only()
		TutorialState.FORCE_PRESS_Y:
			_start_force_press_y()
		TutorialState.EXPLAIN_GREEN_DIMENSION:
			_start_explain_green_dimension()
		TutorialState.WAVE_2_ACTIVE:
			_start_wave_2_both_dimensions()


# State entry methods
func _start_force_select_spyder():
	toolTips.set_text(TUTORIAL_SELECT_SPYDER)
	toolTips.noButtonShow()

	hide_all_plant_buttons_except_spyder()
	highlight_spyder_button()

	waveManager.canStartGame = false
	plantSelectionMenu.canSwapScenes = false


func _start_force_place_plant():
	toolTips.set_text(TUTORIAL_PLACE_SPYDER)
	toolTips.noButtonShow()

	unhighlight_spyder_button()


func _start_explain_blood_cost():
	toolTips.set_text_pause(TUTORIAL_BLOOD_COST)
	toolTips.showButton()


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
	# Start Wave 2 in green dimension
	var green_dimension = get_parent().get_node("Level0-1_Alternate")
	if green_dimension and green_dimension.has_method("start_wave_2"):
		green_dimension.start_wave_2()

	# Start Wave 2 in purple dimension
	waveManager.startSecondWave()

	# Enable dimension swapping
	plantSelectionMenu.canSwapScenes = true

	tutorial_state = TutorialState.TUTORIAL_COMPLETE


# UI Control Methods
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


func show_all_plant_buttons():
	# For Level0-1 tutorial, only show Spyder
	# Other buttons remain hidden (this is a tutorial level)
	pass


func highlight_spyder_button():
	var button = plantSelectionMenu.get_node("PanelContainer/VBoxContainer/HBoxContainer/Peashooter/PeashooterButton2")
	plantSelectionMenu.add_button_highlight(button)


func unhighlight_spyder_button():
	var button = plantSelectionMenu.get_node("PanelContainer/VBoxContainer/HBoxContainer/Peashooter/PeashooterButton2")
	plantSelectionMenu.remove_button_highlight(button)


# Signal Handlers
func _on_tooltip_hidden():
	print("[Tutorial] ToolTip hidden in state: ", TutorialState.keys()[tutorial_state])
	match tutorial_state:
		TutorialState.EXPLAIN_BLOOD_COST:
			_transition_to_state(TutorialState.WAVE_1_ACTIVE)
		TutorialState.EXPLAIN_GREEN_DIMENSION:
			_transition_to_state(TutorialState.WAVE_2_ACTIVE)


func _on_spyder_placed():
	print("[Tutorial] Spyder placed in state: ", TutorialState.keys()[tutorial_state])
	if tutorial_state == TutorialState.FORCE_PLACE_PLANT:
		_transition_to_state(TutorialState.EXPLAIN_BLOOD_COST)


func _on_spyder_button_pressed():
	print("[Tutorial] Spyder button pressed in state: ", TutorialState.keys()[tutorial_state])
	if tutorial_state == TutorialState.FORCE_SELECT_SPYDER:
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
