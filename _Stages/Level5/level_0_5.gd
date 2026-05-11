extends LevelTemplate
# level_0_5.gd - Level 0-5 Tutorial Controller

# Preloaded demo scenes
var erupter_zombie_demo_scene = preload("res://_UI/GameDemonstrations/ZombieTutorials/erupter_zombie_demo.tscn")
var lancer_zombie_demo_scene = preload("res://_UI/GameDemonstrations/ZombieTutorials/lancer_zombie_demo.tscn")

# Level paths
var thisLevel := "res://Scenes/LevelScenes/Level0-5.tscn"
var thisAltLevel := "res://Scenes/LevelScenes/Level0-5_Alternate.tscn"
var level05 = "res://Scenes/LevelScenes/Level0-5.tscn"
var level05Alt = "res://Scenes/LevelScenes/Level0-5_Alternate.tscn"
var level06 = "res://Scenes/LevelScenes/Level0-6.tscn"
var level06Alt = "res://Scenes/LevelScenes/Level0-6_Alternate.tscn"
var hive_pulse_added := false 

# Text file paths
const TUTORIAL_SELECT_HIVE = "res://_Assets/Text/TextFiles/Level0-5_Tutorial_SelectHive.txt"
const TUTORIAL_PLACE_HIVE = "res://_Assets/Text/TextFiles/Level0-5_Tutorial_PlaceHive.txt"
const TUTORIAL_EXPLAIN_ERUPTER = "res://_Assets/Text/TextFiles/ZombieDescriptions/tickerZombieDescription.txt"
const TUTORIAL_EXPLAIN_LANCER = "res://_Assets/Text/TextFiles/ZombieDescriptions/poleVaultZombieDescription.txt"


# Cached button references
@onready var zombie_spawner_1 := $GameLayer/ZombieSpawner1
@onready var zombie_spawner_2 := $GameLayer/ZombieSpawner2
@onready var zombie_spawner_3 := $GameLayer/ZombieSpawner3
@onready var zombie_spawner_4 := $GameLayer/ZombieSpawner4
@onready var zombie_spawner_5 := $GameLayer/ZombieSpawner5
@onready var zombie_spawner_6 := $GameLayer/ZombieSpawner6
@onready var zombie_spawner_7 := $GameLayer/ZombieSpawner7
@onready var hive_button = demonSelectionMenu.get_hive_button()
@onready var hbox = demonSelectionMenu.get_node("PanelContainer/VBoxContainer/HBoxContainer")


#region Tutorial Step Definitions (sequential order — read top to bottom)
func _setup_tutorial():
	define_tutorial_steps([
		{
			"name": "FORCE_SELECT_HIVE",
			"enter": _start_force_select_hive,
			"input_filter": _filter_block_keyboard,
		},
		{
			"name": "FORCE_PLACE_HIVE",
			"enter": _start_force_place_hive,
			"input_filter": _filter_block_deselect,
		},
		{
			"name": "TUTORIAL_P1_DONE",
			"enter": _start_tutorial_p1_done,
		},
		{
			"name": "EXPLAIN_LANCER_ZOMBIE",
			"enter": _start_explain_lancer_zombie,
		},
		{
			"name": "EXPLAIN_ERUPTER_ZOMBIE",
			"enter": _start_explain_erupter_zombie,
		},
	])
#endregion


#region Lifecycle
func _ready():
	Dialogic.Inputs.auto_skip.enabled = true
	waveManager = get_parent().get_node("WaveManager")
	#waveManager.wave_delays = [35.0, 45.0]
	waveManager.wave_delays = [wave2StartTime,wave3StartTime]
	waveManager.wave_started.connect(_on_wave_started)
	waveManager.level_ended.connect(_on_level_ended)
	_configure_waves()

	pause_Button.set_restart_levels(level05, level05Alt)
	process_mode = Node.PROCESS_MODE_ALWAYS
	toolTips.set_basic_tutorial_text(TUTORIAL_SELECT_HIVE, false)
	
	Global.resetSunflowerCount()
	attach_script_to_sway_children()

	# Connect signals
	toolTips.connect("ToolTipHid", Callable(self, "_on_tooltip_hidden"))
	plantManager.connect("wasp_placed", Callable(self, "_on_hive_placed"))
	hive_button.connect("pressed", Callable(self, "_on_hive_button_pressed"))

	toolTips.hide()
	Dialogic.timeline_ended.connect(finish_ready)
	finish_ready()


