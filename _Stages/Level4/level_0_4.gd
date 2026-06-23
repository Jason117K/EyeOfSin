extends LevelTemplate
# level_0_4.gd - Level 0-4 Tutorial Controller
#500
#75,95,90
# Preloaded demo scenes
var summoner_zombie_demo_scene := preload("res://_UI/GameDemonstrations/ZombieTutorials/summoner_zombie_demo.tscn")

# Level paths
var thisLevel := "res://_Stages/Level4/Level0-4.tscn"
var thisAltLevel := "res://_Stages/Level4/Level0-4_Alternate.tscn"

var level05 := "res://_Stages/Level5/Level0-5.tscn"
var level05Alt := "res://_Stages/Level5/Level0-5_Alternate.tscn"

# Text file paths
#const TUTORIAL_SELECT_WYRM = "res://_Assets/Text/TextFiles/Level0-4_Tutorial_SelectWyrm.txt"
const TUTORIAL_PLACE_WYRM = "res://_Assets/Text/TextFiles/Level0-4_Tutorial_PlaceWyrm.txt"
const TUTORIAL_EXPLAIN_SUMMONER = "res://_Assets/Text/TextFiles/ZombieDescriptions/dancerZombieDescription.txt"
const TUTORIAL_EXPLAIN_SYN_ABILITY = "res://_Assets/Text/TextFiles/Tutorial_Explain_Syn_Ability.txt"
const TUTORIAL_EXPLAIN_SYN_ABILITY_2 = "res://_Assets/Text/TextFiles/Tutorial_Explain_Syn_Ability_2.txt"
const TUTORIAL_EXPLAIN_SYN_ABILITY_3 = "res://_Assets/Text/TextFiles/Tutorial_Explain_Syn_Ability_3.txt"
const TUTORIAL_EXPLAIN_SYN_ABILITY_4 = "res://_Assets/Text/TextFiles/Tutorial_Explain_Syn_Ability_4.txt"
const TUTORIAL_EXPLAIN_SYN_ABILITY_5 = "res://_Assets/Text/TextFiles/Tutorial_Explain_Syn_Ability_5.txt"
const TUTORIAL_EXPLAIN_SYN_ABILITY_6 = "res://_Assets/Text/TextFiles/Tutorial_Explain_Syn_Ability_6.txt"
const TUTORIAL_EXPLAIN_SYN_ABILITY_7 = "res://_Assets/Text/TextFiles/Tutorial_Explain_Syn_Ability_7.txt"

var syn_demo_scene := load("res://_UI/GameDemonstrations/syn_ability_demo.tscn")

# Cached button references
@onready var zombie_spawner_1 := $GameLayer/ZombieSpawner1
@onready var zombie_spawner_2 := $GameLayer/ZombieSpawner2
@onready var zombie_spawner_3 := $GameLayer/ZombieSpawner3
@onready var zombie_spawner_4 := $GameLayer/ZombieSpawner4
@onready var zombie_spawner_5 := $GameLayer/ZombieSpawner5
@onready var zombie_spawner_6 := $GameLayer/ZombieSpawner6
@onready var zombie_spawner_7 := $GameLayer/ZombieSpawner7
@onready var wyrm_button :TextureButton= demonSelectionMenu.get_wyrm_button()
@onready var hbox := demonSelectionMenu.get_node("PanelContainer/VBoxContainer/HBoxContainer")


#region Tutorial Step Definitions (sequential order — read top to bottom)
func _setup_tutorial() -> void:
	define_tutorial_steps([
		{
			"name": "EXPLAIN_SYN_ABILITY",
			"enter": _start_explain_syn_ability,
		},
		{
			"name": "EXPLAIN_SYN_ABILITY_2",
			"enter": _start_explain_syn_ability_2,
		},
		{
			"name": "EXPLAIN_SYN_ABILITY_3",
			"enter": _start_explain_syn_ability_3,
		},
		{
			"name": "EXPLAIN_SYN_ABILITY_4",
			"enter": _start_explain_syn_ability_4,
		},
		{
			"name": "EXPLAIN_SYN_ABILITY_5",
			"enter": _start_explain_syn_ability_5,
		},
		{
			"name": "EXPLAIN_SYN_ABILITY_6",
			"enter": _start_explain_syn_ability_6,
		},
		{
			"name": "EXPLAIN_SYN_ABILITY_7",
			"enter": _start_explain_syn_ability_7,
		},
		{
			"name": "PRE_START_GAME",
			"enter": _pre_start_game,
		},
		{
			"name": "EXPLAIN_REANIMATOR",
			"enter": _start_explain_reanimator,
			"input_filter": _filter_block_keyboard,
		},
		{
			"name": "RESUME_GAME",
			"enter": _resume_game,
			"input_filter": _filter_block_keyboard,
		},
	])
