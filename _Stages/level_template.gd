class_name LevelTemplate extends Control

var wave_1_active: bool = false
var wave_1_complete: bool = false
var wave2Started: bool = false

var crawler_already_selected := false

var current_level := ("res://_Stages/Level1/Level0-1.tscn")
var current_level_alt := ("res://_Stages/Level1/Level0-1_Alternate.tscn")
var has_pulsed := false

@onready var level_title : String 

@export_category("Completion Time Thresholds")
@export var new_power_title : String 
@export var new_power_description : String 
@export var new_power_texture : Texture

@export var isGreenDimension := false
@export var new_end_dialog := "res://_Assets/Dialog/level_0_end_dialog.dtl"
@export var wave2StartTime := 30
@export var wave3StartTime := 60
@export var wave4StartTime := 75
@export var debug := true
@export var skip_tutorials := false  # true = skip all tutorial messages; level free-plays
@onready var toolTips := $ToolTips
@onready var demonManager := $DemonManager
@onready var demonSelectionMenu := $DemonSelectionMenu
#@onready var waveManager = $GameLayer/WaveManager
@onready var game_layer := $GameLayer
@onready var waveManager := get_parent().get_node("WaveManager")
#@onready var spotlight_overlay := $"../SpotlightOverlay"  # Reference to CanvasLayer
@onready var pause_Button :=$DemonSelectionMenu/UtilityPanelContainer/MarginContainer/UtilityVBoxContainer/HBoxContainer/PauseButton
@onready var levelSwitcher := $"../LevelSwitcher"
@onready var _demon_hbox := demonSelectionMenu.get_node("PanelContainer/MarginContainer/VBoxContainer/HBoxContainer")
@onready var world_swap_button :TextureButton= demonSelectionMenu.get_world_swap_button()
@onready var codex_button :TextureButton= demonSelectionMenu.get_codex_button()
@onready var sway_script_path := "res://_Common/EnvironmentScripts/sway.gd"

var progress_timer : Timer 

#@onready var green_dimension = Global.game_controller.get_alt_dimension()
var green_dimension : Node

var level_1_start_dialog := preload("res://_Assets/Dialog/level_0_start_dialog.dtl")
var level_2_start_dialog := preload("res://_Assets/Dialog/level_02_start_dialog.dtl")
var level_3_start_dialog := preload("res://_Assets/Dialog/level_03_start_dialog.dtl")
var level_4_start_dialog := preload("res://_Assets/Dialog/level_04_start_dialog.dtl")
var level_5_start_dialog := preload("res://_Assets/Dialog/level_05_start_dialog.dtl")
var level_6_start_dialog := preload("res://_Assets/Dialog/level_06_start_dialog.dtl")
var progress_count := 0

@export var progress_timer_wait_time : float = 5
@onready var og_progress_timer_wait_time := progress_timer_wait_time
var check_progress := false 
@export var skip_end_dialog := true

@export_category("Completion Time Thresholds")
@export var SSS_Rank_Completion_Time : int = 120 
@export var S_Rank_Completion_Time : int = 110
@export var A_Rank_Completion_Time : int = 100
@export var B_Rank_Completion_Time : int = 90
@export var C_Rank_Completion_Time : int = 80
@export var D_Rank_Completion_Time : int = 70

@onready var all_time_thresholds :Array[int] = [SSS_Rank_Completion_Time,S_Rank_Completion_Time,
	A_Rank_Completion_Time,B_Rank_Completion_Time,C_Rank_Completion_Time,D_Rank_Completion_Time]



@export_category("Style Point Thresholds")
@export var SSS_STYLE_POINTS_MIN := 2000
@export var S_STYLE_POINTS_MIN := 1500
@export var A_STYLE_POINTS_MIN := 1000
@export var B_STYLE_POINTS_MIN := 700
@export var C_STYLE_POINTS_MIN := 400
@export var D_STYLE_POINTS_MIN := 100

