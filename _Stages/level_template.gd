class_name LevelTemplate extends Control

var wave_1_active: bool = false
var wave_1_complete: bool = false
var wave2Started : bool = false 

var crawler_already_selected = false

var current_level = ("res://_Stages/Level1/Level0-1.tscn")
var current_level_alt = ("res://_Stages/Level1/Level0-1_Alternate.tscn")
var has_pulsed := false

@export var new_end_dialog = "res://_Assets/Dialog/level_0_end_dialog.dtl"
@export var wave2StartTime := 30
@export var wave3StartTime := 60

@onready var toolTips = $"../ToolTips"
@onready var demonManager = $DemonManager
@onready var demonSelectionMenu := $"../DemonSelectionMenu" 
#@onready var waveManager = $GameLayer/WaveManager
@onready var waveManager = get_parent().get_node("WaveManager")
@onready var spotlight_overlay = $"../SpotlightOverlay"  # Reference to CanvasLayer
@onready var pause_Button = $"../../PauseButton"
@onready var levelSwitcher = 	$"../LevelSwitcher"
@onready var _demon_hbox = demonSelectionMenu.get_node("PanelContainer/VBoxContainer/HBoxContainer")
@onready var world_swap_button = demonSelectionMenu.get_world_swap_button()
@onready var codex_button = demonSelectionMenu.get_codex_button()
@onready var sway_script_path := "res://_Common/EnvironmentScripts/sway.gd"

#@onready var green_dimension = Global.game_controller.get_alt_dimension()
var green_dimension 

# Text file paths
const TUTORIAL_SELECT_CRAWLER = "res://_Assets/Text/TextFiles/Level0_1_Tutorial_Selectcrawler.txt"
const TUTORIAL_PLACE_CRAWLER = "res://_Assets/Text/TextFiles/Level0_1_Tutorial_Placecrawler.txt"
const TUTORIAL_BLOOD_COST = "res://_Assets/Text/TextFiles/Level0_1_Tutorial_BloodCost.txt"
const TUTORIAL_PRESS_Y = "res://_Assets/Text/TextFiles/Level0_1_Tutorial_PressY.txt"
const TUTORIAL_GREEN_DIMENSION = "res://_Assets/Text/TextFiles/Level0_1_Tutorial_GreenDimension.txt"
const TUTORIAL_EXPLAIN_BASIC_ZOMBIE = "res://_Assets/Text/TextFiles/ZombieDescriptions/BaseZombieDescription.txt"
const TUTORIAL_EXPLAIN_SEVERED_ZOMBIE = "res://_Assets/Text/TextFiles/ZombieDescriptions/ConeHeadZombieDescription.txt"

const ALL_DEMON_CONTAINERS = ["Occulum", "SpinalOcculum", "Wyrm", "Maw", "Hive", "Crawler"] #,"Portal"]
const ALL_EXTRA_BUTTONS = []

func get_demon_manager():
	return demonManager


func _on_level_ended():
	#Dialogic.timeline_ended.connect(_on_end_dialog_finished, CONNECT_ONE_SHOT)
	#Dialogic.start(new_end_dialog)
	_on_end_dialog_finished()


func _on_end_dialog_finished():
	levelSwitcher.visible = true
	$"../ToolTips".visible = false
	get_tree().paused = true

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
	#setup_demon_selection_menu()
	#pause_Button.set_restart_levels(current_level,current_level_alt)
	#process_mode = Node.PROCESS_MODE_ALWAYS
	#
#
	#Global.resetOcculumCount()
	#Global.reset_swap_ability()
#
	## Connect signals
	#toolTips.connect("ToolTipHid", Callable(self, "_on_tooltip_hidden"))
## Hides all demon buttons except those in the exceptions array.
## Pass container names matching ALL_DEMON_CONTAINERS, e.g. ["Maw", "Occulum"]
func hide_all_demon_buttons_with_exception(exceptions: Array = []):
	print("Exceptions Are ",exceptions)
	for container_name in ALL_DEMON_CONTAINERS:
		if container_name in exceptions:
			pass
			#print(container_name , " is in ",exceptions )
		else:
			pass
			#print(container_name , " is not in ",exceptions )
		
		
		
		#print("container_name is ",container_name)
		#print("demon box is is ",_demon_hbox)
		if _demon_hbox.get_node(container_name) != null:
			var container = _demon_hbox.get_node(container_name)
			
			var should_show = container_name in exceptions
			#print(should_show, " container is IS ",container)
			container.visible = should_show
			for child in container.get_children():
				child.visible = should_show
 
 
## Shows all demon buttons and their parent containers.
## Optionally pass extra non-demon UI names to also show (e.g. "WorldSwap", "Codex").
func show_all_demon_buttons(extras: Array = []):
	for container_name in ALL_DEMON_CONTAINERS:
		if _demon_hbox.get_node(container_name) != null :
			var container = _demon_hbox.get_node(container_name)
			container.visible = true
			for child in container.get_children():
				child.visible = true
	for extra_name in extras:
		for button_instance in demonSelectionMenu.get_all_extra_buttons():
			if extra_name == button_instance.get_name():
				button_instance.visible = true

	
func setup_demon_selection_menu():
	pass
	
# Helper Methods
func make_camera_current():
	$Camera2D.make_current()

func place_empty_blocker_demon(grid_pos):
	demonManager.place_empty_blocker_demon(grid_pos)

func remove_empty_blocker_demon(grid_pos):
	demonManager.clear_space_alt(grid_pos)

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
	
func attach_script_to_sway_children():                                       #script_path: String) -> void:
	var coral_node = get_node("Environment/Coral")
	if coral_node == null:
		push_error("Coral node not found at Environment/Coral")
		return

	var script_to_attach = load(sway_script_path)
	if script_to_attach == null:
		push_error("Failed to load script at: " + sway_script_path)
		return

	for child in coral_node.get_children():
		child.set_script(script_to_attach)
		if child.is_inside_tree() and child.has_method("_ready"):
			child._ready()

func get_true_name():
	return ""