#endregion


#region Lifecycle
func _ready() -> void:
	extended_new_power_description = "SUMMONS LIGHTNING ACROSS THE BATTLEFIELD. USE TO TURN THE TIDE"
	super()
	unlock_power.set_new_unlock_label("NEW SORCERCY")
	
	waveManager = get_parent().get_node("WaveManager")
	#waveManager.wave_delays = [35.0, 45.0]
	waveManager.wave_delays = [wave2StartTime,wave3StartTime,wave4StartTime]
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
	Global.hide_ui_layer()
	if debug or skip_tutorials:
		finish_ready()
	else:
		Dialogic.start(level_4_start_dialog)


func _configure_waves() -> void:
## 3 -> 5 ->7
	zombie_spawner_1.set_waves_from_dicts([{},
											{}, 
											{"Reborn": 1, "Severed": 3}, 
											{ "Severed": 9}])
	zombie_spawner_2.set_waves_from_dicts([{},
											{"Severed" : 3}, 
											{"Severed": 2, "Reborn": 6}, 
											{"Severed": 2, "Unhallower": 1, "Reanimator" : 1}])
	zombie_spawner_3.set_waves_from_dicts([{"Reborn":6,"Severed":2},
											{"Severed": 5},
											{"Severed": 3, "Unhallower":1}, 
											{"Reborn": 6, "Unhallower": 3, "Reanimator":2}])
	zombie_spawner_4.set_waves_from_dicts([{"Severed": 4}, 
											{"Severed": 3, "Reborn":5},
											{"Reborn": 4, "Severed": 1}, 
											{"Severed": 6, "Unhallower":2}]) 
	zombie_spawner_5.set_waves_from_dicts([{"Reborn":5,"Severed":2}, 
											{"Severed": 2, "Reborn":6, "Unhallower":1},
											{"Reborn": 4, "Severed": 1, "Unhallower":2}, 
											{"Reborn": 9, "Reanimator":2}])
	zombie_spawner_6.set_waves_from_dicts([{}, 
											{"Severed": 4, "Reborn":9},
											{"Reborn": 4, "Severed": 1}, 
											{"Severed": 6,"Reanimator":1}]) 
	zombie_spawner_7.set_waves_from_dicts([{},
											{}, 
											{"Reborn": 4, "Severed": 1}, 
											{"Severed": 4}])
											
											
func finish_ready() -> void:
	Global.show_pip()
	if skip_tutorials:
		_start_free_play()
		return
	toolTips.show()
	_setup_tutorial()
	go_to_step("EXPLAIN_SYN_ABILITY")
	demonSelectionMenu.canSwapScenes = true
	levelSwitcher.update_level(level05, level05Alt)
	levelSwitcher.update_current_level(thisLevel, thisAltLevel)
	levelSwitcher.visible = false
	Global.unHideDemonSelectionMenu()
	Global.unhide_ui_layer()
	hide_all_demon_buttons_with_exception(["Crawler","Occulum","SpinalOcculum"])

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

func _start_explain_syn_ability()->void:
	toolTips.set_visual_demon_tutorial_text(TUTORIAL_EXPLAIN_SYN_ABILITY,true,"NEW ABILITY UNLOCKED : [color=red]SYN SOCERCIES[/color]")
	toolTips.set_visual_demon_tutorial_visual(syn_demo_scene.instantiate(),true,Vector2(0,48))
	

func _start_explain_syn_ability_2()->void:
	Global.register_syn_ability(Global.lightning_strike)
	toolTips.set_basic_tutorial_text(TUTORIAL_EXPLAIN_SYN_ABILITY_2,false)
	toolTips.add_pulsing_button_highlight(Global.get_syn_button())
	Global.get_syn_button().pressed.connect(_on_syn_sorcery_pressed)
	

func _start_explain_syn_ability_3()->void:
	Global.get_syn_button().pressed.disconnect(_on_syn_sorcery_pressed)
	Global.syn_ability_manager.syn_sorcery_activated.connect(_on_syn_sorcery_activated)
	toolTips.set_basic_tutorial_text(TUTORIAL_EXPLAIN_SYN_ABILITY_3,false)

