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

# Text file paths
const TUTORIAL_SELECT_HIVE = "res://_Assets/Text/TextFiles/Level0-5_Tutorial_SelectHive.txt"
const TUTORIAL_PLACE_HIVE = "res://_Assets/Text/TextFiles/Level0-5_Tutorial_PlaceHive.txt"
const TUTORIAL_EXPLAIN_ERUPTER = "res://_Assets/Text/TextFiles/ZombieDescriptions/tickerZombieDescription.txt"
const TUTORIAL_EXPLAIN_LANCER = "res://_Assets/Text/TextFiles/ZombieDescriptions/poleVaultZombieDescription.txt"

# Plant button container names
const ALL_PLANT_CONTAINERS = ["Sunflower", "Walnut", "Egg", "Maw", "Hive", "Peashooter"]

# Cached button references
@onready var hive_button = plantSelectionMenu.get_node("PanelContainer/VBoxContainer/HBoxContainer/Hive/HiveButton")
@onready var hbox = plantSelectionMenu.get_node("PanelContainer/VBoxContainer/HBoxContainer")


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
	waveManager.set_dialog_end(new_end_dialog)
	waveManager.Wave2StartTime = 35
	waveManager.Wave3StartTime = 45

	pause_Button.set_restart_levels(level05, level05Alt)
	process_mode = Node.PROCESS_MODE_ALWAYS
	toolTips.set_text(TUTORIAL_SELECT_HIVE)
	toolTips.noButtonShow()
	Global.resetSunflowerCount()
	attach_script_to_sway_children("res://Scripts/Environment/sway.gd")

	# Connect signals
	toolTips.connect("ToolTipHid", Callable(self, "_on_tooltip_hidden"))
	waveManager.connect("wave1Started", Callable(self, "_on_wave_1_started"))
	waveManager.connect("wave2Started", Callable(self, "_on_wave_2_started"))
	plantManager.connect("wasp_placed", Callable(self, "_on_hive_placed"))
	hive_button.connect("pressed", Callable(self, "_on_hive_button_pressed"))

	toolTips.hide()
	Dialogic.timeline_ended.connect(finish_ready)
	finish_ready()


func finish_ready():
	toolTips.show()
	_setup_tutorial()
	go_to_step("FORCE_SELECT_HIVE")
	levelSwitcher.update_level(level06, level06Alt)
	levelSwitcher.update_current_level(thisLevel, thisAltLevel)
	Global.unHidePlantSelectionMenu()


func getIsPurpleDimension():
	return
#endregion


#region Input
func _input(event):
	_filter_tutorial_input(event)
#endregion


#region Step Entry Functions (same sequential order as definitions above)
func _start_force_select_hive():
	toolTips.set_text(TUTORIAL_SELECT_HIVE)
	toolTips.noButtonShow()
	show_only_plant_buttons(["Hive"])
	hbox.get_node("Hive").visible = true
	plantSelectionMenu.add_pulsing_button_highlight(hive_button)
	waveManager.canStartGame = false
	plantSelectionMenu.canSwapScenes = false


func _start_force_place_hive():
	toolTips.set_text(TUTORIAL_PLACE_HIVE)
	toolTips.noButtonShow()
	plantSelectionMenu.remove_button_highlight(hive_button)
	hide_spotlight()


func _start_tutorial_p1_done():
	toolTips.hide()
	_show_all_buttons()
	plantSelectionMenu.canSwapScenes = true


func start_game():
	for node in get_parent().get_children():
		if node.has_method("getIsGreenDimension"):
			green_dimension = node

	if waveManager.canStartGame:
		return

	_show_all_buttons()
	plantSelectionMenu.canSwapScenes = true
	waveManager.canStartGame = true
	green_dimension.start_game()


func _start_explain_lancer_zombie():
	toolTips.setComplexSceneTextPause(TUTORIAL_EXPLAIN_LANCER)
	toolTips.setComplexScene(lancer_zombie_demo_scene)
	toolTips.showButton()


func _start_explain_erupter_zombie():
	toolTips.setComplexSceneTextPause(TUTORIAL_EXPLAIN_ERUPTER)
	toolTips.setComplexScene(erupter_zombie_demo_scene)
	toolTips.showButton()
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


func _on_wave_1_started():
	go_to_step("EXPLAIN_LANCER_ZOMBIE")


func _on_wave_2_started():
	go_to_step("EXPLAIN_ERUPTER_ZOMBIE")
#endregion


#region UI Helpers
func show_only_plant_buttons(visible_containers: Array):
	for container_name in ALL_PLANT_CONTAINERS:
		var container = hbox.get_node(container_name)
		var should_show = container_name in visible_containers
		for child in container.get_children():
			child.visible = should_show


func _show_all_buttons():
	show_only_plant_buttons(ALL_PLANT_CONTAINERS)
	# Also show non-plant UI and parent containers
	for container_name in ALL_PLANT_CONTAINERS:
		hbox.get_node(container_name).visible = true
	hbox.get_node("WorldSwap").visible = true
	hbox.get_node("Codex").visible = true


func show_guide():
	$GameLayer/GridManager/TileMapLayer.place_rectangles_on_rows(2, 8)
#endregion