@onready var all_style_point_thresholds :Array[int] = [SSS_STYLE_POINTS_MIN,S_STYLE_POINTS_MIN,
	A_STYLE_POINTS_MIN,B_STYLE_POINTS_MIN,C_STYLE_POINTS_MIN,D_STYLE_POINTS_MIN]

@export_category("Total Score Thresholds")
@export var SSS_TOTAL_POINTS_MIN := 5000
@export var S_TOTAL_POINTS_MIN := 4000
@export var A_TOTAL_POINTS_MIN := 3000
@export var B_TOTAL_POINTS_MIN := 2000
@export var C_TOTAL_POINTS_MIN := 1000
@export var D_TOTAL_POINTS_MIN := 500

@onready var all_total_point_thresholds :Array[int] = [SSS_TOTAL_POINTS_MIN,S_TOTAL_POINTS_MIN,
	A_TOTAL_POINTS_MIN,B_TOTAL_POINTS_MIN,C_TOTAL_POINTS_MIN,D_TOTAL_POINTS_MIN]

@onready var new_power_unlock_rune := $AcquirePowerTexture
@onready var unlock_power := $UnlockPower
@onready var ui_layer := $UILayer

const TUTORIAL_SKULL_HOVER = "res://_Assets/Text/TextFiles/Tutorial_Explain_Skull_Hover.txt"
const TUTORIAL_EXPLAIN_SPINAL_OCCULUM = "res://_Assets/Text/TextFiles/DemonDescriptions/SpinalOcculumDescription.txt"
const TUTORIAL_SELECT_DEMON = "res://_Assets/Text/TextFiles/Tutorial_Select_Demon.txt"
const TUTORIAL_SELECT_WYRM = "res://_Assets/Text/TextFiles/DemonDescriptions/WyrmDescription.txt"
const TUTORIAL_EXPLAIN_WYRM = "res://_Assets/Text/TextFiles/DemonDescriptions/WyrmDescription.txt"
const TUTORIAL_EXPLAIN_OCCULUM = "res://_Assets/Text/TextFiles/DemonDescriptions/OcculumDescription.txt"
const TUTORIAL_SELECT_CRAWLER = "res://_Assets/Text/TextFiles/Level0_1_Tutorial_SelectCrawler.txt"
const TUTORIAL_PLACE_CRAWLER = "res://_Assets/Text/TextFiles/Level0_1_Tutorial_PlaceCrawler.txt"
const TUTORIAL_BLOOD_COST = "res://_Assets/Text/TextFiles/Level0_1_Tutorial_BloodCost.txt"
const TUTORIAL_CLICK_SKULL = "res://_Assets/Text/TextFiles/Tutorial_Click_Skull.txt"
const TUTORIAL_PRESS_Y = "res://_Assets/Text/TextFiles/Level0_1_Tutorial_PressY.txt"
const TUTORIAL_GREEN_DIMENSION = "res://_Assets/Text/TextFiles/Level0_1_Tutorial_GreenDimension.txt"
const TUTORIAL_EXPLAIN_BASIC_ZOMBIE = "res://_Assets/Text/TextFiles/ZombieDescriptions/BaseZombieDescription.txt"
const TUTORIAL_EXPLAIN_SEVERED_ZOMBIE = "res://_Assets/Text/TextFiles/ZombieDescriptions/ConeHeadZombieDescription.txt"
const TUTORIAL_SELECT_OCCULUM = "res://_Assets/Text/TextFiles/Level0_2_Tutorial_SelectOcculum.txt"
const TUTORIAL_PLACE_OCCULUM = "res://_Assets/Text/TextFiles/Level0_2_Tutorial_PlaceOcculum.txt"
const TUTORIAL_EXPLAIN_HEALTH = "res://_Assets/Text/TextFiles/Tutorial_Explain_Health.txt"
const TUTORIAL_DEMON_HOVER = "res://_Assets/Text/TextFiles/Tutorial_Explain_Demon_Hover_Click.txt"
const TUTORIAL_DEMON_CLICK = "res://_Assets/Text/TextFiles/Tutorial_Explain_Demon_Click.txt"

