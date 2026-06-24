extends LevelTemplate
# level_0_6.gd - Level 0-6 Controller (no forced demon tutorial, just zombie explanation)
#750
#70
#100
#80
# Preloaded demo scenes
var amalgam_zombie_demo_scene := preload("res://_UI/GameDemonstrations/ZombieTutorials/amalgam_zombie_demo.tscn")

# Level paths
var thisLevel := "res://_Stages/Level6/Level0-6.tscn"
var thisAltLevel := "res://_Stages/Level6/Level0-6_Alternate.tscn"

var endScreen := "res://_Stages/EndScreen/EndScreen.tscn"
var endScreenAlt := "res://_Stages/EndScreen/EndScreen.tscn"

var wyrm_demo_scene = load("res://_UI/GameDemonstrations/DemonTutorials/wyrm_demo_scene.tscn")

# Text file paths
const TUTORIAL_EXPLAIN_AMALGAM = "res://_Assets/Text/TextFiles/ZombieDescriptions/ScreenDoorZombieDescription.txt"
const TUTORIAL_EXPLAIN_REMOVAL = "res://_Assets/Text/TextFiles/Tutorial_Demon_Removal.txt"
const TUTORIAL_EXPLAIN_REMOVAL_2 = "res://_Assets/Text/TextFiles/Tutorial_Demon_Removal_2.txt"
const TUTORIAL_EXPLAIN_REMOVAL_3 = "res://_Assets/Text/TextFiles/Tutorial_Demon_Removal_3.txt"

# Cached references
@onready var zombie_spawner_1 := $GameLayer/ZombieSpawner1
@onready var zombie_spawner_2 := $GameLayer/ZombieSpawner2
@onready var zombie_spawner_3 := $GameLayer/ZombieSpawner3
@onready var zombie_spawner_4 := $GameLayer/ZombieSpawner4
@onready var zombie_spawner_5 := $GameLayer/ZombieSpawner5
@onready var zombie_spawner_6 := $GameLayer/ZombieSpawner6
@onready var zombie_spawner_7 := $GameLayer/ZombieSpawner7
@onready var hbox := demonSelectionMenu.get_node("PanelContainer/VBoxContainer/HBoxContainer")
@onready var wyrm_button :TextureButton = demonSelectionMenu.get_wyrm_button()


var gameStarted := false
var can_advance_to_start_game := false 

#region Tutorial Step Definitions
func _setup_tutorial() -> void:
	define_tutorial_steps([
		{
			"name": "EXPLAIN_WYRM",
			"enter": _start_explain_wyrm,
		},
		{
			"name": "EXPLAIN_REMOVAL",
			"enter": _start_explain_removal,
		},
		{
			"name": "EXPLAIN_REMOVAL_2",
			"enter": _start_explain_removal_2,
		},
		{
			"name": "EXPLAIN_REMOVAL_3",
			"enter": _start_explain_removal_3,
		},
		#{
			#"name": "FORCE_SELECT_WYRM",
			#"enter": _start_force_select_wyrm,
			#"input_filter": _filter_block_keyboard,
		#},
		#{
			#"name": "FORCE_PLACE_WYRM",
			#"enter": _start_force_place_wyrm,
			#"input_filter": _filter_block_deselect,
		#},
		{
			"name": "GAME_READY",
			"enter": _start_game_ready,
		},
		#{
			#"name": "EXPLAIN_AMALGAM_ZOMBIE",
			#"enter": _start_explain_amalgam_zombie,
		#},
	])
#endregion

func print_scene_tree(node: Node = self, indent: int = 0) -> void:
	var prefix := "\t".repeat(indent)
	print(prefix + node.name + "(" + node.get_class() + ")")
	for child in node.get_children():
		print_scene_tree(child, indent + 1)
		
