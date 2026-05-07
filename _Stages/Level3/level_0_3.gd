extends LevelTemplate
# level_0_3.gd - Level 0-3 Tutorial Controller

# Preloaded demo scenes
var fleshEater_zombie_demo_scene = preload("res://_UI/GameDemonstrations/ZombieTutorials/fleshEater_zombie_demo.tscn")

# Level paths
var thisLevel := "res://_Stages/Level3/Level0-3.tscn"
var thisAltLevel := "res://_Stages/Level3/Level0-3_Alternate.tscn"
var level03 = "res://_Stages/Level3/Level0-3.tscn"
var level03Alt = "res://_Stages/Level3/Level0-3_Alternate.tscn"
var level04 = "res://_Stages/Level4/Level0-4.tscn"
var level04Alt = "res://_Stages/Level4/Level0-4_Alternate.tscn"

# Text file paths
const TUTORIAL_SELECT_MAW = "res://_Assets/Text/TextFiles/Level0-3_Tutorial_SelectMaw.txt"
const TUTORIAL_PLACE_MAW = "res://_Assets/Text/TextFiles/Level0-3_Tutorial_PlaceMaw.txt"
const TUTORIAL_EXPLAIN_FLESHEATER = "res://_Assets/Text/TextFiles/ZombieDescriptions/footBallZombieDescription.txt"
const TUTORIAL_SELECT_CODEX = "res://_Assets/Text/TextFiles/CodexSelectExplain.txt"

# Plant button container names
const ALL_PLANT_CONTAINERS = ["Sunflower", "Walnut", "Egg", "Maw", "Hive", "Peashooter"]

# Cached button references
@onready var maw_button = plantSelectionMenu.get_node("PanelContainer/VBoxContainer/HBoxContainer/Maw/MawButton")
@onready var codex_button = plantSelectionMenu.get_node("PanelContainer/VBoxContainer/HBoxContainer/Codex/CodexButton")
@onready var hbox = plantSelectionMenu.get_node("PanelContainer/VBoxContainer/HBoxContainer")


#region Tutorial Step Definitions (sequential order — read top to bottom)
func _setup_tutorial():
	define_tutorial_steps([
		{
			"name": "FORCE_SELECT_MAW",
			"enter": _start_force_select_maw,
			"input_filter": _filter_block_keyboard,
		},
		{
			"name": "FORCE_PLACE_MAW",
			"enter": _start_force_place_maw,
			"input_filter": _filter_block_deselect,
		},
		{
			"name": "TUTORIAL_P1_DONE",
			"enter": _start_tutorial_p1_done,
		},
		{
			"name": "EXPLAIN_FLESHEATER_ZOMBIE",
			"enter": _start_explain_fleshEater_zombie,
		},
		{
			"name": "EXPLAIN_CODEX",
			"enter": _start_explain_codex,
		},
		{
			"name": "TUTORIAL_P2_DONE",
			"enter": _start_tutorial_p2_done,
		},
	])
#endregion


#region Lifecycle
func _ready():
	waveManager = get_parent().get_node("WaveManager")
	waveManager.set_dialog_end(new_end_dialog)
	waveManager.Wave2StartTime = 37
	waveManager.Wave3StartTime = 50

	setup_plant_selection_menu()
	pause_Button.set_restart_levels(level03, level03Alt)
	process_mode = Node.PROCESS_MODE_ALWAYS
	toolTips.set_basic_tutorial_text(TUTORIAL_SELECT_MAW, false)
	
	Global.resetSunflowerCount()
	Global.reset_swap_ability()

	# Connect signals
	toolTips.connect("ToolTipHid", Callable(self, "_on_tooltip_hidden"))
	waveManager.connect("wave1Started", Callable(self, "_on_wave_1_started"))
	waveManager.connect("wave2Started", Callable(self, "_on_wave_2_started"))
	waveManager.connect("wave3Started", Callable(self, "_on_wave_3_started"))
	plantManager.connect("maw_placed", Callable(self, "_on_maw_placed"))
	plantSelectionMenu.connect("codex_clicked", Callable(self, "_on_codex_button_pressed"))
	maw_button.connect("pressed", Callable(self, "_on_maw_button_pressed"))

	toolTips.hide()
	Dialogic.timeline_ended.connect(finish_ready)
	finish_ready()