const TUTORIAL_PLACE_SPINALOCCULUM = "res://_Assets/Text/TextFiles/DemonDescriptions/SpinalOcculumDescription.txt"
const TUTORIAL_BLOOD_GEN = "res://_Assets/Text/TextFiles/Level0_2_Tutorial_BloodGen.txt"
const TUTORIAL_SELECT_CRAWLER_AFTER = "res://_Assets/Text/TextFiles/Level0_2_Tutorial_SelectCrawler.txt"
const TUTORIAL_BLOOD_BUFFS = "res://_Assets/Text/TextFiles/Level0_2_Tutorial_BloodBuffs.txt"
const TUTORIAL_BLOOD_BUFFS_2 = "res://_Assets/Text/TextFiles/Level0_2_Tutorial_BloodBuffs_2.txt"
const TUTORIAL_BLOOD_BUFFS_3 = "res://_Assets/Text/TextFiles/Level0_2_Tutorial_BloodBuffs_3.txt"
const TUTORIAL_BLOOD_BUFFS_4 = "res://_Assets/Text/TextFiles/Level0_2_Tutorial_BloodBuffs_4.txt"
const TUTORIAL_BLOOD_BUFFS_5 = "res://_Assets/Text/TextFiles/Level0_2_Tutorial_BloodBuffs_5.txt"

const TUTORIAL_INVALID_CRAWLER = "res://_Assets/Text/TextFiles/Level0_2_Tutorial_InvalidCrawlerPlacement.txt"
const TUTORIAL_EXPLAIN_BUCKETHEAD_ZOMBIE = "res://_Assets/Text/TextFiles/ZombieDescriptions/bucketHeadZombieDescription.txt"

const TUTORIAL_EXPLAIN_PRE_PLACED_LVL2 = "res://_Assets/Text/TextFiles/Tutorial_Explain_PrePlaced_Spinal_Occulum.txt"

const TUTORIAL_EXPLAIN_WAVES = "res://_Assets/Text/TextFiles/Tutorial_Explain_Waves.txt"
const TUTORIAL_SELECT_MAW = "res://_Assets/Text/TextFiles/Level0-3_Tutorial_SelectMaw.txt"
const TUTORIAL_PLACE_MAW = "res://_Assets/Text/TextFiles/Level0-3_Tutorial_PlaceMaw.txt"
const TUTORIAL_EXPLAIN_FLESHEATER = "res://_Assets/Text/TextFiles/ZombieDescriptions/footBallZombieDescription.txt"
const TUTORIAL_SELECT_CODEX = "res://_Assets/Text/TextFiles/CodexSelectExplain.txt"
const TUTORIAL_SPINAL_OCCULUM_UNLOCKED = "res://_Assets/Text/TextFiles/Tutorial_Spinal_Occulum_Unlocked.txt"

const ALL_DEMON_CONTAINERS : Array [String]= ["Occulum", "SpinalOcculum", "Wyrm", "Maw", "Hive", "Crawler","Portal"]
const ALL_EXTRA_BUTTONS = []

var auto_advance : bool = false 

var total_game_time : float = 0 

var new_power_unlocked := true 

@onready var extended_new_power_description : String

func _ready() -> void:
	Global.adjust_ui_layer()
	Global.reset_all_variables()
	
	waveManager.level_ended.connect(_on_level_ended)
	
	if new_power_texture != null:
		new_power_unlock_rune.set_new_power_texture(new_power_texture)
		unlock_power.set_new_power_texture(new_power_texture)
		new_power_unlock_rune.set_new_power_title(new_power_title)
		unlock_power.set_new_power_title(new_power_title)
		new_power_unlock_rune.set_new_power_description(new_power_description)
		unlock_power.set_new_power_description(extended_new_power_description)
	unlock_power.hide()
	new_power_unlock_rune.hide()

func demon_clicked()->void:
	pass 
	
func demon_hover()->void:
	pass
	
func get_demon_manager()->Node:
	return demonManager

func show_demon_selection_menu()->void:
	#print("About to Show D Select Menu ", demonSelectionMenu)
	demonSelectionMenu.show()

