extends LevelTemplate
# level_0_6.gd - Level 0-6 Controller (no forced demon tutorial, just zombie explanation)
#500

# Preloaded demo scenes
var sundered_zombie_demo_scene := preload("res://_UI/GameDemonstrations/ZombieTutorials/amalgam_zombie_demo.tscn")

# Level paths
var thisLevel :=  "res://_Stages/Level7/Level7.tscn"
var thisAltLevel := "res://_Stages/Level7/Level7_Alternate.tscn"

var endScreen := "res://_Stages/EndScreen/EndScreen.tscn"
var endScreenAlt := "res://_Stages/EndScreen/EndScreen.tscn"

# Text file paths
const TUTORIAL_EXPLAIN_SYN_MONOLITH = "res://_Assets/Text/TextFiles/Tutorial_Explain_Syn_Monolith.txt"
const TUTORIAL_EXPLAIN_SYN_MONOLITH_2 = "res://_Assets/Text/TextFiles/Tutorial_Explain_Syn_Monolith_2.txt"
const TUTORIAL_EXPLAIN_SYN_MONOLITH_3 = "res://_Assets/Text/TextFiles/Tutorial_Explain_Syn_Monolith_3.txt"
const TUTORIAL_EXPLAIN_SYN_MONOLITH_4 = "res://_Assets/Text/TextFiles/Tutorial_Explain_Syn_Monolith_4.txt"

# Cached references
@onready var zombie_spawner_1 := $GameLayer/ZombieSpawner1
@onready var zombie_spawner_2 := $GameLayer/ZombieSpawner2
@onready var zombie_spawner_3 := $GameLayer/ZombieSpawner3
@onready var zombie_spawner_4 := $GameLayer/ZombieSpawner4
@onready var zombie_spawner_5 := $GameLayer/ZombieSpawner5
@onready var zombie_spawner_6 := $GameLayer/ZombieSpawner6
@onready var zombie_spawner_7 := $GameLayer/ZombieSpawner7
@onready var hbox := demonSelectionMenu.get_node("PanelContainer/MarginContainer/VBoxContainer/HBoxContainer")


var gameStarted := false
var syn_monolith_demo_scene := load("res://_UI/GameDemonstrations/syn_monolith_demo.tscn")

