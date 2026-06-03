extends LevelTemplate
# level_0_3.gd - Level 0-3 Tutorial Controller

# Preloaded demo scenes
var fleshEater_zombie_demo_scene := preload("res://_UI/GameDemonstrations/ZombieTutorials/fleshEater_zombie_demo.tscn")
var codex_demo := preload("res://_UI/GameDemonstrations/codex_demo.tscn")

# Level paths
var thisLevel := "res://_Stages/Level2/Level0-3B.tscn"
var thisAltLevel := "res://_Stages/Level3/Level0-3_Alternate_B.tscn"
var level03 := "res://_Stages/Level3/Level0-3.tscn"
var level03Alt := "res://_Stages/Level3/Level0-3_Alternate.tscn"
var level04 := "res://_Stages/Level4/Level0-4.tscn"
var level04Alt := "res://_Stages/Level4/Level0-4_Alternate.tscn"

# Text file paths
const TUTORIAL_SELECT_MAW = "res://_Assets/Text/TextFiles/Level0-3_Tutorial_SelectMaw.txt"
const TUTORIAL_PLACE_MAW = "res://_Assets/Text/TextFiles/Level0-3_Tutorial_PlaceMaw.txt"
const TUTORIAL_EXPLAIN_FLESHEATER = "res://_Assets/Text/TextFiles/ZombieDescriptions/footBallZombieDescription.txt"
const TUTORIAL_SELECT_CODEX = "res://_Assets/Text/TextFiles/CodexSelectExplain.txt"

var maw_pulse_added := false

# Demon button container names

# Cached button references
@onready var zombie_spawner_1 := $GameLayer/ZombieSpawner1
@onready var zombie_spawner_2 := $GameLayer/ZombieSpawner2
@onready var zombie_spawner_3 := $GameLayer/ZombieSpawner3
@onready var zombie_spawner_4 := $GameLayer/ZombieSpawner4
@onready var zombie_spawner_5 := $GameLayer/ZombieSpawner5
@onready var maw_button :TextureButton= demonSelectionMenu.get_maw_button()
@onready var hbox := demonSelectionMenu.get_node("PanelContainer/VBoxContainer/HBoxContainer")



#region Tutorial Step Definitions (sequential order — read top to bottom)
func _setup_tutorial() -> void:
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
func _ready() -> void:
	super()
	waveManager = get_parent().get_node("WaveManager")
	#waveManager.wave_delays = [37.0, 50.0]
	waveManager.wave_delays = [wave2StartTime,wave3StartTime,wave4StartTime]
	waveManager.wave_started.connect(_on_wave_started)
	waveManager.level_ended.connect(_on_level_ended)
	_configure_waves()

	setup_demon_selection_menu()
	pause_Button.set_restart_levels(level03, level03Alt)
	process_mode = Node.PROCESS_MODE_ALWAYS
	

	Global.resetOcculumCount()
	Global.reset_swap_ability()

	# Connect signals
	toolTips.connect("ToolTipHid", Callable(self, "_on_tooltip_hidden"))
	demonManager.connect("maw_placed", Callable(self, "_on_maw_placed"))
	demonSelectionMenu.connect("codex_clicked", Callable(self, "_on_codex_button_pressed"))
	maw_button.connect("pressed", Callable(self, "_on_maw_button_pressed"))

	toolTips.hide()
	Dialogic.timeline_ended.connect(finish_ready)
	Global.hide_ui_layer()
	if debug or skip_tutorials:
		finish_ready()
	else:
		Dialogic.start(level_3_start_dialog)
	#Global.hide_ui_layer()
	#finish_ready()


