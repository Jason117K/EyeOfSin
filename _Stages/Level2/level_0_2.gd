extends LevelTemplate
# level_0_2.gd - Level 0-2 Tutorial Controller

# Preloaded demo scenes
var hive_egg_buff_scene = preload("res://_UI/GameDemonstrations/DemonTutorials/egg_spine_buff.tscn")
var spyder_sun_buff_scene = preload("res://_UI/GameDemonstrations/DemonTutorials/sunflower_spyder_buff.tscn")
var sun_spyder_buff_scene = preload("res://_UI/GameDemonstrations/DemonTutorials/spyder_sunflower_buff.tscn")
var buff_demo_scene = preload("res://_UI/GameDemonstrations/DemonTutorials/blood_buff_demo.tscn")
var buckethead_zombie_demo_scene = preload("res://_UI/GameDemonstrations/ZombieTutorials/buckethead_zombie_demo.tscn")

# Level paths
var thisLevel := "res://_Stages/Level2/Level0-2.tscn"
var thisAltLevel := "res://_Stages/Level2/Level0-2_Alternate.tscn"
var level02 = "res://_Stages/Level2/Level0-2.tscn"
var level02Alt = "res://_Stages/Level2/Level0-2_Alternate.tscn"
var level03 = "res://_Stages/Level3/Level0-3.tscn"
var level03Alt = "res://_Stages/Level3/Level0-3_Alternate.tscn"

# Text file paths
const TUTORIAL_SELECT_SUNFLOWER = "res://_Assets/Text/TextFiles/Level0_2_Tutorial_SelectSunflower.txt"
const TUTORIAL_PLACE_SUNFLOWER = "res://_Assets/Text/TextFiles/Level0_2_Tutorial_PlaceSunflower.txt"
const TUTORIAL_PLACE_WALNUT = "res://_Assets/Text/TextFiles/DemonDescriptions/WalnutDescription.txt"
const TUTORIAL_BLOOD_GEN = "res://_Assets/Text/TextFiles/Level0_2_Tutorial_BloodGen.txt"
const TUTORIAL_SELECT_SPYDER_AFTER = "res://_Assets/Text/TextFiles/Level0_2_Tutorial_SelectSpyder.txt"
var tutorial_place_spyder = "res://_Assets/Text/TextFiles/Level0_2_Tutorial_PlaceSpyder.txt"
const TUTORIAL_BLOOD_BUFFS = "res://_Assets/Text/TextFiles/Level0_2_Tutorial_BloodBuffs.txt"
const TUTORIAL_BLOOD_BUFFS_2 = "res://_Assets/Text/TextFiles/Level0_2_Tutorial_BloodBuffs_2.txt"
const TUTORIAL_INVALID_SPYDER = "res://_Assets/Text/TextFiles/Level0_2_Tutorial_InvalidSpyderPlacement.txt"
const TUTORIAL_EXPLAIN_BUCKETHEAD_ZOMBIE = "res://_Assets/Text/TextFiles/ZombieDescriptions/bucketHeadZombieDescription.txt"

# Tutorial tracking
var tutorial_sunflower = null
var waiting_for_blood = false
var bucketHeadExplained = false
var sun_before_pickup = 0
var tutorial_sunflower_grid_pos: Vector2 = Vector2.ZERO
var tutorial_sun_instance: Node2D = null

# Plant button container names for show/hide helpers
const ALL_PLANT_CONTAINERS = ["Sunflower", "Walnut", "Egg", "Maw", "Hive", "Peashooter"]

# Cached button references
@onready var sunflower_button = plantSelectionMenu.get_node("PanelContainer/VBoxContainer/HBoxContainer/Sunflower/SunflowerButton")
@onready var spyder_button = plantSelectionMenu.get_node("PanelContainer/VBoxContainer/HBoxContainer/Peashooter/PeashooterButton2")
@onready var walnut_button = plantSelectionMenu.get_node("PanelContainer/VBoxContainer/HBoxContainer/Walnut/WalnutButton")
@onready var hbox = plantSelectionMenu.get_node("PanelContainer/VBoxContainer/HBoxContainer")


