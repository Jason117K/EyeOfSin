extends LevelTemplate
# level_0_5.gd - Level 0-5 Tutorial Controller
#400
#75, 100, 75
# Preloaded demo scenes
var erupter_zombie_demo_scene := preload("res://_UI/GameDemonstrations/ZombieTutorials/erupter_zombie_demo.tscn")
var lancer_zombie_demo_scene := preload("res://_UI/GameDemonstrations/ZombieTutorials/lancer_zombie_demo.tscn")

# Level paths
var thisLevel := "res://_Stages/Level5/Level0-5.tscn"
var thisAltLevel := "res://_Stages/Level5/Level0-5_Alternate.tscn"

var level06 := "res://_Stages/Level6/Level0-6.tscn"
var level06Alt := "res://_Stages/Level6/Level0-6_Alternate.tscn"
var hive_pulse_added := false

# Text file paths
const TUTORIAL_SELECT_HIVE = "res://_Assets/Text/TextFiles/Level0-5_Tutorial_SelectHive.txt"
const TUTORIAL_PLACE_HIVE = "res://_Assets/Text/TextFiles/Level0-5_Tutorial_PlaceHive.txt"
const TUTORIAL_EXPLAIN_ERUPTER = "res://_Assets/Text/TextFiles/ZombieDescriptions/tickerZombieDescription.txt"
const TUTORIAL_EXPLAIN_LANCER = "res://_Assets/Text/TextFiles/ZombieDescriptions/poleVaultZombieDescription.txt"
const TUTORIAL_EXPLAIN_SWAP = "res://_Assets/Text/TextFiles/Tutorial_Explain_Swap.txt"
const TUTORIAL_EXPLAIN_SWAP_2 = "res://_Assets/Text/TextFiles/Tutorial_Explain_Swap_2.txt"
const TUTORIAL_EXPLAIN_SWAP_3 = "res://_Assets/Text/TextFiles/Tutorial_Explain_Swap_3.txt"
const EXPLAIN_WYRM_QUEEN = "res://_Assets/Text/TextFiles/Tutorial_Explain_Wyrm_Queen.txt"

var swap_demo_scene := load("res://_UI/GameDemonstrations/swap_ability_demo.tscn")

# Cached button references
@onready var zombie_spawner_1 := $GameLayer/ZombieSpawner1
@onready var zombie_spawner_2 := $GameLayer/ZombieSpawner2
@onready var zombie_spawner_3 := $GameLayer/ZombieSpawner3
@onready var zombie_spawner_4 := $GameLayer/ZombieSpawner4
@onready var zombie_spawner_5 := $GameLayer/ZombieSpawner5
@onready var zombie_spawner_6 := $GameLayer/ZombieSpawner6
@onready var zombie_spawner_7 := $GameLayer/ZombieSpawner7
@onready var hive_button :TextureButton= demonSelectionMenu.get_hive_button()
@onready var hbox := demonSelectionMenu.get_node("PanelContainer/VBoxContainer/HBoxContainer")


#region Tutorial Step Definitions (sequential order — read top to bottom)
func _setup_tutorial() -> void:
	define_tutorial_steps([
		{
			"name": "EXPLAIN_SWAP_ABILITY",
			"enter": _start_explain_swap,
		},
		{
			"name": "EXPLAIN_SWAP_ABILITY_2",
			"enter": _start_explain_swap_2,
		},
		{
			"name": "EXPLAIN_SWAP_ABILITY_3",
			"enter": _start_explain_swap_3,
		},
		{
			"name": "PRE_START_GAME",
			"enter": _pre_start_game,
		},
	])
#endregion


#region Lifecycle
func _ready() -> void:
	extended_new_power_description = "SHOOTS PIERCING BLOOD. SYNERGIES IMPROVE AOE DAMAGE. RIPS THROUGH HORDES"
	super()
	Global.register_syn_ability(Global.lightning_strike)
	Global.register_swap_ability(Global.lightning_storm)
	
	Dialogic.Inputs.auto_skip.enabled = true
	waveManager = get_parent().get_node("WaveManager")
	#waveManager.wave_delays = [35.0, 45.0]
	waveManager.wave_delays = [wave2StartTime]
	waveManager.wave_started.connect(_on_wave_started)
	waveManager.level_ended.connect(_on_level_ended)
	_configure_waves()
	print("Set Restart Levels to ", thisLevel,thisAltLevel)
	pause_Button.set_restart_levels(thisLevel, thisAltLevel)
	process_mode = Node.PROCESS_MODE_ALWAYS
	toolTips.set_basic_tutorial_text(TUTORIAL_SELECT_HIVE, false)
	
	Global.resetOcculumCount()
	attach_script_to_sway_children()

	# Connect signals
	toolTips.connect("ToolTipHid", Callable(self, "_on_tooltip_hidden"))
	demonManager.connect("wasp_placed", Callable(self, "_on_hive_placed"))
	hive_button.connect("pressed", Callable(self, "_on_hive_button_pressed"))

	toolTips.hide()
	Dialogic.timeline_ended.connect(finish_ready)
	Global.hide_ui_layer()
	

	
	
	if debug or skip_tutorials:
		finish_ready()
	else:
		Dialogic.start(level_5_start_dialog)
	
	#finish_ready()