func finish_ready():
	toolTips.show()
	_setup_tutorial()
	go_to_step("FORCE_SELECT_MAW")
	levelSwitcher.update_level(level04, level04Alt)
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
func _start_force_select_maw():
	toolTips.set_basic_tutorial_text(TUTORIAL_SELECT_MAW, false)
	
	show_only_plant_buttons(["Maw"])
	plantSelectionMenu.add_pulsing_button_highlight(maw_button)
	#show_spotlight_at_node(maw_button)
	waveManager.canStartGame = false
	plantSelectionMenu.canSwapScenes = false


func _start_force_place_maw():
	toolTips.set_basic_tutorial_text(TUTORIAL_PLACE_MAW, false)
	
	plantSelectionMenu.remove_button_highlight(maw_button)
	hide_spotlight()


func _start_tutorial_p1_done():
	toolTips.hide()
	show_only_plant_buttons(["Sunflower", "Peashooter", "Walnut", "Maw"])
	plantSelectionMenu.canSwapScenes = true


func start_game():
	for node in get_parent().get_children():
		if node.has_method("getIsGreenDimension"):
			green_dimension = node

	if waveManager.canStartGame:
		return

	show_only_plant_buttons(["Sunflower", "Peashooter", "Walnut", "Maw"])
	plantSelectionMenu.canSwapScenes = true
	waveManager.canStartGame = true
	green_dimension.start_game()


func _start_explain_fleshEater_zombie():
	toolTips.set_visual_tutorial_text(TUTORIAL_EXPLAIN_FLESHEATER)
	toolTips.set_visual_tutorial_visual(fleshEater_zombie_demo_scene.instantiate())


func _start_explain_codex():
	hbox.get_node("Codex").visible = true
	codex_button.visible = true
	toolTips.set_basic_tutorial_text(TUTORIAL_SELECT_CODEX, false)
	
	#show_spotlight_at_node(codex_button)


func _start_tutorial_p2_done():
	toolTips._on_Button_pressed()
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
		"FORCE_PLACE_MAW":
			get_tree().paused = false

		"EXPLAIN_FLESHEATER_ZOMBIE":
			get_tree().paused = false

		"EXPLAIN_CODEX":
			_start_explain_codex()


func _on_maw_button_pressed():
	if get_current_step_name() == "FORCE_SELECT_MAW":
		advance_tutorial() # → FORCE_PLACE_MAW


func _on_maw_placed(_grid_pos: Vector2):
	if get_current_step_name() == "FORCE_PLACE_MAW":
		advance_tutorial() # → TUTORIAL_P1_DONE


func _on_codex_button_pressed():
	go_to_step("TUTORIAL_P2_DONE")


func _on_wave_1_started():
	pass


func _on_wave_2_started():
	go_to_step("EXPLAIN_FLESHEATER_ZOMBIE")


func _on_wave_3_started():
	go_to_step("EXPLAIN_CODEX")
#endregion


#region UI Helpers
func setup_plant_selection_menu():
	hbox.get_node("Maw").visible = true
	hbox.get_node("WorldSwap").visible = true
	hbox.get_node("RemovePlant").visible = true
	hbox.get_node("Codex").visible = true


func show_only_plant_buttons(visible_containers: Array):
	for container_name in ALL_PLANT_CONTAINERS:
		var container = hbox.get_node(container_name)
		var should_show = container_name in visible_containers
		for child in container.get_children():
			child.visible = should_show


func show_guide():
	$GameLayer/GridManager/TileMapLayer.place_rectangles_on_rows(2, 19)
#endregion