#region Tutorial Step Definitions (sequential order — read top to bottom)
func _setup_tutorial():
	define_tutorial_steps([
		{
			"name": "FORCE_SELECT_SUNFLOWER",
			"enter": _start_force_select_sunflower,
			"input_filter": _filter_block_keyboard,
		},
		{
			"name": "FORCE_PLACE_SUNFLOWER",
			"enter": _start_force_place_sunflower,
			"input_filter": _filter_block_deselect,
		},
		{
			"name": "EXPLAIN_BLOOD_GENERATION",
			"enter": _start_explain_blood_gen,
		},
		{
			"name": "FORCE_SELECT_SPYDER",
			"enter": _start_force_select_spyder_after_blood,
			"input_filter": _filter_block_keyboard,
		},
		{
			"name": "FORCE_PLACE_SPYDER_BEHIND",
			"enter": _start_force_place_spyder_behind,
			"input_filter": _filter_block_deselect,
		},
		{
			"name": "EXPLAIN_BLOOD_BUFFS",
			"enter": _start_explain_blood_buffs,
		},
		{
			"name": "EXPLAIN_BLOOD_BUFFS_2",
			"enter": _start_explain_blood_buffs_2,
		},
		{
			"name": "WAVE_1_ACTIVE",
			"enter": _start_wave_1,
		},
		{
			"name": "EXPLAIN_BUCKETHEAD_ZOMBIE",
			"enter": _start_explain_buckethead_zombie,
		},
		{
			"name": "FORCE_SELECT_WALNUT",
			"enter": _start_force_select_walnut,
			"input_filter": _filter_block_keyboard,
		},
		{
			"name": "FORCE_PLACE_WALNUT",
			"enter": _start_force_place_walnut,
			"input_filter": _filter_block_deselect,
		},
	])
#endregion


#region Lifecycle
func _ready():
	levelSwitcher.visible = false
	plantSelectionMenu.visible = false
	get_tree().paused = false
	waveManager = get_parent().get_node("WaveManager")
	waveManager.set_dialog_end(new_end_dialog)
	waveManager.Wave2StartTime = 35
	waveManager.Wave3StartTime = 55
	attach_script_to_sway_children("res://Scripts/Environment/sway.gd")

	setup_plant_selection_menu()
	pause_Button.set_restart_levels(level02, level02Alt)
	process_mode = Node.PROCESS_MODE_ALWAYS
	toolTips.set_text(TUTORIAL_SELECT_SUNFLOWER)
	toolTips.noButtonShow()
	Global.resetSunflowerCount()
	call_deferred("_find_green_dimension")

	# Connect signals
	toolTips.connect("ToolTipHid", Callable(self, "_on_tooltip_hidden"))
	plantManager.connect("plant_placed", Callable(self, "_on_sunflower_placed"))
	plantManager.connect("spyder_placed", Callable(self, "_on_spyder_placed"))
	plantManager.connect("walnut_placed", Callable(self, "_on_walnut_placed"))
	waveManager.connect("wave1Started", Callable(self, "_on_wave_1_started"))
	waveManager.connect("wave2Started", Callable(self, "_on_wave_2_started"))
	waveManager.connect("wave3Started", Callable(self, "_on_wave_3_started"))

	sunflower_button.connect("pressed", Callable(self, "_on_sunflower_button_pressed"))
	spyder_button.connect("pressed", Callable(self, "_on_spyder_button_pressed"))
	walnut_button.connect("pressed", Callable(self, "_on_walnut_button_pressed"))

	toolTips.hide()
	Dialogic.timeline_ended.connect(finish_ready)
	finish_ready()


func _find_green_dimension():
	green_dimension = get_parent().get_node("Level0-2_Alternate")


func finish_ready():
	toolTips.show()
	_setup_tutorial()
	go_to_step("FORCE_SELECT_SUNFLOWER")
	levelSwitcher.update_level(level03, level03Alt)
	levelSwitcher.update_current_level(thisLevel, thisAltLevel)
	levelSwitcher.visible = false
	Global.unHidePlantSelectionMenu()
#endregion


#region Input
func _input(event):
	_filter_tutorial_input(event)
#endregion


