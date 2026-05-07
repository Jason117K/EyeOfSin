extends LevelTemplate
# level_0_6.gd - Level 0-6 Controller (no forced plant tutorial, just zombie explanation)

# Preloaded demo scenes
var amalgam_zombie_demo_scene = preload("res://_UI/GameDemonstrations/ZombieTutorials/amalgam_zombie_demo.tscn")

# Level paths
var thisLevel := "res://Scenes/LevelScenes/Level0-6.tscn"
var thisAltLevel := "res://Scenes/LevelScenes/Level0-6_Alternate.tscn"
var level06 = "res://Scenes/LevelScenes/Level0-6.tscn"
var level06Alt = "res://Scenes/LevelScenes/Level0-6_Alternate.tscn"
var endScreen = "res://Scenes/LevelScenes/EndScreen.tscn"
var endScreenAlt = "res://Scenes/LevelScenes/EndScreen.tscn"

# Text file paths
const TUTORIAL_EXPLAIN_AMALGAM = "res://_Assets/Text/TextFiles/ZombieDescriptions/ScreenDoorZombieDescription.txt"

# Plant button container names
const ALL_PLANT_CONTAINERS = ["Sunflower", "Walnut", "Egg", "Maw", "Hive", "Peashooter"]

# Cached references
@onready var hbox = plantSelectionMenu.get_node("PanelContainer/VBoxContainer/HBoxContainer")

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
	waveManager.set_dialog_end(new_end_dialog)
	waveManager.Wave2StartTime = 35
	waveManager.Wave3StartTime = 45
	waveManager.Wave1_Interval = 3

	setup_plant_selection_menu()
	pause_Button.set_restart_levels(level06, level06Alt)
	process_mode = Node.PROCESS_MODE_ALWAYS
	Global.resetSunflowerCount()
	attach_script_to_sway_children("res://Scripts/Environment/sway.gd")

	# Connect signals
	toolTips.connect("ToolTipHid", Callable(self, "_on_tooltip_hidden"))
	waveManager.connect("wave1Started", Callable(self, "_on_wave_1_started"))

	Dialogic.timeline_ended.connect(finish_ready)
	finish_ready()


func finish_ready():
	_setup_tutorial()
	go_to_step("GAME_READY")
	levelSwitcher.update_level(endScreen, endScreenAlt)
	levelSwitcher.update_current_level(thisLevel, thisAltLevel)
	Global.unHidePlantSelectionMenu()
	plantSelectionMenu.canSwapScenes = true


func getIsPurpleDimension():
	return
#endregion


#region Step Entry Functions
func _start_game_ready():
	_show_all_buttons()


func start_game():
	plantSelectionMenu.canSwapScenes = true
	for node in get_parent().get_children():
		if node.has_method("getIsGreenDimension"):
			green_dimension = node

	if waveManager.canStartGame:
		return

	waveManager.canStartGame = true
	green_dimension.start_game()
	gameStarted = true


func _start_explain_amalgam_zombie():
	toolTips.setComplexSceneTextPause(TUTORIAL_EXPLAIN_AMALGAM)
	toolTips.setComplexScene(amalgam_zombie_demo_scene)
	toolTips.showButton()
#endregion


#region Signal Handlers
func _on_tooltip_hidden():
	hide_spotlight()

	match get_current_step_name():
		"EXPLAIN_AMALGAM_ZOMBIE":
			get_tree().paused = false


func _on_wave_1_started():
	go_to_step("EXPLAIN_AMALGAM_ZOMBIE")
#endregion


#region UI Helpers
func setup_plant_selection_menu():
	hbox.get_node("Maw").visible = true
	hbox.get_node("WorldSwap").visible = true
	hbox.get_node("RemovePlant").visible = true
	hbox.get_node("Codex").visible = true
	hbox.get_node("Sunflower").visible = true
	hbox.get_node("Walnut").visible = true
	hbox.get_node("Egg").visible = true
	hbox.get_node("Hive").visible = true


func _show_all_buttons():
	for container_name in ALL_PLANT_CONTAINERS:
		var container = hbox.get_node(container_name)
		container.visible = true
		for child in container.get_children():
			child.visible = true


func show_guide():
	$GameLayer/GridManager/TileMapLayer.place_rectangles_on_rows(2, 8)
#endregion
