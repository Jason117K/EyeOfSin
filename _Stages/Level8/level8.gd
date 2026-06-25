extends LevelTemplate
#750
# Preloaded demo scenes
var sundered_zombie_demo_scene := preload("res://_UI/GameDemonstrations/ZombieTutorials/amalgam_zombie_demo.tscn")

# Level paths
var thisLevel :=  "res://_Stages/Level7/Level7.tscn"
var thisAltLevel := "res://_Stages/Level7/Level7_Alternate.tscn"

var endScreen := "res://_Stages/EndScreen/EndScreen.tscn"
var endScreenAlt := "res://_Stages/EndScreen/EndScreen.tscn"

# Text file paths
const TUTORIAL_EXPLAIN_SUNDERED = "res://_Assets/Text/TextFiles/ZombieDescriptions/poleVaultZombieDescription.txt"

# Cached references
@onready var zombie_spawner_1 := $GameLayer/ZombieSpawner1
@onready var zombie_spawner_2 := $GameLayer/ZombieSpawner2
@onready var zombie_spawner_3 := $GameLayer/ZombieSpawner3
@onready var zombie_spawner_4 := $GameLayer/ZombieSpawner4
@onready var zombie_spawner_5 := $GameLayer/ZombieSpawner5
@onready var zombie_spawner_6 := $GameLayer/ZombieSpawner6
@onready var zombie_spawner_7 := $GameLayer/ZombieSpawner7
@onready var hbox := demonSelectionMenu.get_node("PanelContainer/MarginContainer/VBoxContainer/HBoxContainer")

const TUTORIAL_EXPLAIN_SKULL_TILE := "res://_Assets/Text/TextFiles/Tutorial_Explain_Skull_Tile.txt"
const TUTORIAL_EXPLAIN_PORTALS := "res://_Assets/Text/TextFiles/Tutorial_Explain_Portals.txt"
const TUTORIAL_EXPLAIN_PORTALS_2 := "res://_Assets/Text/TextFiles/Tutorial_Explain_Portals_2.txt"
const TUTORIAL_EXPLAIN_PORTALS_3 := "res://_Assets/Text/TextFiles/Tutorial_Explain_Portals_3.txt"
const TUTORIAL_PLACE_PORTAL := "res://_Assets/Text/TextFiles/Tutorial_Place_Portal.txt"
const TUTORIAL_PLACE_PORTAL_2 := "res://_Assets/Text/TextFiles/Tutorial_Place_Portal_2.txt"


var gameStarted := false
var portal_demo := load("res://_UI/GameDemonstrations/portal_ability_demo.tscn")