func hide_demon_selection_menu()->void:
	#print("About to Hide D Select Menu ", demonSelectionMenu)
	demonSelectionMenu.hide()
	#demonSelectionMenu.visible = false
	#demonSelectionMenu.self_modulate = Color(1,1,1,0)

func show_new_demon()->void:
	unlock_power.show()
	
func _on_level_ended() -> void:
	if isGreenDimension:
		if Global.game_controller.get_active_dimension() != Global.game_controller.get_green_dimension():
			print("Ended On Purple Early Return From Green")
			return
	elif !isGreenDimension:
		if Global.game_controller.get_active_dimension() != Global.game_controller.get_purple_dimension():
			print("Ended on Green Early Return From Purple")
			return
	print(self, " isGreen is:", isGreenDimension, " should show score then card")
	handle_score()

	
	#if skip_end_dialog:
		#_on_end_dialog_finished()
	#else:
		#Dialogic.timeline_ended.connect(_on_end_dialog_finished, CONNECT_ONE_SHOT)
		#Dialogic.start(new_end_dialog)
	#_on_end_dialog_finished()


	
	
func handle_score()->void:
	ScoreManager.set_completion_times(all_time_thresholds)
	
	Global.style_menu.set_level_title(level_title)
	Global.style_menu.set_completion_times(all_time_thresholds)
	Global.style_menu.set_style_point_thresholds(all_style_point_thresholds)
	Global.style_menu.set_total_point_thresholds(all_total_point_thresholds)
	
	ScoreManager.calc_completion_time_rank(total_game_time)
	ScoreManager.level_ended.emit()
	
	var wait_for_demon_points_timer :Timer = Timer.new()
	wait_for_demon_points_timer.autostart = false
	wait_for_demon_points_timer.one_shot = true
	wait_for_demon_points_timer.wait_time = 0.3
	wait_for_demon_points_timer.timeout.connect(handle_new_power_unlock)
	add_child(wait_for_demon_points_timer)
	wait_for_demon_points_timer.start()
	
func handle_new_power_unlock()->void:
	Global.style_menu._setup_score()
	if !new_power_unlocked:
		finish_end_level()
	new_power_unlock_rune.unlock_done.connect(show_new_demon)
	new_power_unlock_rune.activate()
	new_power_unlock_rune.process_mode = Node.PROCESS_MODE_ALWAYS
	unlock_power.process_mode = Node.PROCESS_MODE_ALWAYS
	#levelSwitcher.visible = true
	toolTips.visible = false
	get_tree().paused = true
	
	
func finish_end_level()->void:
	toolTips.visible = false
	levelSwitcher.visible = true
	await get_tree().physics_frame
	await get_tree().physics_frame
	await get_tree().physics_frame
	get_tree().paused = true


func _on_end_dialog_finished() -> void:
	print(isGreenDimension, "-------------Style Menu Visible--------------", self)
	if isGreenDimension:
		return
	else:
		handle_score()
	
	#style_menu.visible = true 
	#levelSwitcher.visible = true
	
	
func _process(delta: float) -> void:
	total_game_time += delta
	if check_progress:

		progress_timer_wait_time -= delta

		if progress_timer_wait_time <= 0:
			print("Call Progress Time Passed")
			
			progress_timer_wait_time = og_progress_timer_wait_time
			check_progress = false
			print("Time Up", check_progress)
			progress_time_passed()
	
func set_auto_advance_toolTip(new_progress_wait_time:float)->void:
	progress_timer_wait_time = new_progress_wait_time
	og_progress_timer_wait_time = new_progress_wait_time
	check_progress = true 
		
	
func show_zombie_tutorial(unlocked_zombie:String)->void:
	pass

func get_green_dimension():
	return Global.game_controller.get_green_dimension()	
	
func progress_time_passed()->void:
	if auto_advance:
		advance_tutorial()