#region Lifecycle
func _ready() -> void:
	level_title = "0-6:BONDS"
	extended_new_power_description = "TELEPORTS ZOMBIES TO OPPOSITE DIMENSION PORTAL. CONTROL THE FIELD"
	super()
	unlock_power.set_new_unlock_label("NEW SORCERCY")
	Global.register_syn_ability(Global.lightning_strike)
	Global.register_swap_ability(Global.lightning_storm)
	#print_scene_tree()
	waveManager = get_parent().get_node("WaveManager")
	#waveManager.wave_delays = [60.0, 100.0]
	waveManager.wave_delays = [wave2StartTime,wave3StartTime,wave4StartTime]
	waveManager.wave_started.connect(_on_wave_started)
	waveManager.level_ended.connect(_on_level_ended)
	_configure_waves()

	setup_demon_selection_menu()
	pause_Button.set_restart_levels(thisLevel, thisAltLevel)
	process_mode = Node.PROCESS_MODE_ALWAYS
	Global.resetOcculumCount()
	attach_script_to_sway_children()

	# Connect signals
	toolTips.connect("ToolTipHid", Callable(self, "_on_tooltip_hidden"))
	wyrm_button.connect("pressed", Callable(self, "_on_wyrm_button_pressed"))
	demonManager.connect("demon_placed", Callable(self, "_on_wyrm_placed"))
	demonManager.demon_placed.connect(_on_wyrm_placed)

	Dialogic.timeline_ended.connect(finish_ready)
	Global.hide_ui_layer()
	
	if debug :
		finish_ready()
	else:
		Dialogic.start(level_6_start_dialog)

	#finish_ready()

#TODO Re-Implement Rohan 
func _configure_waves() -> void:
	zombie_spawner_1.set_waves_from_dicts([{},
											{}, 
											{"Severed":3}, 
											{ "Amalgam": 2}])
	zombie_spawner_2.set_waves_from_dicts([{"Reanimator":1, "Reborn":10},
											{"Reanimator" : 1, "Reborn":9, "Severed":3}, 
											{"Reanimator": 2, "Severed": 7}, 
											{"Reanimator": 2, "Unhallower": 1, "Severed" : 2}])
	zombie_spawner_3.set_waves_from_dicts([{},
											{},
											{"Reborn": 10, "Unhallower":2}, 
											{"Severed": 2, "Unhallower": 1,"Amalgam":1 }])
	zombie_spawner_4.set_waves_from_dicts([{"Unhallower": 1}, 
											{"Unhallower": 1, "Reborn": 6},
											{"Unhallower": 1, "Severed": 6}, 
											{"Unhallower": 1, "Reanimator":1}]) 
	zombie_spawner_5.set_waves_from_dicts([{},
											{},
											{"Reborn": 10, "Unhallower":2}, 
											{"Severed": 4, "Unhallower": 1,"Amalgam":1 }])
	zombie_spawner_6.set_waves_from_dicts([{"Reanimator":1, "Reborn":10},
											{"Reanimator" : 1, "Reborn":9,"Severed":3}, 
											{"Reanimator": 2, "Severed": 7}, 
											{"Reanimator": 2, "Unhallower": 1, "Severed" : 2}])
	zombie_spawner_7.set_waves_from_dicts([{},
											{}, 
											{"Severed":3}, 
											{"Amalgam": 2}])


func finish_ready() -> void:
	Global.show_pip()
	_setup_tutorial()
	go_to_step("GAME_READY")
	levelSwitcher.update_level(endScreen, endScreenAlt)
	levelSwitcher.update_current_level(thisLevel, thisAltLevel)
	toolTips.show()
	_setup_tutorial()
	go_to_step("EXPLAIN_WYRM")
	Global.unHideDemonSelectionMenu()
	demonSelectionMenu.canSwapScenes = true
	Global.unhide_ui_layer()
	hide_all_demon_buttons_with_exception(["Wyrm"])


func getIsPurpleDimension()->void:
	return
#endregion


#region Step Entry Functions
func _start_explain_wyrm() -> void:
	await get_tree().physics_frame

	print("Explain Wyrm Demon")
	Global.hide_notification_bar()
	
	toolTips.set_visual_demon_tutorial_text(TUTORIAL_EXPLAIN_WYRM, true, "NEW DEMON : Wyrm")
	toolTips.set_visual_demon_tutorial_visual(wyrm_demo_scene.instantiate(),true,Vector2(0,0))
	hide_demon_selection_menu()
	
	#print("Explain Wyrm Demon")
	#Global.hide_notification_bar()
	#toolTips.set_visual_tutorial_text(TUTORIAL_EXPLAIN_WYRM)
	#toolTips.set_visual_tutorial_visual(wyrm_demo_scene.instantiate(),true,Vector2(0,0))

func _start_explain_removal()->void:
	await get_tree().physics_frame
	demonSelectionMenu._on_WyrmButton_pressed()
	demonManager.place_demon(Vector2(624,176))
	toolTips.set_basic_tutorial_text(TUTORIAL_EXPLAIN_REMOVAL,true)