#region Step Entry Functions (same sequential order as definitions above)
func _start_force_select_sunflower():
	toolTips.set_text(TUTORIAL_SELECT_SUNFLOWER)
	toolTips.noButtonShow()
	show_only_plant_buttons(["Sunflower"])
	plantSelectionMenu.add_pulsing_button_highlight(sunflower_button)
	#show_spotlight_at_node(sunflower_button)
	waveManager.canStartGame = false
	plantSelectionMenu.canSwapScenes = false


func _start_force_place_sunflower():
	toolTips.set_text(TUTORIAL_PLACE_SUNFLOWER)
	toolTips.noButtonShow()
	plantSelectionMenu.remove_button_highlight(sunflower_button)
	hide_spotlight()


func _start_explain_blood_gen():
	toolTips.set_text(TUTORIAL_BLOOD_GEN)
	toolTips.noButtonShow()
	waiting_for_blood = true
	sun_before_pickup = plantManager.sun_points


func _start_force_select_spyder_after_blood():
	toolTips.set_text(TUTORIAL_SELECT_SPYDER_AFTER)
	toolTips.noButtonShow()
	show_only_plant_buttons(["Peashooter"])
	plantSelectionMenu.add_pulsing_button_highlight(spyder_button)
	#show_spotlight_at_node(spyder_button)
	waveManager.canStartGame = false
	plantSelectionMenu.canSwapScenes = false
	get_tree().paused = true


func _start_force_place_spyder_behind():
	toolTips.setComplexSceneText(tutorial_place_spyder)
	toolTips.setComplexScene(buff_demo_scene)
	toolTips.noButtonShow()
	plantSelectionMenu.remove_button_highlight(spyder_button)
	var valid_pos = tutorial_sunflower_grid_pos - Vector2(32, 0)
	#TODO Add Highlight
	#show_spotlight_at_position(valid_pos, 0.12)


func _start_explain_blood_buffs():
	get_tree().paused = true
	toolTips.setComplexSceneText(TUTORIAL_BLOOD_BUFFS)
	toolTips.setComplexScene(spyder_sun_buff_scene)
	toolTips.showButton()


func _start_explain_blood_buffs_2():
	get_tree().paused = true
	toolTips.setComplexSceneText(TUTORIAL_BLOOD_BUFFS_2)
	toolTips.setComplexScene(sun_spyder_buff_scene)
	toolTips.showButton()


func _start_wave_1():
	plantSelectionMenu.canSwapScenes = true
	waveManager.canStartGame = true
	green_dimension.start_game()
	show_only_plant_buttons(["Sunflower", "Peashooter"])
	wave_1_active = false
	wave_1_complete = false


func start_game():
	_start_wave_1()


func _start_explain_buckethead_zombie():
	bucketHeadExplained = true
	toolTips.setComplexSceneTextPause(TUTORIAL_EXPLAIN_BUCKETHEAD_ZOMBIE)
	toolTips.setComplexScene(buckethead_zombie_demo_scene)
	toolTips.showButton()


func _start_force_select_walnut():
	toolTips.set_text(TUTORIAL_PLACE_WALNUT)
	toolTips.noButtonShow()
	show_only_plant_buttons(["Walnut"])
	plantSelectionMenu.add_pulsing_button_highlight(walnut_button)
	hbox.get_node("Walnut").visible = true
	#show_spotlight_at_node(walnut_button)
	plantManager.add_sun(50.0)
	green_dimension.add_sun(50.0)


func _start_force_place_walnut():
	toolTips.set_text(TUTORIAL_PLACE_WALNUT)
	toolTips.noButtonShow()
	plantSelectionMenu.remove_button_highlight(walnut_button)
	hide_spotlight()
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
		"EXPLAIN_BLOOD_BUFFS":
			get_tree().paused = false
			advance_tutorial() # → EXPLAIN_BLOOD_BUFFS_2

		"EXPLAIN_BLOOD_BUFFS_2":
			get_tree().paused = false
			hbox.get_node("WorldSwap").visible = true
			advance_tutorial() # → WAVE_1_ACTIVE

		"EXPLAIN_BUCKETHEAD_ZOMBIE":
			get_tree().paused = false
			# No transition — wait for wave3Started signal

		"FORCE_PLACE_SPYDER_BEHIND":
			# Error tooltip acknowledged — player retries placement
			get_tree().paused = false


