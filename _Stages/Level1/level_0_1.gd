extends LevelTemplate

var basic_zombie_demo_scene = preload("res://_UI/GameDemonstrations/ZombieTutorials/basic_zombie_demo.tscn")
var severed_zombie_demo_scene = preload("res://_UI/GameDemonstrations/ZombieTutorials/severed_zombie_demo.tscn")
var wave_1_completed := false 
var current_completed_wave_number := 0 
var wave3StartTimer : Timer
@export var this_wave_3_start_time := 20

@onready var crawler_button = demonSelectionMenu.get_crawler_button()
@onready var zombie_spawner := $GameLayer/ZombieSpawner

const HIDEABLE_PLANT_NAMES = ["Sunflower", "Walnut", "Egg", "Maw", "Hive", "Heart", "Portal", "WorldSwap"]


#region Tutorial Step Definitions (sequential order — read top to bottom)
func _setup_tutorial():
	define_tutorial_steps([
		{
			"name": "FORCE_SELECT_SPYDER",
			"enter": _start_force_select_spyder,
			"input_filter": _filter_block_keyboard,
		},
		{
			"name": "FORCE_PLACE_PLANT",
			"enter": _start_force_place_plant,
			"input_filter": _filter_block_deselect_and_swap,
		},
		{
			"name": "EXPLAIN_BLOOD_COST",
			"enter": _start_explain_blood_cost,
		},
		{
			"name": "WAVE_1_ACTIVE",
			"enter": _start_wave_1,
			"input_filter": _filter_block_swap,
		},
		{
			"name": "EXPLAIN_BASIC_ZOMBIE",
			"enter": _start_explain_basic_zombie,
			"input_filter": _filter_block_swap,
		},
		{
			"name": "FORCE_PRESS_Y",
			"enter": _start_force_press_y,
			"input_filter": _filter_only_allow_y,
		},
		{
			"name": "EXPLAIN_GREEN_DIMENSION",
			"enter": _start_explain_green_dimension,
		},
		{
			"name": "WAVE_2_ACTIVE",
			"enter": _start_wave_2_both_dimensions,
		},
		{
			"name": "EXPLAIN_SEVERED_ZOMBIE",
			"enter": _start_explain_severed_zombie,
		},
	])
#endregion


#region Lifecycle
func _ready():
	Dialogic.Inputs.auto_skip.enabled = true
	Dialogic.timeline_ended.connect(finish_ready)

	Global.current_level = self
	Global.resetSunflowerCount()
	Global.reset_swap_ability()

	#waveManager.wave_delays = [-1, -1]
	waveManager.wave_delays = [wave2StartTime,wave3StartTime]
	waveManager.wave_started.connect(_on_wave_started)
	waveManager.level_ended.connect(_on_level_ended)
	_configure_waves()

	setup_plant_selection_menu()
	pause_Button.set_restart_levels(current_level, current_level_alt)
	process_mode = Node.PROCESS_MODE_ALWAYS

	toolTips.connect("ToolTipHid", Callable(self, "_on_tooltip_hidden"))
	toolTips.set_basic_tutorial_text(TUTORIAL_SELECT_SPYDER, false)

	plantManager.spyder_placed.connect(func(_grid_position): _on_spyder_placed())
	crawler_button.connect("pressed", Callable(self, "_on_spyder_button_pressed"))

	toolTips.hide()
	zombie_spawner.wave_exhausted.connect(wave_exhausted)
	waveManager.preview_lead_time = 8
	
	finish_ready()


func _configure_waves():
	zombie_spawner.set_waves_from_dicts([{"Reborn": 3}, {"Reborn": 5}, {"Reborn": 7}])


func finish_ready():
	_setup_tutorial()
	go_to_step("FORCE_SELECT_SPYDER")
	Global.unHideDemonSelectionMenu()

func wave_exhausted():
	wave_1_completed = true 

#endregion


#region Input
func _input(event):
	_filter_tutorial_input(event)
#endregion


#region Step Entry Functions (same sequential order as definitions above)
func _start_force_select_spyder():
	toolTips.set_basic_tutorial_text(TUTORIAL_SELECT_SPYDER, false)
	hide_all_demon_buttons_with_exception(["Crawler"])
	#hide_all_plant_buttons_except_spyder()
	highlight_spyder_button()
	waveManager.can_start = true
	demonSelectionMenu.canSwapScenes = false


func _start_force_place_plant():
	toolTips.set_basic_tutorial_text(TUTORIAL_PLACE_SPYDER, false)
	
	unhighlight_spyder_button()
	hide_spotlight()


func _start_explain_blood_cost():
	toolTips.set_basic_tutorial_text(TUTORIAL_BLOOD_COST, true)
	#TODO Add Highlight
	#show_spotlight_at_position(Vector2(10, 0))


func _start_wave_1():
	waveManager.can_start = true
	wave_1_active = false
	wave_1_complete = false


