extends LevelTemplate
# level_0_6.gd - Level 0-6 Controller (no forced demon tutorial, just zombie explanation)
#750
# Preloaded demo scenes
var amalgam_zombie_demo_scene := preload("res://_UI/GameDemonstrations/ZombieTutorials/amalgam_zombie_demo.tscn")

# Level paths
var thisLevel := "res://_Stages/Level6/Level0-6.tscn"
var thisAltLevel := "res://_Stages/Level6/Level0-6_Alternate.tscn"

var endScreen := "res://_Stages/EndScreen/EndScreen.tscn"
var endScreenAlt := "res://_Stages/EndScreen/EndScreen.tscn"

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
@onready var hbox := demonSelectionMenu.get_node("PanelContainer/VBoxContainer/HBoxContainer")


var gameStarted := false


#region Tutorial Step Definitions
func _setup_tutorial() -> void:
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

func print_scene_tree(node: Node = self, indent: int = 0) -> void:
	var prefix := "\t".repeat(indent)
	print(prefix + node.name + "(" + node.get_class() + ")")
	for child in node.get_children():
		print_scene_tree(child, indent + 1)
		
#region Lifecycle
func _ready() -> void:
	super()
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

	Dialogic.timeline_ended.connect(finish_ready)
	Global.hide_ui_layer()
	
	if debug:
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
	Global.unHideDemonSelectionMenu()
	demonSelectionMenu.canSwapScenes = true
	Global.unhide_ui_layer()
	hide_all_demon_buttons_with_exception(["Crawler","Occulum","SpinalOcculum","Wyrm"])


func getIsPurpleDimension()->void:
	return
#endregion


#region Step Entry Functions
func _start_game_ready() -> void:
	_show_all_buttons()


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

	match get_current_step_name():
		"EXPLAIN_AMALGAM_ZOMBIE":
			get_tree().paused = false


func _on_wave_started(wave_index: int) -> void:
	if wave_index == 0:
		go_to_step("EXPLAIN_AMALGAM_ZOMBIE")
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