func _on_sunflower_button_pressed():
	if get_current_step_name() == "FORCE_SELECT_SUNFLOWER":
		advance_tutorial() # → FORCE_PLACE_SUNFLOWER


func _on_sunflower_placed(grid_pos: Vector2):
	if get_current_step_name() != "FORCE_PLACE_SUNFLOWER":
		return

	tutorial_sunflower_grid_pos = grid_pos

	# Wait for sunflower to instantiate, then force blood generation
	await get_tree().create_timer(0.3).timeout

	var sunflowers = get_tree().get_nodes_in_group("Plants")
	for plant in sunflowers:
		if "Sunflower" in plant.name:
			tutorial_sunflower = plant
			break

	if tutorial_sunflower and tutorial_sunflower.has_method("generate_sun"):
		tutorial_sun_instance = tutorial_sunflower.generate_sun()

		if tutorial_sun_instance and tutorial_sun_instance.has_node("Auto_pick_up_timer"):
			tutorial_sun_instance.get_node("Auto_pick_up_timer").stop()

		await get_tree().create_timer(0.15).timeout
		if tutorial_sun_instance:
			#TODO Add Highlight
			pass
			#show_spotlight_at_position(tutorial_sun_instance.global_position, 0.12)

	advance_tutorial() # → EXPLAIN_BLOOD_GENERATION


func _on_spyder_button_pressed():
	if get_current_step_name() == "FORCE_SELECT_SPYDER":
		advance_tutorial() # → FORCE_PLACE_SPYDER_BEHIND


func _on_spyder_placed(grid_pos: Vector2):
	if get_current_step_name() != "FORCE_PLACE_SPYDER_BEHIND":
		return

	var expected_pos = tutorial_sunflower_grid_pos - Vector2(32, 0)

	if grid_pos != expected_pos:
		# Invalid placement — delete, refund, show error, let player retry
		await get_tree().create_timer(0.15).timeout
		plantManager.clear_space(grid_pos)
		plantManager.add_sun(50)
		get_tree().paused = true
		toolTips.set_text_pause(TUTORIAL_INVALID_SPYDER)
		toolTips.showButton()
		#TODO Add Highlight
		#show_spotlight_at_position(expected_pos, 0.12)
	else:
		advance_tutorial() # → EXPLAIN_BLOOD_BUFFS


func _on_walnut_button_pressed():
	if get_current_step_name() == "FORCE_SELECT_WALNUT":
		advance_tutorial() # → FORCE_PLACE_WALNUT


func _on_walnut_placed(grid_pos: Vector2):
	if get_current_step_name() == "FORCE_PLACE_WALNUT":
		toolTips.hide()
		show_only_plant_buttons(["Sunflower", "Peashooter", "Walnut"])


func _on_wave_1_started():
	show_only_plant_buttons(["Sunflower", "Peashooter"])
	wave_1_active = true


func _on_wave_2_started():
	go_to_step("EXPLAIN_BUCKETHEAD_ZOMBIE")


func _on_wave_3_started():
	go_to_step("FORCE_SELECT_WALNUT")
#endregion


#region Blood Pickup Detection
func _physics_process(_delta):
	if waiting_for_blood and plantManager.sun_points > sun_before_pickup:
		waiting_for_blood = false
		toolTips.hide()
		hide_spotlight()
		get_tree().paused = false
		advance_tutorial() # → FORCE_SELECT_SPYDER
#endregion


#region UI Helpers
func setup_plant_selection_menu():
	hbox.get_node("Sunflower").visible = true


func show_only_plant_buttons(visible_containers: Array):
	for container_name in ALL_PLANT_CONTAINERS:
		var container = hbox.get_node(container_name)
		var should_show = container_name in visible_containers
		for child in container.get_children():
			child.visible = should_show



func show_guide():
	$GameLayer/GridManager/TileMapLayer.place_rectangles_on_rows(3, 5)
#endregion