func _configure_waves():
	zombie_spawner_1.set_waves_from_dicts([{}, {"Erupter": 2, "Flesheater": 2, "Reanimator": 1, "Severed": 5}, {"Erupter": 1, "Flesheater": 2, "Reanimator": 1, "Severed": 2, "Unhallower": 1}])
	zombie_spawner_2.set_waves_from_dicts([{"Severed": 2, "Sundered": 3}, {"Erupter": 2, "Flesheater": 1, "Reborn": 1, "Severed": 2, "Sundered": 3, "Unhallower": 2}, {"Erupter": 3, "Flesheater": 1, "Sundered": 4, "Unhallower": 2}])
	zombie_spawner_3.set_waves_from_dicts([{"Reborn": 4, "Severed": 2, "Sundered": 1}, {"Erupter": 2, "Reborn": 6, "Severed": 2, "Sundered": 3}, {"Erupter": 4, "Reanimator": 1, "Reborn": 2, "Severed": 1, "Unhallower": 3}])
	zombie_spawner_4.set_waves_from_dicts([{"Flesheater": 1, "Reborn": 2, "Sundered": 3}, {"Severed": 3, "Sundered": 2, "Unhallower": 2}, {"Erupter": 3, "Reanimator": 1, "Reborn": 4, "Severed": 2, "Unhallower": 3}])
	zombie_spawner_5.set_waves_from_dicts([{}, {"Erupter": 2, "Flesheater": 1, "Severed": 2, "Unhallower": 4}, {"Reborn": 8, "Severed": 1, "Sundered": 3}])
	zombie_spawner_6.set_waves_from_dicts([{"Unhallower": 2}, {"Reanimator": 1, "Reborn": 5, "Unhallower": 2}, {"Flesheater": 3, "Severed": 6, "Sundered": 4, "Unhallower": 4}])
	zombie_spawner_7.set_waves_from_dicts([{}, {"Flesheater": 2, "Severed": 1}, {"Unhallower": 2}])


func finish_ready():
	toolTips.show()
	_setup_tutorial()
	go_to_step("FORCE_SELECT_HIVE")
	levelSwitcher.update_level(level06, level06Alt)
	levelSwitcher.update_current_level(thisLevel, thisAltLevel)
	Global.unHideDemonSelectionMenu()


func getIsPurpleDimension():
	return
#endregion


#region Input
func _input(event):
	_filter_tutorial_input(event)
#endregion


#region Step Entry Functions (same sequential order as definitions above)
func _start_force_select_hive():
	toolTips.set_basic_tutorial_text(TUTORIAL_SELECT_HIVE, false)
	
	show_only_plant_buttons(["Hive"])
	hide_all_demon_buttons_with_exception(["Hive"])
	#hbox.get_node("Hive").visible = true
	if hive_pulse_added == false:
		demonSelectionMenu.add_pulsing_button_highlight(hive_button)
		hive_pulse_added = true
	waveManager.can_start = false
	demonSelectionMenu.canSwapScenes = false


func _start_force_place_hive():
	toolTips.set_basic_tutorial_text(TUTORIAL_PLACE_HIVE,false)
	
#	demonSelectionMenu.remove_button_highlight(hive_button)
	demonSelectionMenu.stop_glow_pulse(hive_button)
	hide_spotlight()


func _start_tutorial_p1_done():
	toolTips.hide()
	_show_all_buttons()
	demonSelectionMenu.canSwapScenes = true


func start_game():
	for node in get_parent().get_children():
		if node.has_method("getIsGreenDimension"):
			green_dimension = node

	if waveManager.can_start:
		return

	_show_all_buttons()
	demonSelectionMenu.canSwapScenes = true
	waveManager.can_start = true
	green_dimension.start_game()


func _start_explain_lancer_zombie():
	toolTips.set_visual_tutorial_text(TUTORIAL_EXPLAIN_LANCER)
	toolTips.set_visual_tutorial_visual(lancer_zombie_demo_scene.instantiate())


func _start_explain_erupter_zombie():
	toolTips.set_visual_tutorial_text(TUTORIAL_EXPLAIN_ERUPTER)
	toolTips.set_visual_tutorial_visual(erupter_zombie_demo_scene.instantiate())
#endregion


#region Input Filters
func _filter_block_keyboard(event: InputEvent):
	if event is InputEventKey:
		get_viewport().set_input_as_handled()


func _filter_block_deselect(event: InputEvent):
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_X:
			get_viewport().set_input_as_handled()
#endregion


#region Signal Handlers
func _on_tooltip_hidden():
	hide_spotlight()

	match get_current_step_name():
		"FORCE_PLACE_HIVE":
			get_tree().paused = false

		"EXPLAIN_LANCER_ZOMBIE":
			get_tree().paused = false

		"EXPLAIN_ERUPTER_ZOMBIE":
			get_tree().paused = false


func _on_hive_button_pressed():
	if get_current_step_name() == "FORCE_SELECT_HIVE":
		advance_tutorial() # → FORCE_PLACE_HIVE


func _on_hive_placed(_grid_pos: Vector2):
	if get_current_step_name() == "FORCE_PLACE_HIVE":
		advance_tutorial() # → TUTORIAL_P1_DONE


func _on_wave_started(wave_index: int):
	match wave_index:
		0: go_to_step("EXPLAIN_LANCER_ZOMBIE")
		1: go_to_step("EXPLAIN_ERUPTER_ZOMBIE")
#endregion


#region UI Helpers
func show_only_plant_buttons(visible_containers: Array):
	for container_name in ALL_DEMON_CONTAINERS:
		var container = hbox.get_node(container_name)
		var should_show = container_name in visible_containers
		for child in container.get_children():
			child.visible = should_show


func _show_all_buttons():
	show_only_plant_buttons(ALL_DEMON_CONTAINERS)
	# Also show non-plant UI and parent containers
	for container_name in ALL_DEMON_CONTAINERS:
		hbox.get_node(container_name).visible = true
	world_swap_button.show()
	codex_button.show()


func show_guide():
	$GameLayer/GridManager/TileMapLayer.place_rectangles_on_rows(2, 8)
#endregion
