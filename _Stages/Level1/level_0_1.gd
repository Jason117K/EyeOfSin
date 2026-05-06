extends LevelTemplate

var basic_zombie_demo_scene = preload("res://_UI/GameDemonstrations/ZombieTutorials/basic_zombie_demo.tscn")
var severed_zombie_demo_scene = preload("res://_UI/GameDemonstrations/ZombieTutorials/severed_zombie_demo.tscn")

@onready var crawler_button = plantSelectionMenu.get_crawler_button()

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

	waveManager.set_dialog_end(new_end_dialog)
	waveManager.Wave2StartTime = Wave2StartTime
	waveManager.Wave3StartTime = Wave3StartTime

	setup_plant_selection_menu()
	pause_Button.set_restart_levels(current_level, current_level_alt)
	process_mode = Node.PROCESS_MODE_ALWAYS

	toolTips.connect("ToolTipHid", Callable(self, "_on_tooltip_hidden"))
	toolTips.set_text(TUTORIAL_SELECT_SPYDER)
	toolTips.noButtonShow()

	plantManager.spyder_placed.connect(func(_grid_position): _on_spyder_placed())
	waveManager.connect("wave1Started", Callable(self, "_on_wave_1_started"))
	waveManager.connect("wave3Started", Callable(self, "_on_wave_3_started"))
	crawler_button.connect("pressed", Callable(self, "_on_spyder_button_pressed"))

	toolTips.hide()
	finish_ready()


func finish_ready():
	_setup_tutorial()
	go_to_step("FORCE_SELECT_SPYDER")
	Global.unHidePlantSelectionMenu()
#endregion


#region Input
func _input(event):
	_filter_tutorial_input(event)
#endregion


#region Step Entry Functions (same sequential order as definitions above)
func _start_force_select_spyder():
	toolTips.set_text(TUTORIAL_SELECT_SPYDER)
	toolTips.noButtonShow()
	hide_all_plant_buttons_except_spyder()
	highlight_spyder_button()
	#show_spotlight_at_node(crawler_button)
	waveManager.canStartGame = false
	plantSelectionMenu.canSwapScenes = false


func _start_force_place_plant():
	toolTips.set_text(TUTORIAL_PLACE_SPYDER)
	toolTips.noButtonShow()
	unhighlight_spyder_button()
	hide_spotlight()


func _start_explain_blood_cost():
	toolTips.set_text_pause(TUTORIAL_BLOOD_COST)
	toolTips.showButton()
	show_spotlight_at_position(Vector2(10, 0))


func _start_wave_1():
	waveManager.canStartGame = true
	wave_1_active = false
	wave_1_complete = false


func start_game():
	_start_wave_1()


func _start_explain_basic_zombie():
	toolTips.setComplexSceneTextPause(TUTORIAL_EXPLAIN_BASIC_ZOMBIE)
	toolTips.setComplexScene(basic_zombie_demo_scene)
	toolTips.showButton()


func _start_force_press_y():
	plantSelectionMenu.get_node("PanelContainer/VBoxContainer/HBoxContainer/WorldSwap/WorldSwapButton").visible = true
	plantSelectionMenu.get_node("PanelContainer/VBoxContainer/HBoxContainer/WorldSwap").visible = true
	toolTips.set_text(TUTORIAL_PRESS_Y)
	toolTips.noButtonShow()


func _start_explain_green_dimension():
	toolTips.set_text_pause(TUTORIAL_GREEN_DIMENSION)
	toolTips.showButton()


func _start_wave_2_both_dimensions():
	# Start Wave 2 in green dimension
	var green_dimension = get_parent().get_node("Level0-1_Alternate")
	if green_dimension and green_dimension.has_method("start_wave_2"):
		green_dimension.start_wave_2()

	# Increment spawners from wave 1 to wave 2
	for spawner in waveManager.spawners:
		spawner.increase_wave()

	# Start Wave 2 in purple dimension
	waveManager.startSecondWave()

	# Enable dimension swapping
	plantSelectionMenu.canSwapScenes = true


func _start_explain_severed_zombie():
	toolTips.setComplexSceneTextPause(TUTORIAL_EXPLAIN_SEVERED_ZOMBIE)
	toolTips.setComplexScene(severed_zombie_demo_scene)
	toolTips.showButton()
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
	hide_spotlight()
	match get_current_step_name():
		"EXPLAIN_BLOOD_COST":
			go_to_step("WAVE_1_ACTIVE")
		"EXPLAIN_GREEN_DIMENSION":
			go_to_step("WAVE_2_ACTIVE")


func _on_spyder_placed():
	if get_current_step_name() == "FORCE_PLACE_PLANT":
		advance_tutorial() # → EXPLAIN_BLOOD_COST


func _on_spyder_button_pressed():
	if get_current_step_name() == "FORCE_SELECT_SPYDER":
		advance_tutorial() # → FORCE_PLACE_PLANT


func _on_wave_1_started():
	advance_tutorial() # → EXPLAIN_BASIC_ZOMBIE


func _on_wave_3_started():
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

			if purple_zombies.size() == 0 and wave_1_active:
				wave_1_complete = true
				go_to_step("FORCE_PRESS_Y")
#endregion


#region UI Helpers
func setup_plant_selection_menu():
	plantSelectionMenu.get_node("PanelContainer/VBoxContainer/HBoxContainer/WorldSwap/WorldSwapButton").visible = false
	plantSelectionMenu.get_node("PanelContainer/VBoxContainer/HBoxContainer/RemovePlant/RemovePlantButton").visible = false
	plantSelectionMenu.get_node("PanelContainer/VBoxContainer/HBoxContainer/Codex/CodexButton").visible = false
	plantSelectionMenu.get_node("PanelContainer").size.x = 71


func hide_all_plant_buttons_except_spyder():
	var hbox = plantSelectionMenu.get_node("PanelContainer/VBoxContainer/HBoxContainer")
	for plant_name in HIDEABLE_PLANT_NAMES:
		var container = hbox.get_node(plant_name)
		for child in container.get_children():
			child.visible = false

	# Keep Spyder visible
	crawler_button.visible = true
	plantSelectionMenu.get_node("PanelContainer/VBoxContainer/HBoxContainer/Peashooter/PeashooterLabel").visible = true


func highlight_spyder_button():
	plantSelectionMenu.add_pulsing_button_highlight(crawler_button)


func unhighlight_spyder_button():
	plantSelectionMenu.remove_button_highlight(crawler_button)
	plantSelectionMenu.stop_glow_pulse(crawler_button)


func show_guide():
	$GameLayer/GridManager/TileMapLayer.place_rectangles_on_rows(4, 4)
#endregion