## Hides all demon buttons except those in the exceptions array.
## Pass container names matching ALL_DEMON_CONTAINERS, e.g. ["Maw", "Occulum"]
func hide_all_demon_buttons_with_exception(exceptions: Array = []) -> void:
	#print("Exceptions Are ",exceptions)
	for container_name:String in ALL_DEMON_CONTAINERS:
		if container_name in exceptions:
			pass
			#print(container_name , " is in ",exceptions )
		else:
			pass
			#print(container_name , " is not in ",exceptions )
		
		
		
		#print("container_name is ",container_name)
		#print("demon box is is ",_demon_hbox)
		if _demon_hbox.get_node(container_name) != null:
			var container := _demon_hbox.get_node(container_name)

			var should_show :bool= container_name in exceptions
			#print(should_show, " container is IS ",container)
			container.visible = should_show
			for child in container.get_children():
				child.visible = should_show
	demonSelectionMenu.reset_panel_size()
 
 
## Shows all demon buttons and their parent containers.
## Optionally pass extra non-demon UI names to also show (e.g. "WorldSwap", "Codex").
func show_all_demon_buttons(extras: Array = []) -> void:
	for container_name:String in ALL_DEMON_CONTAINERS:
		if _demon_hbox.get_node(container_name) != null:
			var container := _demon_hbox.get_node(container_name)
			container.visible = true
			for child in container.get_children():
				child.visible = true
	for extra_name:String in extras:
		for button_instance:TextureButton in demonSelectionMenu.get_all_extra_buttons():
			if extra_name == button_instance.get_name():
				button_instance.visible = true

	
func setup_demon_selection_menu() -> void:
	pass

## Levels override this to set up normal play when skip_tutorials is true.
func _start_free_play() -> void:
	pass

# Helper Methods
func make_camera_current() -> void:
	$Camera2D.make_current()

func place_empty_blocker_demon(grid_pos:Vector2,empty_demon_to_place:Demon) -> void:
	print("Calling Demon Manager Place Empty From Level ", self)
	demonManager.place_empty_blocker_demon(grid_pos,empty_demon_to_place)

func click_pause_button()->void:
	pause_Button._on_pressed()
	
func remove_empty_blocker_demon(grid_pos:Vector2) -> void:
	demonManager.clear_space_alt(grid_pos)



func show_unlock_zombie_button(new_zombie_unlock:String)->void:
	pass

func hide_guide() -> void:
	$GameLayer/GridManager/TileMapLayer.clear_rectangles()

func get_health_ui()->Control:
	return $UILayer.get_the_health()


func get_game_layer()->Node:
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
	var old_name := get_current_step_name()
	_current_step_index = index
	var step := _tutorial_steps[_current_step_index]
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
	var step := get_current_step()
	if step.has("input_filter"):
		step["input_filter"].call(event)
	
func attach_script_to_sway_children(_make_green : bool = false) -> void:                                       #script_path: String) -> void:
	var coral_node := get_node("Environment/Coral")
	#print("Should Attach Scripts to Children of ", coral_node)
	if coral_node == null:
		push_error("Coral node not found at Environment/Coral")
		return

	var script_to_attach := load(sway_script_path)
	if script_to_attach == null:
		push_error("Failed to load script at: " + sway_script_path)
		return

	for child in coral_node.get_children():
		child.set_script(script_to_attach)
		if child.is_inside_tree() and child.has_method("_ready"):
			child._ready()
			#print(child, " is ready has attached ", script_to_attach)
			#if make_green:
				#child.make_green()

func get_true_name() -> String:
	return ""


func _filter_block_keyboard(event: InputEvent) -> void:
	if event is InputEventKey:
		get_viewport().set_input_as_handled()


func _filter_block_deselect_and_swap(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_X or event.keycode == KEY_Y:
			get_viewport().set_input_as_handled()


func _filter_block_swap(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_Y:
			get_viewport().set_input_as_handled()


func _filter_only_allow_y(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_Y:
			Global.swap_scenes()
			print("Advancing Tutorial Should Explian Green")
			advance_tutorial() # → EXPLAIN_GREEN_DIMENSION
			return
		else:
			get_viewport().set_input_as_handled()
	elif event is InputEventMouseButton:
		get_viewport().set_input_as_handled()