func start_game():
	_start_wave_1()


func _start_explain_basic_zombie():
	toolTips.set_visual_tutorial_text(TUTORIAL_EXPLAIN_BASIC_ZOMBIE)
	toolTips.set_visual_tutorial_visual(basic_zombie_demo_scene.instantiate())


func _start_force_press_y():
	demonSelectionMenu.get_world_swap_button().visible = true
	#demonSelectionMenu.get_node("PanelContainer/VBoxContainer/HBoxContainer/WorldSwap").visible = true
	toolTips.set_basic_tutorial_text(TUTORIAL_PRESS_Y, false)


func _start_explain_green_dimension():
	toolTips.set_basic_tutorial_text(TUTORIAL_GREEN_DIMENSION, true)


func _start_wave_2_both_dimensions():
	var green_dimension = get_parent().get_node("Level0-1_Alternate")
	if green_dimension and green_dimension.has_method("setup_wave_2_ui"):
		green_dimension.setup_wave_2_ui()

	waveManager.start_next_wave()
	demonSelectionMenu.canSwapScenes = true


func _start_explain_severed_zombie():
	toolTips.set_visual_tutorial_text(TUTORIAL_EXPLAIN_SEVERED_ZOMBIE)
	toolTips.set_visual_tutorial_visual(severed_zombie_demo_scene.instantiate())

#endregion


#region Input Filters
func _filter_block_keyboard(event: InputEvent):
	if event is InputEventKey:
		get_viewport().set_input_as_handled()


func _filter_block_deselect_and_swap(event: InputEvent):
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_X or event.keycode == KEY_Y:
			get_viewport().set_input_as_handled()


func _filter_block_swap(event: InputEvent):
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_Y:
			get_viewport().set_input_as_handled()


func _filter_only_allow_y(event: InputEvent):
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_Y:
			Global.swap_scenes()
			advance_tutorial() # → EXPLAIN_GREEN_DIMENSION
			return
		else:
			get_viewport().set_input_as_handled()
	elif event is InputEventMouseButton:
		get_viewport().set_input_as_handled()
#endregion


#region Signal Handlers
func _on_tooltip_hidden():
	print("Tooltip Was Hidden, Current Step is ", get_current_step_name() )
	hide_spotlight()
	match get_current_step_name():
		"EXPLAIN_BLOOD_COST":
			pass
			#go_to_step("WAVE_1_ACTIVE")
		"EXPLAIN_GREEN_DIMENSION":
			go_to_step("WAVE_2_ACTIVE")


func _on_spyder_placed():
	if get_current_step_name() == "FORCE_PLACE_PLANT":
		print("Advancing YTutorial Here from : ", get_current_step_name())
		advance_tutorial() # → EXPLAIN_BLOOD_COST


func _on_spyder_button_pressed():
	if get_current_step_name() == "FORCE_SELECT_SPYDER":
		print("Advancing WTutorial Here from : ", get_current_step_name())
		advance_tutorial() # → FORCE_PLACE_PLANT


func _on_wave_started(wave_index: int):
	match wave_index:
		0:
			wave_1_active = true
			advance_tutorial() # → EXPLAIN_BASIC_ZOMBIE
		2:
			go_to_step("EXPLAIN_SEVERED_ZOMBIE")


func _on_plant_manager_spyder_placed(_grid_position: Vector2) -> void:
	_on_spyder_placed()
#endregion


#region Wave Completion Detection
func _physics_process(_delta):
	var step_name = get_current_step_name()
	if step_name == "WAVE_1_ACTIVE" or step_name == "EXPLAIN_BASIC_ZOMBIE":
		if not wave_1_complete:
			var alive_zombies = get_tree().get_nodes_in_group("Alive-Enemies")

			var purple_zombies = []
			for zombie in alive_zombies:
				if not zombie.is_in_group("Green"):
					purple_zombies.append(zombie)
			if wave_1_completed :
				if purple_zombies.size() == 0 and wave_1_active:
					wave_1_complete = true
					go_to_step("FORCE_PRESS_Y")
#endregion


#region UI Helpers
func setup_plant_selection_menu():
	demonSelectionMenu.get_world_swap_button().visible = false
	demonSelectionMenu.get_remove_demon_button().visible = false 
	demonSelectionMenu.get_codex_button().visible = false 
	#TODO Should We Adjust Size Here?
	demonSelectionMenu.get_panel_container().size.x = 71


func highlight_spyder_button():
	demonSelectionMenu.add_pulsing_button_highlight(crawler_button)


func unhighlight_spyder_button():
	demonSelectionMenu.remove_button_highlight(crawler_button)
	demonSelectionMenu.stop_glow_pulse(crawler_button)


func show_guide():
	$GameLayer/GridManager/TileMapLayer.place_rectangles_on_rows(4, 4)
	
#endregion