#region Tutorial Step Definitions
func _setup_tutorial() -> void:
	define_tutorial_steps([
		{
			"name": "EXPLAIN_SYN_MONOLILTH",
			"enter": _start_explain_syn_monolith,
		},
		{
			"name": "EXPLAIN_SYN_MONOLILTH_2",
			"enter": _start_explain_syn_monolith_2,
		},
		{
			"name": "EXPLAIN_SYN_MONOLILTH_3",
			"enter": _start_explain_syn_monolith_3,
		},
		{
			"name": "EXPLAIN_SYN_MONOLILTH_4",
			"enter": _start_explain_syn_monolith_4,
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
	Global.enable_ultimate()
	level_title = tr("LEVEL_TITLE_0_10")
	extended_new_power_description = "POWER_OCCULUM_DESC_LONG"
	super()
	Global.register_syn_ability(Global.lightning_strike)
	Global.register_swap_ability(Global.lightning_storm)
	#print_scene_tree()
	waveManager = get_parent().get_node("WaveManager")
	#waveManager.wave_delays = [60.0, 100.0]
	waveManager.wave_delays = [wave2StartTime,wave3StartTime,wave4StartTime,wave5StartTime,wave6StartTime]
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
	zombie_spawner_1._build_pool(0)
	#zombie_spawner_2._build_pool(0)
	#zombie_spawner_3._build_pool(0)
	#zombie_spawner_4._build_pool(0)
	#zombie_spawner_5._build_pool(0)
	#zombie_spawner_6._build_pool(0)
	#zombie_spawner_7._build_pool(0)
	#return
	#zombie_spawner_1.set_waves_from_dicts([{},                                                   #(0)
											#{},                                                  #(0)
											#{},                                                  #(0)
											#{"Amalgam": 2},                                      #(5)
											#{"Buffer": 2},                                      #(10)
											#{"Reanimator":2}])                                   #(20)
											 
	zombie_spawner_2.set_waves_from_dicts([{},                                                   #(0)
											{},                                                  #(0)
											{"Reanimator":1},                                    #(10)
											{ "Amalgam" : 5},                                    #(15-)
											{"Sundered": 2, "Buffer" : 2},                        #(15)
											{"Amalgam": 4,"Buffer": 2}])                          #(20)
											
	zombie_spawner_3.set_waves_from_dicts([{"Reborn":8,"Severed":4},                             #(3+)
											{"Reborn":4, "Unhallower":1},                         #(6-)    
											{"Reanimator":1},                                     #(10)
											{"Reanimator": 1, "Amalgam":2},                      #(15)
											{"Sundered": 3, "Buffer":2},                         #(20-)
											{"Unhallower":3, "Sundered":4}])                     #(25)
											
	zombie_spawner_4.set_waves_from_dicts([{},                                                   #(0)
											{"Unhallower":1},                                     #(5)
											{"Reanimator":1},                                    #(10)
											{"Reanimator":1 ,"Amalgam":2},                          #(11+)
											{"Sundered":3,"Buffer":2},                           #(20-)
											{"Rohan":1}])                                            #???
											
	zombie_spawner_5.set_waves_from_dicts([{"Reborn":8,"Severed":4},                             #(3+)
											{"Reborn":4, "Unhallower":1},                         #(6-)
											{"Reanimator":1},                                     #(10)
											{"Reanimator":1, "Amalgam":2},                         #(15)
											{ "Sundered":3, "Buffer":2},                          #(20-)
											{"Unhallower":3, "Sundered":4}])                      #(25)  
											
	zombie_spawner_6.set_waves_from_dicts([{},                                                   #(0)
											{},                                                  #(0)  
											{"Reanimator":1},                                      #(10)
											{ "Amalgam" : 5},                                     #(15-)
											{"Sundered": 2, "Buffer" : 2},                         #(15)
											{"Amalgam": 4,"Buffer": 2}])                          #(20)
											
	zombie_spawner_7.set_waves_from_dicts([{},                                                   #(0)
											{},                                                  #(0)
											{},                                                  #(0)
											{ "Amalgam": 2},                                      #(5)
											{"Buffer":2},                                       #(10)
											{"Reanimator":2}])                                   #(20) 

func finish_ready() -> void:
	Global.show_pip()
	if skip_tutorials:
		_start_free_play()
		return
	_setup_tutorial()
	go_to_step("EXPLAIN_SYN_MONOLILTH")
	levelSwitcher.update_level(endScreen, endScreenAlt)
	levelSwitcher.update_current_level(thisLevel, thisAltLevel)
	Global.unHideDemonSelectionMenu()
	demonSelectionMenu.canSwapScenes = true
	Global.unhide_ui_layer()
	hide_all_demon_buttons_with_exception(["Crawler","Occulum","SpinalOcculum","Wyrm","Hero"])


func _start_free_play() -> void:
	hide_all_demon_buttons_with_exception(["Crawler","Occulum","SpinalOcculum","Wyrm","Hero"])
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

func _start_explain_syn_monolith()->void:
	demonManager.add_blood(75)
	await get_tree().physics_frame
	demonSelectionMenu._on_CrawlerButton_pressed()
	demonManager.place_demon(Vector2(176,240))
	
	toolTips.set_visual_demon_tutorial_text(TUTORIAL_EXPLAIN_SYN_MONOLITH,true,"[color=red]SYN MONOLITH")
	toolTips.set_visual_demon_tutorial_visual(syn_monolith_demo_scene.instantiate(),true,Vector2(0,48))

func _start_explain_syn_monolith_2()->void:
	toolTips.set_basic_tutorial_text(TUTORIAL_EXPLAIN_SYN_MONOLITH_2,false)
	toolTips.add_pulsing_button_highlight(demonSelectionMenu.get_syn_monolith_button())
	demonSelectionMenu.get_syn_monolith_button().pressed.connect(_on_syn_monolith_pressed)
	
	

func _start_explain_syn_monolith_3()->void:
	demonSelectionMenu.get_syn_monolith_button().pressed.disconnect(_on_syn_monolith_pressed)
	Global.syn_monolith_activated.connect(_on_syn_monolith_activated)
	toolTips.set_basic_tutorial_text(TUTORIAL_EXPLAIN_SYN_MONOLITH_3,false)

func _start_explain_syn_monolith_4()->void:
	toolTips.stop_glow_pulse(demonSelectionMenu.get_syn_monolith_button())
	Global.syn_monolith_activated.disconnect(_on_syn_monolith_activated)
	toolTips.set_basic_tutorial_text(TUTORIAL_EXPLAIN_SYN_MONOLITH_4,true)
			
func _start_game_ready() -> void:
	Global.show_swap_and_pip()
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

func _on_syn_monolith_pressed()->void:
	demonSelectionMenu.get_syn_monolith_button().pressed.disconnect(_on_syn_monolith_pressed)
	go_to_step("EXPLAIN_SYN_MONOLILTH_3")

func _on_syn_monolith_activated()->void:
	go_to_step("EXPLAIN_SYN_MONOLILTH_4")
	
func _on_tooltip_hidden() -> void:
	toolTips.visible = false
	advance_tutorial()


	
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
		"Rohan":
			ui_layer.new_zombie_unlocked_button.show()
			ui_layer.set_zombie_icon_texture(new_zombie_unlocked)