func _start_explain_syn_ability_4()->void:
	Global.syn_ability_manager.syn_sorcery_activated.disconnect(_on_syn_sorcery_activated)
	Global.swap_scenes_signal.connect(scenes_swapped)
	toolTips.set_basic_tutorial_text(TUTORIAL_EXPLAIN_SYN_ABILITY_4,false)

func _start_explain_syn_ability_5()->void:
	green_dimension = Global.game_controller.get_green_dimension()
	green_dimension._start_explain_syn_ability_5()
	Global.syn_ability_manager.syn_sorcery_activated.connect(_on_syn_sorcery_activated_again)
	toolTips.set_basic_tutorial_text(TUTORIAL_EXPLAIN_SYN_ABILITY_5,false)

func _start_explain_syn_ability_6()->void:
	Global.syn_ability_manager.syn_sorcery_activated.disconnect(_on_syn_sorcery_activated_again)
	toolTips.set_basic_tutorial_text(TUTORIAL_EXPLAIN_SYN_ABILITY_6,false)
	auto_advance = true 
	set_auto_advance_toolTip(6)
	
func _start_explain_syn_ability_7()->void:
	toolTips.set_basic_tutorial_text(TUTORIAL_EXPLAIN_SYN_ABILITY_7,false)
	auto_advance = true 
	set_auto_advance_toolTip(6)
			
func scenes_swapped()->void:
	Global.swap_scenes_signal.disconnect(scenes_swapped)
	go_to_step("EXPLAIN_SYN_ABILITY_5")
	
func _pre_start_game()->void:
	toolTips.stop_glow_pulse(Global.get_syn_button())
	toolTips.hide()
	green_dimension._pre_start_game()
	
func _start_explain_reanimator() -> void:
	toolTips.set_visual_tutorial_text(TUTORIAL_EXPLAIN_SUMMONER)
	toolTips.set_visual_tutorial_visual(summoner_zombie_demo_scene.instantiate())

func _resume_game()->void:
	print("Resume Game")
	toolTips.hide()
	pass
	
		



func _start_tutorial_p1_done() -> void:
	toolTips.hide()
	_show_all_buttons()
	demonSelectionMenu.canSwapScenes = true


func start_game() -> void:
	for node in get_parent().get_children():
		if node.has_method("getIsGreenDimension"):
			green_dimension = node

	if waveManager.can_start:
		return

	_show_all_buttons()
	demonSelectionMenu.canSwapScenes = true
	waveManager.can_start = true
	green_dimension.start_game()


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
	match get_current_step_name():
		"EXPLAIN_SYN_ABILITY":
			go_to_step("EXPLAIN_SYN_ABILITY_2")

		"FORCE_PLACE_WYRM":
			get_tree().paused = false
		"EXPLAIN_SUMMONER_ZOMBIE":
			get_tree().paused = false

func _on_syn_sorcery_pressed()->void:
	Global.get_syn_button().pressed.disconnect(_on_syn_sorcery_pressed)
	go_to_step("EXPLAIN_SYN_ABILITY_3")

func _on_syn_sorcery_activated()->void:
	go_to_step("EXPLAIN_SYN_ABILITY_4")
	
func _on_syn_sorcery_activated_again()->void:
	go_to_step("EXPLAIN_SYN_ABILITY_6")


func _on_wave_started(wave_index: int) -> void:
	if skip_tutorials:
		return
	match wave_index:
		0:
			pass
		1:
			pass
		2: 
			pass
		3:
			go_to_step("EXPLAIN_REANIMATOR")
			
#endregion


#region UI Helpers
func show_only_demon_buttons(visible_containers: Array) -> void:
	for container_name in ALL_DEMON_CONTAINERS:
		var container := hbox.get_node(container_name)
		var should_show :bool= container_name in visible_containers
		for child in container.get_children():
			child.visible = should_show


func _show_all_buttons() -> void:
	hide_all_demon_buttons_with_exception(["Occulum", "Crawler", "SpinalOcculum", "Maw", "Wyrm"])



func remove_empty_blocker_demon(grid_pos:Vector2) -> void:
	demonManager.clear_space_alt(grid_pos)


func show_guide() -> void:
	$GameLayer/GridManager/TileMapLayer.place_rectangles_on_rows(3, 11)
#endregion
