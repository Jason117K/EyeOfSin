class_name LevelTemplate extends Control

var wave_1_active: bool = false
var wave_1_complete: bool = false
var wave2Started : bool = false 

var spyder_already_selected = false

var current_level = ("res://_Stages/Level1/Level0-1.tscn")
var current_level_alt = ("res://_Stages/Level1/Level0-1_Alternate.tscn")


@export var new_end_dialog = "res://_Assets/Dialog/level_0_end_dialog.dtl"
@export var Wave2StartTime := 20
@export var Wave3StartTime := 30

@onready var toolTips = $"../ToolTips"
@onready var plantManager = $PlantManager
@onready var plantSelectionMenu = $"../DemonSelectionMenu" 
#@onready var waveManager = $GameLayer/WaveManager
@onready var waveManager = get_parent().get_node("WaveManager")
@onready var spotlight_overlay = $"../SpotlightOverlay"  # Reference to CanvasLayer
@onready var pause_Button = $"../../PauseButton"
@onready var levelSwitcher = 	$"../LevelSwitcher"
#@onready var green_dimension = Global.game_controller.get_alt_dimension()
var green_dimension 

# Text file paths
const TUTORIAL_SELECT_SPYDER = "res://_Assets/Text/TextFiles/Level0_1_Tutorial_SelectSpyder.txt"
const TUTORIAL_PLACE_SPYDER = "res://_Assets/Text/TextFiles/Level0_1_Tutorial_PlaceSpyder.txt"
const TUTORIAL_BLOOD_COST = "res://_Assets/Text/TextFiles/Level0_1_Tutorial_BloodCost.txt"
const TUTORIAL_PRESS_Y = "res://_Assets/Text/TextFiles/Level0_1_Tutorial_PressY.txt"
const TUTORIAL_GREEN_DIMENSION = "res://_Assets/Text/TextFiles/Level0_1_Tutorial_GreenDimension.txt"
const TUTORIAL_EXPLAIN_BASIC_ZOMBIE = "res://_Assets/Text/TextFiles/ZombieDescriptions/BaseZombieDescription.txt"
const TUTORIAL_EXPLAIN_SEVERED_ZOMBIE = "res://_Assets/Text/TextFiles/ZombieDescriptions/ConeHeadZombieDescription.txt"


func get_demon_manager():
	return plantManager

#TODO Refactor to Make Children Use Ready
#func _ready():
	#Dialogic.Inputs.auto_skip.enabled = true 
	#Global.current_level = self
	#waveManager.set_dialog_end(new_end_dialog)
	#
	##TODO Need Refactor
	#waveManager.Wave2StartTime = 20
	#waveManager.Wave3StartTime = 30
#
	#setup_plant_selection_menu()
	#pause_Button.set_restart_levels(current_level,current_level_alt)
	#process_mode = Node.PROCESS_MODE_ALWAYS
	#
#
	#Global.resetSunflowerCount()
	#Global.reset_swap_ability()
#
	## Connect signals
	#toolTips.connect("ToolTipHid", Callable(self, "_on_tooltip_hidden"))


	
func setup_plant_selection_menu():
	pass
	
# Helper Methods
func make_camera_current():
	$Camera2D.make_current()

func place_empty_blocker_plant(grid_pos):
	plantManager.place_empty_blocker_plant(grid_pos)

func remove_empty_blocker_plant(grid_pos):
	plantManager.clear_space_alt(grid_pos)

# Spotlight helper functions - ADD THESE NEW FUNCTIONS

## Shows spotlight centered on a Control node
func show_spotlight_at_node(target_node: Control, size_multiplier: float = 1.0):
	if not target_node or not spotlight_overlay:
		print("NOT SHOWING SPOTLIGHT")
		return
	print("Showing Spotlight At Node", target_node, size_multiplier)

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
	print("[SHOW SPOTLIGHT] Screen pos: ", screen_pos, " → UV: ", uv_pos, " Size: ", size)
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

	
func hide_guide():
	$GameLayer/GridManager/TileMapLayer.clear_rectangles()		

func get_health_ui():
	return $UILayer.get_the_health()
	
	
func get_game_layer():
	return $GameLayer
	
	
	
	
	
	
# ============================================================
# Tutorial Step System 
# ============================================================

var _tutorial_steps: Array[Dictionary] = []
var _current_step_index: int = -1


func define_tutorial_steps(steps: Array[Dictionary]) -> void:
	_tutorial_steps = steps


func advance_tutorial() -> void:
	go_to_step_index(_current_step_index + 1)


func go_to_step(step_name: String) -> void:
	for i in _tutorial_steps.size():
		if _tutorial_steps[i]["name"] == step_name:
			go_to_step_index(i)
			return
	push_warning("[Tutorial] Step not found: " + step_name)


func go_to_step_index(index: int) -> void:
	if index < 0 or index >= _tutorial_steps.size():
		push_warning("[Tutorial] Step index out of range: " + str(index))
		return
	var old_name = get_current_step_name()
	_current_step_index = index
	var step = _tutorial_steps[_current_step_index]
	print("[Tutorial] Transition: ", old_name, " → ", step["name"])
	if step.has("enter"):
		step["enter"].call()


func get_current_step_name() -> String:
	if _current_step_index >= 0 and _current_step_index < _tutorial_steps.size():
		return _tutorial_steps[_current_step_index]["name"]
	return "NONE"


func get_current_step() -> Dictionary:
	if _current_step_index >= 0 and _current_step_index < _tutorial_steps.size():
		return _tutorial_steps[_current_step_index]
	return {}


func _filter_tutorial_input(event: InputEvent) -> void:
	var step = get_current_step()
	if step.has("input_filter"):
		step["input_filter"].call(event)
	
	