#region Tutorial Step Definitions
func _setup_tutorial() -> void:
	define_tutorial_steps([
		{
			"name": "EXPLAIN_SKULL_TILES",
			"enter": _start_explain_skull_tiles,
		},
		{
			"name": "EXPLAIN_PORTAL",
			"enter": _start_explain_portals,
		},
		{
			"name": "EXPLAIN_PORTAL_2",
			"enter": _start_explain_portals_2,
		},
		{
			"name": "EXPLAIN_PORTAL_3",
			"enter": _start_explain_portals_3,
		},
		{
			"name": "PLACE_PORTAL_1",
			"enter": _start_place_portals,
		},
		{
			"name": "PLACE_PORTAL_2",
			"enter": _start_place_portals_2,
		},
		{
			"name": "GAME_READY",
			"enter": _start_game_ready,
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
	level_title = "0-7:ODE TO POWER"
	extended_new_power_description = "GENERATES BLOOD OVER TIME. SYNERGIES IMPROVE BLOOD GENERATION. VITAL FOR ANY DEFENSE."
	super()
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

	Dialogic.timeline_ended.connect(finish_ready)
	Global.hide_ui_layer()
	
	if debug:
		finish_ready()
	else:
		Dialogic.start(level_6_start_dialog)

	#finish_ready()

#TODO Re-Implement Rohan 
func _configure_waves() -> void:
	#zombie_spawner_1._build_pool(0)
	#zombie_spawner_2._build_pool(0)
	#zombie_spawner_3._build_pool(0)
	#zombie_spawner_4._build_pool(0)
	#zombie_spawner_5._build_pool(0)
	#zombie_spawner_6._build_pool(0)
	#zombie_spawner_7._build_pool(0)
	#return
	zombie_spawner_1.set_waves_from_dicts([{},
											{}, 
											{"Severed":3}, 
											{ "Amalgam": 2}])
	zombie_spawner_2.set_waves_from_dicts([{"Reanimator":1, "Reborn":10},
											{"Reanimator" : 1, "Reborn":9, "Severed":3}, 
											{"Reanimator": 2, "Severed": 7}, 
											{"Reanimator": 2, "Unhallower": 1, "Severed" : 3}])
	zombie_spawner_3.set_waves_from_dicts([{"Rohan":1},
											{},
											{"Reborn": 10, "Unhallower":2}, 
											{"Severed": 3, "Unhallower": 1,"Amalgam":1 }])
	zombie_spawner_4.set_waves_from_dicts([{"Unhallower": 1}, 
											{"Unhallower": 1, "Reborn": 6},
											{"Unhallower": 1, "Severed": 6}, 
											{"Unhallower": 2, "Reanimator":1}]) 
	zombie_spawner_5.set_waves_from_dicts([{},
											{},
											{"Reborn": 10, "Unhallower":2}, 
											{"Severed": 4, "Unhallower": 1,"Amalgam":1 }])
	zombie_spawner_6.set_waves_from_dicts([{"Reanimator":1, "Reborn":10},
											{"Reanimator" : 1, "Reborn":9,"Severed":3}, 
											{"Reanimator": 2, "Severed": 7}, 
											{"Reanimator": 2, "Unhallower": 1, "Severed" : 3}])
	zombie_spawner_7.set_waves_from_dicts([{"Buffer":1},
											{}, 
											{"Severed":3}, 
											{"Amalgam": 2}])


func finish_ready() -> void:
	Global.show_pip()
	if skip_tutorials:
		_start_free_play()
		return
	_setup_tutorial()
	go_to_step("EXPLAIN_SKULL_TILES")
	levelSwitcher.update_level(endScreen, endScreenAlt)
	levelSwitcher.update_current_level(thisLevel, thisAltLevel)
	Global.unHideDemonSelectionMenu()
	demonSelectionMenu.canSwapScenes = true
	Global.unhide_ui_layer()
	hide_all_demon_buttons_with_exception(["Crawler","Occulum","SpinalOcculum","Wyrm","Portal",])


func _start_free_play() -> void:
	hide_all_demon_buttons_with_exception(["Crawler","Occulum","SpinalOcculum","Wyrm","Portal",])
	world_swap_button.visible = true
	demonSelectionMenu.canSwapScenes = true
	waveManager.can_start = true
	Global.show_pip()
	Global.unhide_ui_layer()
	Global.unHideDemonSelectionMenu()
	
func getIsPurpleDimension()->void:
	return
#endregion


#region Step Entry Functions

func _start_explain_skull_tiles()->void:
	Global.hide_swap_and_pip()
	toolTips.sideways_config()
	toolTips.set_basic_tutorial_text(TUTORIAL_EXPLAIN_SKULL_TILE,true,Vector2(16,-8))
	await get_tree().physics_frame
	Global.hideDemonSelectionMenu()
	Global.add_pulsing_button_highlight(Global.skull_tile_highlight_area)
	#set_auto_advance_toolTip(5)
	
func _start_explain_portals()->void:
	Global.remove_pulsing_button_highlight(Global.skull_tile_highlight_area)
	Global.unHideDemonSelectionMenu()
	toolTips.basic_config()
	await get_tree().physics_frame
	demonSelectionMenu.add_pulsing_button_highlight(demonSelectionMenu.PortalButton)
	toolTips.set_visual_demon_tutorial_text(TUTORIAL_EXPLAIN_PORTALS,true,"NEW ABILITY UNLOCKED: [color=green]POR[/color][color=purple]TALS[/color]")
	toolTips.set_visual_demon_tutorial_visual(portal_demo.instantiate(),true,Vector2(0,48))
	
	

		
		
func _start_explain_portals_2()->void:
	
	
	toolTips.set_basic_tutorial_text(TUTORIAL_EXPLAIN_PORTALS_2,true)
	auto_advance = true 
	set_auto_advance_toolTip(12)
	
	
func _start_explain_portals_3()->void:
	toolTips.set_basic_tutorial_text(TUTORIAL_EXPLAIN_PORTALS_3,true)
	set_auto_advance_toolTip(12)
		
func _start_place_portals()->void:
	toolTips.set_basic_tutorial_text(TUTORIAL_PLACE_PORTAL,false)
	demonManager.portal_placed.connect(_on_tooltip_hidden)
	
	
func _start_place_portals_2()->void:
	demonManager.portal_placed.disconnect(_on_tooltip_hidden)
	
	green_dimension = get_green_dimension()
	green_dimension.demonManager.portal_placed.connect(_on_tooltip_hidden)
	
	toolTips.set_basic_tutorial_text(TUTORIAL_PLACE_PORTAL_2,false)
	
			
func _start_game_ready() -> void:
	green_dimension.demonManager.portal_placed.disconnect(_on_tooltip_hidden)
	Global.show_swap_and_pip()
	demonSelectionMenu.remove_pulsing_button_highlight(demonSelectionMenu.PortalButton)
	auto_advance = false
	toolTips.hide()
	
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



#endregion


#region Signal Handlers
func _on_tooltip_hidden() -> void:
	toolTips.visible = false
	advance_tutorial()

func _start_explain_sundered()->void:
	toolTips.set_visual_tutorial_text(TUTORIAL_EXPLAIN_SUNDERED)
	toolTips.set_visual_tutorial_visual(sundered_zombie_demo_scene.instantiate())
	
	
func show_zombie_tutorial(_unlocked_zombie : String)->void:
	_start_explain_sundered()
	
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


func show_unlock_zombie_button(new_zombie_unlocked:String)->void:
	match new_zombie_unlocked:
		"Sundered":
			ui_layer.new_zombie_unlocked_button.show()
			ui_layer.set_zombie_icon_texture(new_zombie_unlocked)
