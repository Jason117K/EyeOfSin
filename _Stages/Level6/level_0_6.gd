extends LevelTemplate
# level_0_6.gd - Level 0-6 Controller (no forced plant tutorial, just zombie explanation)

# Preloaded demo scenes
var amalgam_zombie_demo_scene = preload("res://_UI/GameDemonstrations/ZombieTutorials/amalgam_zombie_demo.tscn")

# Level paths
var thisLevel := "res://_Stages/Level6/Level0-6.tscn"
var thisAltLevel := "res://_Stages/Level6/Level0-6_Alternate.tscn"

var endScreen = "res://_Stages/EndScreen/EndScreen.tscn"
var endScreenAlt = "res://_Stages/EndScreen/EndScreen.tscn"

# Text file paths
const TUTORIAL_EXPLAIN_AMALGAM = "res://_Assets/Text/TextFiles/ZombieDescriptions/ScreenDoorZombieDescription.txt"

# Cached references
@onready var zombie_spawner_1 := $GameLayer/ZombieSpawner1
@onready var zombie_spawner_2 := $GameLayer/ZombieSpawner2
@onready var zombie_spawner_3 := $GameLayer/ZombieSpawner3
@onready var zombie_spawner_4 := $GameLayer/ZombieSpawner4
@onready var zombie_spawner_5 := $GameLayer/ZombieSpawner5
@onready var zombie_spawner_6 := $GameLayer/ZombieSpawner6
@onready var zombie_spawner_7 := $GameLayer/ZombieSpawner7
@onready var hbox = demonSelectionMenu.get_node("PanelContainer/VBoxContainer/HBoxContainer")


var gameStarted := false


#region Tutorial Step Definitions
func _setup_tutorial():
	define_tutorial_steps([
		{
			"name": "GAME_READY",
			"enter": _start_game_ready,
		},
		{
			"name": "EXPLAIN_AMALGAM_ZOMBIE",
			"enter": _start_explain_amalgam_zombie,
		},
	])
#endregion


#region Lifecycle
func _ready():
	waveManager = get_parent().get_node("WaveManager")
	#waveManager.wave_delays = [60.0, 100.0]
	waveManager.wave_delays = [wave2StartTime,wave3StartTime]
	waveManager.wave_started.connect(_on_wave_started)
	waveManager.level_ended.connect(_on_level_ended)
	_configure_waves()

	setup_plant_selection_menu()
	pause_Button.set_restart_levels(thisLevel, thisAltLevel)
	process_mode = Node.PROCESS_MODE_ALWAYS
	Global.resetSunflowerCount()
	attach_script_to_sway_children()

	# Connect signals
	toolTips.connect("ToolTipHid", Callable(self, "_on_tooltip_hidden"))

	Dialogic.timeline_ended.connect(finish_ready)
	finish_ready()


func _configure_waves():
	pass
	#zombie_spawner_1.set_waves_from_dicts([{"Amalgam": 1, "Erupter": 3, "Flesheater": 2, "Reborn": 1, "Severed": 1, "Unhallower": 8}, {"Flesheater": 2, "Reanimator": 1, "Reborn": 11, "Severed": 5, "Unhallower": 3}, {"Erupter": 3, "Flesheater": 3, "Reborn": 8, "Severed": 7, "Sundered": 4, "Unhallower": 5}])
	#zombie_spawner_2.set_waves_from_dicts([{"Erupter": 2, "Flesheater": 1, "Reanimator": 1, "Reborn": 1, "Severed": 3, "Unhallower": 4}, {"Erupter": 3, "Flesheater": 1, "Severed": 1, "Unhallower": 6}, {"Flesheater": 5, "Reborn": 10, "Severed": 3, "Unhallower": 6}])
	#zombie_spawner_3.set_waves_from_dicts([{"Amalgam": 1, "Flesheater": 2, "Reborn": 1, "Severed": 1, "Sundered": 4, "Unhallower": 8}, {"Reborn": 8, "Severed": 2, "Sundered": 6, "Unhallower": 4}, {"Erupter": 2, "Reanimator": 1, "Severed": 7, "Sundered": 5, "Unhallower": 3}])
	#zombie_spawner_4.set_waves_from_dicts([{"Amalgam": 1, "Flesheater": 2, "Reborn": 12, "Severed": 1, "Sundered": 5}, {"Erupter": 4, "Reanimator": 1, "Unhallower": 4}, {"Erupter": 5, "Flesheater": 2, "Rohan": 1, "Severed": 8, "Unhallower": 3}])
	#zombie_spawner_5.set_waves_from_dicts([{"Amalgam": 5, "Reanimator": 1, "Reborn": 1, "Severed": 1, "Unhallower": 8}, {"Amalgam": 2, "Reborn": 10, "Unhallower": 12}, {"Amalgam": 9, "Erupter": 4, "Reanimator": 1, "Severed": 5, "Unhallower": 3}])
	#zombie_spawner_6.set_waves_from_dicts([{"Amalgam": 1, "Flesheater": 1, "Reanimator": 1, "Reborn": 1, "Severed": 1, "Sundered": 5, "Unhallower": 4}, {"Flesheater": 1, "Severed": 5, "Sundered": 3}, {"Amalgam": 5, "Severed": 4, "Unhallower": 11}])
	#zombie_spawner_7.set_waves_from_dicts([{"Amalgam": 1, "Flesheater": 2, "Reborn": 1, "Severed": 1, "Unhallower": 8}, {"Amalgam": 4, "Reborn": 8, "Severed": 1, "Sundered": 3}, {"Erupter": 1, "Reborn": 18, "Severed": 7, "Unhallower": 6}])


func finish_ready():
	_setup_tutorial()
	go_to_step("GAME_READY")
	levelSwitcher.update_level(endScreen, endScreenAlt)
	levelSwitcher.update_current_level(thisLevel, thisAltLevel)
	Global.unHideDemonSelectionMenu()
	demonSelectionMenu.canSwapScenes = true


func getIsPurpleDimension():
	return
#endregion


#region Step Entry Functions
func _start_game_ready():
	_show_all_buttons()


func start_game():
	demonSelectionMenu.canSwapScenes = true
	for node in get_parent().get_children():
		if node.has_method("getIsGreenDimension"):
			green_dimension = node

	if waveManager.can_start:
		return

	waveManager.can_start = true
	green_dimension.start_game()
	gameStarted = true


func _start_explain_amalgam_zombie():
	toolTips.set_visual_tutorial_text(TUTORIAL_EXPLAIN_AMALGAM)
	toolTips.set_visual_tutorial_visual(amalgam_zombie_demo_scene.instantiate())
#endregion


#region Signal Handlers
func _on_tooltip_hidden():
	hide_spotlight()

	match get_current_step_name():
		"EXPLAIN_AMALGAM_ZOMBIE":
			get_tree().paused = false


func _on_wave_started(wave_index: int):
	if wave_index == 0:
		go_to_step("EXPLAIN_AMALGAM_ZOMBIE")
#endregion


#region UI Helpers
func setup_plant_selection_menu():
	show_all_demon_buttons()
	
	world_swap_button.visible = true 
	codex_button.visible = true 


func _show_all_buttons():
	for container_name in ALL_DEMON_CONTAINERS:
		if container_name == "Hive":
			continue
		var container = hbox.get_node(container_name)
		container.visible = true
		for child in container.get_children():
			pass
			#child.visible = true


func show_guide():
	$GameLayer/GridManager/TileMapLayer.place_rectangles_on_rows(3, 9)
#endregion
