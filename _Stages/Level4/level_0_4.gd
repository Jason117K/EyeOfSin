extends LevelTemplate
# level_0_4.gd - Level 0-4 Tutorial Controller

# Preloaded demo scenes
var summoner_zombie_demo_scene = preload("res://_UI/GameDemonstrations/ZombieTutorials/summoner_zombie_demo.tscn")

# Level paths
var thisLevel := "res://_Stages/Level4/Level0-4.tscn"
var thisAltLevel := "res://_Stages/Level4/Level0-4_Alternate.tscn"

var level05 = "res://_Stages/Level5/Level0-5.tscn"
var level05Alt = "res://_Stages/Level5/Level0-5_Alternate.tscn"

# Text file paths
const TUTORIAL_SELECT_WYRM = "res://_Assets/Text/TextFiles/Level0-4_Tutorial_SelectWyrm.txt"
const TUTORIAL_PLACE_WYRM = "res://_Assets/Text/TextFiles/Level0-4_Tutorial_PlaceWyrm.txt"
const TUTORIAL_EXPLAIN_SUMMONER = "res://_Assets/Text/TextFiles/ZombieDescriptions/dancerZombieDescription.txt"

# Demon button container names

# Cached button references
@onready var zombie_spawner_1 := $GameLayer/ZombieSpawner1
@onready var zombie_spawner_2 := $GameLayer/ZombieSpawner2
@onready var zombie_spawner_3 := $GameLayer/ZombieSpawner3
@onready var zombie_spawner_4 := $GameLayer/ZombieSpawner4
@onready var zombie_spawner_5 := $GameLayer/ZombieSpawner5
@onready var zombie_spawner_6 := $GameLayer/ZombieSpawner6
@onready var zombie_spawner_7 := $GameLayer/ZombieSpawner7
@onready var wyrm_button = demonSelectionMenu.get_wyrm_button()
@onready var hbox = demonSelectionMenu.get_node("PanelContainer/VBoxContainer/HBoxContainer")


#region Tutorial Step Definitions (sequential order — read top to bottom)
func _setup_tutorial():
	define_tutorial_steps([
		{
			"name": "FORCE_SELECT_WYRM",
			"enter": _start_force_select_wyrm,
			"input_filter": _filter_block_keyboard,
		},
		{
			"name": "FORCE_PLACE_WYRM",
			"enter": _start_force_place_wyrm,
			"input_filter": _filter_block_deselect,
		},
		{
			"name": "TUTORIAL_P1_DONE",
			"enter": _start_tutorial_p1_done,
		},
		{
			"name": "EXPLAIN_SUMMONER_ZOMBIE",
			"enter": _start_explain_summoner_zombie,
		},
	])
#endregion


#region Lifecycle
func _ready():
	super()
	waveManager = get_parent().get_node("WaveManager")
	#waveManager.wave_delays = [35.0, 45.0]
	waveManager.wave_delays = [wave2StartTime,wave3StartTime]
	waveManager.wave_started.connect(_on_wave_started)
	waveManager.level_ended.connect(_on_level_ended)
	_configure_waves()

	pause_Button.set_restart_levels(thisLevel, thisAltLevel)
	process_mode = Node.PROCESS_MODE_ALWAYS
	toolTips.set_basic_tutorial_text(TUTORIAL_SELECT_WYRM, false)
	
	Global.resetOcculumCount()
	attach_script_to_sway_children()

	# Connect signals
	toolTips.connect("ToolTipHid", Callable(self, "_on_tooltip_hidden"))
	demonManager.connect("wyrm_placed", Callable(self, "_on_wyrm_placed"))
	wyrm_button.connect("pressed", Callable(self, "_on_wyrm_button_pressed"))

	toolTips.hide()
	Dialogic.timeline_ended.connect(finish_ready)
	finish_ready()