func _start_explain_removal_2()->void:

	Global.demon_was_removed.connect(advance_to_start_game)
	can_advance_to_start_game = true 
	toolTips.set_basic_tutorial_text(TUTORIAL_EXPLAIN_REMOVAL_2,false)
	
func advance_to_start_game()->void:
	if can_advance_to_start_game:
		advance_tutorial()
		Global.demon_was_removed.disconnect(advance_to_start_game)
		can_advance_to_start_game = false 

func _start_explain_removal_3()->void:
	Global.unHideDemonSelectionMenu()
	hide_all_demon_buttons_with_exception(["Crawler","Occulum","SpinalOcculum","Wyrm"])
	auto_advance = true
	toolTips.set_basic_tutorial_text(TUTORIAL_EXPLAIN_REMOVAL_3,false)
	set_auto_advance_toolTip(8)

func _start_force_select_wyrm() -> void:
	Global.unHideDemonSelectionMenu()
	toolTips.set_basic_tutorial_text(TUTORIAL_SELECT_DEMON,false)
	hide_all_demon_buttons_with_exception(["Wyrm"])
	demonSelectionMenu.add_pulsing_button_highlight(wyrm_button)
	waveManager.can_start = false
	demonSelectionMenu.canSwapScenes = false


func _start_force_place_wyrm() -> void:

	toolTips.set_basic_tutorial_text(TUTORIAL_PLACE_MAW,false)
	demonSelectionMenu.stop_glow_pulse(wyrm_button)
		
func _start_game_ready() -> void:
	toolTips.hide()
	
	#_show_all_buttons()


func start_game() -> void:
	demonSelectionMenu.canSwapScenes = true
	for node in get_parent().get_children():
		if node.has_method("getIsGreenDimension"):
			green_dimension = node

	if waveManager.can_start:
		return

	waveManager.can_start = true
	green_dimension.start_game()
	gameStarted = true


func _start_explain_amalgam_zombie() -> void:
	toolTips.set_visual_tutorial_text(TUTORIAL_EXPLAIN_AMALGAM)
	toolTips.set_visual_tutorial_visual(amalgam_zombie_demo_scene.instantiate())
#endregion


#region Signal Handlers


func _on_tooltip_hidden() -> void:
	#hide_spotlight()
	advance_tutorial()
	#match get_current_step_name():
		#"EXPLAIN_WYRM":
			#go_to_step("FORCE_SELECT_WYRM")
		#"EXPLAIN_AMALGAM_ZOMBIE":
			#get_tree().paused = false

func _on_wyrm_button_pressed() -> void:
	if get_current_step_name() == "FORCE_SELECT_WYRM":
		go_to_step("FORCE_PLACE_WYRM")

func _on_wyrm_placed(grid_pos: Vector2) -> void:
	print("WYRM PLACED")
	if get_current_step_name() != "FORCE_PLACE_WYRM":
		print("Current Step is ", get_current_step_name())
		return
	go_to_step("GAME_READY")
		
func _on_wave_started(wave_index: int) -> void:
	pass
	#if wave_index == 0:
		#go_to_step("EXPLAIN_AMALGAM_ZOMBIE")
#endregion


#region UI Helpers
func setup_demon_selection_menu() -> void:
	show_all_demon_buttons()
	#hide_all_demon_buttons_with_exception(["Crawler","Occulum","SpinalOcculum","Wyrm"])
	world_swap_button.visible = true
	codex_button.visible = true


func _show_all_buttons() -> void:
	for container_name:String in ALL_DEMON_CONTAINERS:
		if container_name == "Hive":
			continue
		var container := hbox.get_node(container_name)
		container.visible = true
		for child in container.get_children():
			pass
			#child.visible = true


func show_guide() -> void:
	$GameLayer/GridManager/TileMapLayer.place_rectangles_on_rows(3, 9)
#endregion



func _filter_block_deselect(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_X:
			get_viewport().set_input_as_handled()

func show_zombie_tutorial(_unlocked_zombie : String)->void:
	_start_explain_amalgam_zombie()


func show_unlock_zombie_button(new_zombie_unlocked:String)->void:
	match new_zombie_unlocked:
		"Amalgam":
			ui_layer.new_zombie_unlocked_button.show()
			ui_layer.set_zombie_icon_texture(new_zombie_unlocked)
			
			
			
			