func _configure_waves() -> void:
	pass
	zombie_spawner_1.set_waves_from_dicts([{},
											{}, 
											{"Severed": 1, "Reborn": 5}, 
											{"Severed": 2, "Unhallower": 1}])
	zombie_spawner_2.set_waves_from_dicts([{"Reborn": 4, "Severed": 1}, 
											{"Reborn": 1, "Severed": 2},
											{"Reborn": 1, "Severed": 3}, 
											{ "Severed": 4}])
	zombie_spawner_3.set_waves_from_dicts([{"Severed":1},
											{"Severed": 2},
											{"Severed": 3}, 
											{"Reborn": 6, "Unhallower": 2}])
	zombie_spawner_4.set_waves_from_dicts([{"Severed": 2}, 
											{"Severed": 2, "Reborn":3},
											{"Reborn": 4, "Severed": 1}, 
											{"Severed": 4}])
	zombie_spawner_5.set_waves_from_dicts([{},
											{},
											{"Severed": 3, "Reborn":2}, 
											{"Severed": 1, "Reborn": 4, "Unhallower": 1}])


	#zombie_spawner_1.set_waves_from_dicts([{"Reborn": 3}, {"Flesheater": 1, "Reborn": 2}, {"Reborn": 1, "Unhallower": 2}])
	#zombie_spawner_2.set_waves_from_dicts([{"Reborn": 3, "Severed": 1}, {"Flesheater": 1, "Reborn": 2}, {"Flesheater": 1, "Severed": 2}])
	#zombie_spawner_3.set_waves_from_dicts([{"Reborn": 2, "Severed": 1}, {"Flesheater": 1}, {"Reborn": 5, "Unhallower": 2}])
	#zombie_spawner_4.set_waves_from_dicts([{}, {"Flesheater": 1, "Severed": 1}, {"Unhallower": 2}])
	#zombie_spawner_5.set_waves_from_dicts([{}, {"Severed": 3, "Sundered": 1, "Unhallower": 1}, {"Flesheater": 1, "Reborn": 1, "Unhallower": 1}])


func finish_ready() -> void:
	Global.show_pip()
	
	if skip_tutorials:
		_start_free_play()
		return
	toolTips.show()
	toolTips.set_basic_tutorial_text(TUTORIAL_SELECT_MAW, false)
	_setup_tutorial()
	print("Go To Step Maw Select")
	go_to_step("FORCE_SELECT_MAW")
	levelSwitcher.update_level(level04, level04Alt)
	levelSwitcher.update_current_level(thisLevel, thisAltLevel)
	Global.unHideDemonSelectionMenu()
	Global.unhide_ui_layer()
	
func _start_free_play() -> void:
	hide_all_demon_buttons_with_exception(["Crawler","Occulum","SpinalOcculum"])
	world_swap_button.visible = true
	demonSelectionMenu.canSwapScenes = true
	waveManager.can_start = true
	Global.show_pip()
	Global.unhide_ui_layer()
	Global.unHideDemonSelectionMenu()

func getIsPurpleDimension():
	return
#endregion


#region Input
func _input(event: InputEvent) -> void:
	_filter_tutorial_input(event)
#endregion


#region Step Entry Functions (same sequential order as definitions above)
func _start_force_select_maw() -> void:
	print("Force Selecting Maw")
	toolTips.set_basic_tutorial_text(TUTORIAL_SELECT_MAW, false)

	hide_all_demon_buttons_with_exception(["Maw"])

	if maw_pulse_added == false:
		print("Add Glow Pulse SD")
		demonSelectionMenu.add_pulsing_button_highlight(maw_button)
		maw_pulse_added = true
	#show_spotlight_at_node(maw_button)
	waveManager.can_start = false
	demonSelectionMenu.canSwapScenes = false


func _start_force_place_maw() -> void:
	print("Force Placing Maw")
	toolTips.set_basic_tutorial_text(TUTORIAL_PLACE_MAW, false)

	#demonSelectionMenu.remove_button_highlight(maw_button)
	print("Stop GLOW Pulse")
	demonSelectionMenu.stop_glow_pulse(maw_button)
	hide_spotlight()


func _start_tutorial_p1_done() -> void:
	toolTips.hide()
	hide_all_demon_buttons_with_exception(["Occulum", "Crawler", "SpinalOcculum", "Maw"])
	demonSelectionMenu.canSwapScenes = true
	waveManager.can_start = true