func _configure_waves():
	pass
	zombie_spawner_1.set_waves_from_dicts([{ "Flesheater": 1, "Severed": 2}, {"Severed": 5, "Unhallower": 2}, {"Flesheater": 2, "Reborn": 3, "Unhallower": 2}])
	zombie_spawner_2.set_waves_from_dicts([{"Severed": 2}, {"Reanimator": 1, "Severed": 4, "Unhallower": 2}, {"Reborn": 6, "Unhallower": 2}])
	zombie_spawner_3.set_waves_from_dicts([{}, {"Reanimator": 1, "Reborn": 5, "Unhallower": 2}, {"Reanimator": 1, "Reborn": 5, "Severed": 3}])
	zombie_spawner_4.set_waves_from_dicts([{}, {"Reborn": 3, "Unhallower": 2}, {"Reanimator": 2, "Reborn": 1, "Unhallower": 3}])
	zombie_spawner_5.set_waves_from_dicts([{"Reborn": 2, "Unhallower": 2}, {"Reborn": 4, "Severed": 3}, {"Severed": 4, "Unhallower": 2}])
	zombie_spawner_6.set_waves_from_dicts([{"Reborn": 1, "Severed": 2}, {"Severed": 2, "Unhallower": 6}, {"Flesheater": 3, "Unhallower": 2}])
	zombie_spawner_7.set_waves_from_dicts([{}, {"Severed": 2}, {"Flesheater": 1, "Reanimator": 1, "Severed": 1, "Unhallower": 2}])


func finish_ready():
	toolTips.show()
	_setup_tutorial()
	go_to_step("FORCE_SELECT_WYRM")
	levelSwitcher.update_level(level05, level05Alt)
	levelSwitcher.update_current_level(thisLevel, thisAltLevel)
	levelSwitcher.visible = false
	Global.unHideDemonSelectionMenu()


func getIsPurpleDimension():
	return
#endregion


#region Input
func _input(event):
	_filter_tutorial_input(event)
#endregion


#region Step Entry Functions (same sequential order as definitions above)
func _start_force_select_wyrm():
	toolTips.set_basic_tutorial_text(TUTORIAL_SELECT_WYRM, false)
	hide_all_demon_buttons_with_exception(["Wyrm"])
	if has_pulsed == false:
		has_pulsed = true 
		demonSelectionMenu.add_pulsing_button_highlight(wyrm_button)
	waveManager.can_start = false
	demonSelectionMenu.canSwapScenes = false


func _start_force_place_wyrm():
	toolTips.set_basic_tutorial_text(TUTORIAL_PLACE_WYRM, false)
	
	#demonSelectionMenu.remove_button_highlight(wyrm_button)
	demonSelectionMenu.stop_glow_pulse(wyrm_button)
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


func _start_explain_summoner_zombie():
	toolTips.set_visual_tutorial_text(TUTORIAL_EXPLAIN_SUMMONER)
	toolTips.set_visual_tutorial_visual(summoner_zombie_demo_scene.instantiate())
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
		"FORCE_PLACE_WYRM":
			get_tree().paused = false

		"EXPLAIN_SUMMONER_ZOMBIE":
			get_tree().paused = false


func _on_wyrm_button_pressed():
	if get_current_step_name() == "FORCE_SELECT_WYRM":
		advance_tutorial() # → FORCE_PLACE_WYRM


func _on_wyrm_placed(_grid_pos: Vector2):
	if get_current_step_name() == "FORCE_PLACE_WYRM":
		advance_tutorial() # → TUTORIAL_P1_DONE


func _on_wave_started(wave_index: int):
	if wave_index == 1:
		go_to_step("EXPLAIN_SUMMONER_ZOMBIE")
#endregion


#region UI Helpers
func show_only_demon_buttons(visible_containers: Array):
	for container_name in ALL_DEMON_CONTAINERS:
		var container = hbox.get_node(container_name)
		var should_show = container_name in visible_containers
		for child in container.get_children():
			child.visible = should_show


func _show_all_buttons():
	hide_all_demon_buttons_with_exception(["Occulum", "Crawler", "SpinalOcculum", "Maw", "Wyrm"])
	# Also show non-demon UI
	#hbox.get_node("Occulum").visible = true
	#hbox.get_node("SpinalOcculum").visible = true
	#hbox.get_node("Maw").visible = true
	#hbox.get_node("WorldSwap").visible = true
	#hbox.get_node("Codex").visible = true


func remove_empty_blocker_demon(grid_pos):
	demonManager.clear_space_alt(grid_pos)


func show_guide():
	$GameLayer/GridManager/TileMapLayer.place_rectangles_on_rows(3, 9)
#endregion