func _configure_waves() -> void:
	zombie_spawner_1.set_waves_from_dicts([{},
											{"Reborn": 6, "Unhallower": 1, "Reanimator":2}])
	zombie_spawner_2.set_waves_from_dicts([{"Severed":4},
											{"Reborn": 8, "Unhallower": 1}])
	zombie_spawner_3.set_waves_from_dicts([{"Severed":4},
											{"Reborn": 1, "Severed": 3}])
	zombie_spawner_4.set_waves_from_dicts([{"Severed":5}, 
											{"Reborn": 7, "Unhallower":3}]) 
	zombie_spawner_5.set_waves_from_dicts([{"Severed":4},
											{"Reborn": 7,"Severed":1}])
	zombie_spawner_6.set_waves_from_dicts([{"Severed": 4},
											{"Reborn": 8, "Unhallower": 1}]) 
	zombie_spawner_7.set_waves_from_dicts([{}, 
											{"Reanimator": 2, "Reborn":6, "Unhallower":1}])
func finish_ready() -> void:
	Global.show_pip()
	if skip_tutorials: 
		_start_free_play()
		return
	toolTips.show()
	_setup_tutorial()
	#Global.unHideDemonSelectionMenu()
	Global.unhide_ui_layer()
	hide_all_demon_buttons_with_exception(["Crawler","Occulum","SpinalOcculum"])
	go_to_step("EXPLAIN_SWAP_ABILITY")
	levelSwitcher.update_level(level06, level06Alt)
	levelSwitcher.update_current_level(thisLevel, thisAltLevel)
	demonSelectionMenu.canSwapScenes = true
	
	
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

func _start_explain_swap()->void:
	
	toolTips.set_visual_demon_tutorial_text(TUTORIAL_EXPLAIN_SWAP,true,"NEW ABILITY UNLOCKED : [color=red]SWAP SORCERIES[/color]")
	toolTips.set_visual_demon_tutorial_visual(swap_demo_scene.instantiate())
	toolTips.add_pulsing_button_highlight(Global.get_swap_ability_panel())
	await get_tree().physics_frame
	Global.hideDemonSelectionMenu()

func _start_explain_swap_2()->void:
	toolTips.set_basic_tutorial_text(TUTORIAL_EXPLAIN_SWAP_2,true,Vector2(0,-80))
	toolTips.add_pulsing_button_highlight(Global.get_swap_ability_panel())
	
func _start_explain_swap_3()->void:
	toolTips.set_basic_tutorial_text(TUTORIAL_EXPLAIN_SWAP_3,true,Vector2(0,-80))
	toolTips.add_pulsing_button_highlight(Global.get_swap_ability_panel())
	
func _pre_start_game()->void:
	Global.unHideDemonSelectionMenu()
	demonSelectionMenu.set_wyrm_queen()
	demonManager.place_demon(Vector2(48,144),true)
	toolTips.stop_glow_pulse(Global.get_swap_ability_panel())
	
	toolTips.set_basic_tutorial_text(EXPLAIN_WYRM_QUEEN,true,Vector2(0,-80))
	set_auto_advance_toolTip(9)
	green_dimension = Global.game_controller.get_green_dimension()
	green_dimension.place_wyrm_queen()



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


func _start_explain_lancer_zombie() -> void:
	toolTips.set_visual_tutorial_text(TUTORIAL_EXPLAIN_LANCER)
	toolTips.set_visual_tutorial_visual(lancer_zombie_demo_scene.instantiate())


func _start_explain_erupter_zombie() -> void:
	toolTips.set_visual_tutorial_text(TUTORIAL_EXPLAIN_ERUPTER)
	toolTips.set_visual_tutorial_visual(erupter_zombie_demo_scene.instantiate())
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
	advance_tutorial()

	#match get_current_step_name():
		#"EXPLAIN_SWAP_ABILITY":
			#go_to_step("PRE_START_GAME")
		#"FORCE_PLACE_HIVE":
			#get_tree().paused = false
#
		#"EXPLAIN_LANCER_ZOMBIE":
			#get_tree().paused = false
#
		#"EXPLAIN_ERUPTER_ZOMBIE":
			#get_tree().paused = false


func _on_hive_button_pressed() -> void:
	if get_current_step_name() == "FORCE_SELECT_HIVE":
		advance_tutorial() # → FORCE_PLACE_HIVE


func _on_hive_placed(_grid_pos: Vector2) -> void:
	if get_current_step_name() == "FORCE_PLACE_HIVE":
		advance_tutorial() # → TUTORIAL_P1_DONE


func _on_wave_started(wave_index: int) -> void:
	match wave_index:
		0: go_to_step("EXPLAIN_LANCER_ZOMBIE")
		1: go_to_step("EXPLAIN_ERUPTER_ZOMBIE")
#endregion


#region UI Helpers
func show_only_demon_buttons(visible_containers: Array) -> void:
	for container_name in ALL_DEMON_CONTAINERS:
		var container := hbox.get_node(container_name)
		var should_show :bool= container_name in visible_containers
		for child in container.get_children():
			child.visible = should_show


func _show_all_buttons() -> void:
	show_only_demon_buttons(ALL_DEMON_CONTAINERS)
	# Also show non-demon UI and parent containers
	for container_name in ALL_DEMON_CONTAINERS:
		hbox.get_node(container_name).visible = true
	world_swap_button.show()
	codex_button.show()


func show_guide() -> void:
	$GameLayer/GridManager/TileMapLayer.place_rectangles_on_rows(3, 9)
#endregion