func start_game() -> void:
	for node in get_parent().get_children():
		if node.has_method("getIsGreenDimension"):
			green_dimension = node

	if waveManager.can_start:
		return

	hide_all_demon_buttons_with_exception(["Occulum", "Crawler", "SpinalOcculum", "Maw"])
	demonSelectionMenu.canSwapScenes = true
	
	green_dimension.start_game()


func _start_explain_fleshEater_zombie() -> void:
	print("Should Explain Flesheaster")
	toolTips.set_visual_tutorial_text(TUTORIAL_EXPLAIN_FLESHEATER)
	toolTips.set_visual_tutorial_visual(fleshEater_zombie_demo_scene.instantiate())


func _start_explain_codex() -> void:
	#hbox.get_node("Codex").visible = true
	codex_button.show()
	codex_button.visible = true
	codex_button.pressed.connect(toolTips._on_visual_tutorial_understood_button_pressed)
	#toolTips.set_basic_tutorial_text(TUTORIAL_SELECT_CODEX, false)
	print("Codex Explain")
	toolTips.set_visual_tutorial_text(TUTORIAL_SELECT_CODEX)
	
	demonSelectionMenu.add_pulsing_button_highlight(demonSelectionMenu.get_codex_button())
	print("Add Glow Pulse F")
	toolTips.set_visual_tutorial_visual(codex_demo.instantiate(), false)
	
	#show_spotlight_at_node(codex_button)


func _start_tutorial_p2_done() -> void:
	demonSelectionMenu.stop_glow_pulse(demonSelectionMenu.get_codex_button())
	#toolTips._on_Button_pressed()
#endregion


#region Input Filters
func _filter_block_keyboard(event: InputEvent) -> void:
	if event is InputEventKey:
		get_viewport().set_input_as_handled()


func _filter_block_deselect(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_X:
			get_viewport().set_input_as_handled()
#endregion


#region Signal Handlers
func _on_tooltip_hidden() -> void:
	hide_spotlight()

	match get_current_step_name():
		"FORCE_PLACE_MAW":
			get_tree().paused = false

		"EXPLAIN_FLESHEATER_ZOMBIE":
			get_tree().paused = false

		"EXPLAIN_CODEX":
			_start_explain_codex()


func _on_maw_button_pressed() -> void:
	if get_current_step_name() == "FORCE_SELECT_MAW":
		advance_tutorial() # → FORCE_PLACE_MAW


func _on_maw_placed(_grid_pos: Vector2) -> void:
	if get_current_step_name() == "FORCE_PLACE_MAW":
		advance_tutorial() # → TUTORIAL_P1_DONE


func _on_codex_button_pressed() -> void:
	go_to_step("TUTORIAL_P2_DONE")


func _on_wave_started(wave_index: int) -> void:
	match wave_index:
		1: go_to_step("EXPLAIN_FLESHEATER_ZOMBIE")
		2: go_to_step("EXPLAIN_CODEX")
#endregion


#region UI Helpers
func setup_demon_selection_menu() -> void:
	#hbox.get_node("Maw").visible = true
	demonSelectionMenu.get_maw_button().show()
	#hbox.get_node("WorldSwap").visible = true
	demonSelectionMenu.get_world_swap_button().show()
	#hbox.get_node("RemoveDemon").visible = true
	demonSelectionMenu.get_remove_demon_button().show()
# 	hbox.get_node("Codex").visible = true
	demonSelectionMenu.get_codex_button().show()


func show_only_demon_buttons(visible_containers: Array) -> void:
	for container_name in ALL_DEMON_CONTAINERS:
		var container := hbox.get_node(container_name)
		var should_show :bool= container_name in visible_containers
		for child in container.get_children():
			child.visible = should_show


func show_guide() -> void:
	$GameLayer/GridManager/TileMapLayer.place_rectangles_on_rows(2, 6)
#endregion
