extends LevelTemplate
#750



#75
#90
#105
#105



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

const TUTORIAL_EXPLAIN_ULTIMATES := "res://_Assets/Text/TextFiles/Tutorial_Explain_Ultimates.txt"
const TUTORIAL_EXPLAIN_ULTIMATES_2 := "res://_Assets/Text/TextFiles/Tutorial_Explain_Ultimates_2.txt"
const TUTORIAL_EXPLAIN_ULTIMATES_3 := "res://_Assets/Text/TextFiles/Tutorial_Explain_Ultimates_3.txt"
const TUTORIAL_EXPLAIN_ULTIMATES_4 := "res://_Assets/Text/TextFiles/Tutorial_Explain_Ultimates_4.txt"
const TUTORIAL_EXPLAIN_ULTIMATES_5 := "res://_Assets/Text/TextFiles/Tutorial_Explain_Ultimates_5.txt"

var ultimate_demo := load("res://_UI/GameDemonstrations/ultimate_ability_demo.tscn")

var gameStarted := false
var portal_demo := load("res://_UI/GameDemonstrations/portal_ability_demo.tscn")

#region Tutorial Step Definitions
func _setup_tutorial() -> void:
	define_tutorial_steps([
		{
			"name": "START_EXPLAIN_ULTIMATES",
			"enter": _start_explain_ultimates,
		},
		{
			"name": "EXPLAIN_ULTIMATES_2",
			"enter": _start_explain_ultimates_2,
		},
		{
			"name": "EXPLAIN_ULTIMATES_3",
			"enter": _start_explain_ultimates_3,
		},
		{
			"name": "EXPLAIN_ULTIMATES_4",
			"enter": _start_explain_ultimates_4,
		},
		{
			"name": "EXPLAIN_ULTIMATES_5",
			"enter": _start_explain_ultimates_5,
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
	level_title = "0-8:ODE TO POWER"
	extended_new_power_description = "GENERATES BLOOD OVER TIME. SYNERGIES IMPROVE BLOOD GENERATION. VITAL FOR ANY DEFENSE."
	super()
	Global.register_syn_ability(Global.lightning_strike)
	Global.register_swap_ability(Global.lightning_storm)
	#print_scene_tree()
	waveManager = get_parent().get_node("WaveManager")
	waveManager.wave_delays = [wave2StartTime,wave3StartTime,wave4StartTime,wave5StartTime]
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
	zombie_spawner_1.set_waves_from_dicts([{},                                                   #(0)
											{},                                                  #(0)
											{},                                                  #(0)
											{ "Buffer": 1},                                      #(5)
											{ "Severed":4, "Buffer": 2}])                       #(12)
											
	zombie_spawner_2.set_waves_from_dicts([{},                                                   #(0)
											{},                                                  #(0)
											{"Amalgam": 2},                                      #(5)
											{"Reborn": 5, "Reanimator" : 1},                     #(11)
											{"Buffer": 1, "Reanimator" : 1}])                    #(15)
											
	zombie_spawner_3.set_waves_from_dicts([{"Reborn":3,"Severed":4},                             #(2+)
											{"Reborn": 3,"Unhallower":1},                        #(5+)    
											{"Severed": 4, "Unhallower":1},                       #(7)
											{"Severed": 4, "Reanimator":1},                      #(12)
											{"Severed": 6, "Buffer":2}])                         #(13)
											
	zombie_spawner_4.set_waves_from_dicts([{},                                                   #(0)
											{"Severed": 2,"Unhallower":1},                       #(6)
											{"Reanimator":1},                                    #(10)
											{"Severed":2 ,"Amalgam":4},                          #(11+)
											{"Amalgam":4,"Buffer":1}])                           #(15)
											
	zombie_spawner_5.set_waves_from_dicts([{"Severed":5, },                                       #(2+)
											{"Amalgam":2,  },                                     #(5)
											{"Reborn":5, "Amalgam":2},                            #(6)
											{"Buffer":1, "Amagalm":2},                           #(10)
											{ "Severed":4, "Unhallower":1,"Buffer":1}])          #(13)
											
	zombie_spawner_6.set_waves_from_dicts([{},                                                   #(0)
											{},                                                  #(0)  
											{"Severed": 6},                                      #(3)
											{"Reanimator":1},                                    #(10)
											{"Amagalm": 2,"Reanimator":1}])                      #(15)
											
	zombie_spawner_7.set_waves_from_dicts([{},                                                   #(0)
											{},                                                  #(0)
											{},                                                  #(0)
											{"Buffer":1},                                        #(5)
											{"Buffer":2}])                                       #(10)

func finish_ready() -> void:
	Global.show_pip()
	if skip_tutorials:
		_start_free_play()
		return
	_setup_tutorial()
	go_to_step("START_EXPLAIN_ULTIMATES")
	levelSwitcher.update_level(endScreen, endScreenAlt)
	levelSwitcher.update_current_level(thisLevel, thisAltLevel)
	Global.unHideDemonSelectionMenu()
	demonSelectionMenu.canSwapScenes = true
	Global.unhide_ui_layer()
	hide_all_demon_buttons_with_exception(["Crawler","Occulum","SpinalOcculum","Wyrm",])


func _start_free_play() -> void:
	hide_all_demon_buttons_with_exception(["Crawler","Occulum","SpinalOcculum","Wyrm",])
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

func _start_explain_ultimates()->void:
	UiFx.add_pulsing_button_highlight(Global.ultimate_charge_container.all_charges_panel_container)
	toolTips.set_visual_demon_tutorial_text(TUTORIAL_EXPLAIN_ULTIMATES,true,"NEW ABILITY UNLOCKED:[color=red]ULTIMATES[/color]")
	toolTips.set_visual_demon_tutorial_visual(ultimate_demo.instantiate(),true,Vector2(0,48))

func _start_explain_ultimates_2()->void:
	UiFx.remove_pulsing_button_highlight(Global.ultimate_charge_container.all_charges_panel_container)
	UiFx.add_pulsing_button_highlight(Global.ultimate_charge_container.charge_progress_bar)
	toolTips.set_basic_tutorial_text(TUTORIAL_EXPLAIN_ULTIMATES_2,true,Vector2(0,-96))


func _start_explain_ultimates_3()->void:
	print("Explain Ultimates 3")
	UiFx.remove_pulsing_button_highlight(Global.ultimate_charge_container.charge_progress_bar)
	UiFx.add_pulsing_button_highlight(Global.ultimate_charge_container.all_charges_panel_container)
	demonSelectionMenu._on_CrawlerButton_pressed()
	demonManager.place_demon(Vector2(304,176),false)
	Global.ultimate_charge_container.ultimate_bar_clicked.connect(advance_tutorial)
	toolTips.set_basic_tutorial_text(TUTORIAL_EXPLAIN_ULTIMATES_3,false,Vector2(0,-96))
	Global.ultimate_charge_container.increase_ultimate_charges()


func _start_explain_ultimates_4()->void:
	print("Explain Ultimates 4")
	Global.ultimate_charge_container.ultimate_bar_clicked.disconnect(advance_tutorial)
	Global.crawler_ultimate_triggered.connect(advance_tutorial)
	UiFx.remove_pulsing_button_highlight(Global.ultimate_charge_container.all_charges_panel_container)
	toolTips.set_basic_tutorial_text(TUTORIAL_EXPLAIN_ULTIMATES_4,false)
	

func _start_explain_ultimates_5()->void:
	print("Explain Ultimates 5")
	Global.crawler_ultimate_triggered.disconnect(advance_tutorial)
	auto_advance = true 
	toolTips.set_basic_tutorial_text(TUTORIAL_EXPLAIN_ULTIMATES_5,false)
	set_auto_advance_toolTip(6)


			
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
		"Buffer":
			ui_layer.new_zombie_unlocked_button.show()
			ui_layer.set_zombie_icon_texture(new_zombie_unlocked)
