extends LevelTemplate
# level_0_3.gd - Level 0-3 Tutorial Controller
#290
#55,80,70

# Preloaded demo scenes
var fleshEater_zombie_demo_scene := preload("res://_UI/GameDemonstrations/ZombieTutorials/fleshEater_zombie_demo.tscn")
var codex_demo := preload("res://_UI/GameDemonstrations/codex_demo.tscn")
var buckethead_zombie_demo_scene := preload("res://_UI/GameDemonstrations/ZombieTutorials/buckethead_zombie_demo.tscn")
# Level paths
var thisLevel := "res://_Stages/Level2/Level0-3B.tscn"
var thisAltLevel := "res://_Stages/Level3/Level0-3_Alternate_B.tscn"

var level04 := "res://_Stages/Level4/Level0-4.tscn"
var level04Alt := "res://_Stages/Level4/Level0-4_Alternate.tscn"

# Text file paths


var maw_pulse_added := false

var spinal_occulum_demo_scene = load("res://_UI/GameDemonstrations/DemonTutorials/spinal_occulum_demo_scene.tscn")

# Demon button container names

# Cached button references
@onready var zombie_spawner_1 := $GameLayer/ZombieSpawner1
@onready var zombie_spawner_2 := $GameLayer/ZombieSpawner2
@onready var zombie_spawner_3 := $GameLayer/ZombieSpawner3
@onready var zombie_spawner_4 := $GameLayer/ZombieSpawner4
@onready var zombie_spawner_5 := $GameLayer/ZombieSpawner5
@onready var maw_button :TextureButton= demonSelectionMenu.get_maw_button()
@onready var hbox := demonSelectionMenu.get_node("PanelContainer/MarginContainer/VBoxContainer/HBoxContainer")

@onready var spinal_occulum_button :TextureButton= demonSelectionMenu.get_spinal_occulum_button()


#region Tutorial Step Definitions (sequential order — read top to bottom)
func _setup_tutorial() -> void:
	define_tutorial_steps([
		{
			"name": "EXPLAIN_SPINAL_OCCULUM",
			"enter": _start_explain_spinal_occulum,
			"input_filter": _filter_block_deselect_and_swap,
		},
		{
			"name": "EXPLAIN_PRE_PLACED_SPINAL",
			"enter": _explain_pre_placed_spinal_occulum,
			"input_filter": _filter_block_deselect_and_swap,
		},
		{
			"name": "RESUME_GAME",
			"enter": _resume_game,
		},
		{
			"name": "SPINAL_OCCULUM_UNLOCKED",
			"enter": _spinal_occulum_unlocked,
		},
		{
			"name": "HIDE_SPINAL_HIGHLIGHT",
			"enter": _hide_spinal_occulum_highlight,
		},
	])
#endregion


#region Lifecycle
func _ready() -> void:
	Global.spinal_occulum_unlocked = true
	Global.disable_ultimate()
	level_title = tr("LEVEL_TITLE_0_3")
	extended_new_power_description = "POWER_SYN_LIGHTNING_DESC_LONG"
	super()
	waveManager = get_parent().get_node("WaveManager")
	#waveManager.wave_delays = [37.0, 50.0]
	waveManager.wave_delays = [wave2StartTime,wave3StartTime,wave4StartTime]
	waveManager.wave_started.connect(_on_wave_started)
	waveManager.level_ended.connect(_on_level_ended)
	_configure_waves()

	setup_demon_selection_menu()
	pause_Button.set_restart_levels(thisLevel, thisAltLevel)
	process_mode = Node.PROCESS_MODE_ALWAYS
	

	Global.resetOcculumCount()
	Global.reset_swap_ability()
	unlock_power.set_new_unlock_label("UI_NEW_SORCERY")

	# Connect signals
	#toolTips.connect("ToolTipHid", Callable(self, "_on_tooltip_hidden"))
	if not toolTips.ToolTipHid.is_connected(_on_tooltip_hidden):
		toolTips.ToolTipHid.connect(_on_tooltip_hidden)
	demonManager.connect("maw_placed", Callable(self, "_on_maw_placed"))
	demonSelectionMenu.connect("codex_clicked", Callable(self, "_on_codex_button_pressed"))
	maw_button.connect("pressed", Callable(self, "_on_maw_button_pressed"))
	spinal_occulum_button.pressed.connect(_on_spinal_occulum_button_pressed)
	demonManager.spinalOcculum_placed.connect(_on_spinal_occulum_placed)
	if not waveManager.wave_started.is_connected(_on_wave_started):
		waveManager.wave_started.connect(_on_wave_started)


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
	zombie_spawner_1.set_waves_from_dicts([{}, 									 #(0)
											{}, 								 #(0)
											{"Severed": 2, "Reborn": 5},  		 #(2)
											{"Severed": 4, "Unhallower": 1}]) 	 #(7)
											
	zombie_spawner_2.set_waves_from_dicts([{"Reborn": 4, "Severed": 2}, 		 #(2)
											{"Reborn": 8, "Severed": 2}, 		 #(3)
											{"Reborn": 4, "Severed": 3}, 		 #(4)
											{"Reborn": 8, "Severed": 5}])		 #(5)
											
	zombie_spawner_3.set_waves_from_dicts([{"Severed":2},                        #(1)
											{"Severed": 4},						 #(2)
											{"Severed": 6}, 					 #(3)
											{"Reborn": 8, "Unhallower": 1}])	 #(7)
											 
	zombie_spawner_4.set_waves_from_dicts([{}, 					            	  #(0)
											{"Severed": 2 },		  			  #(1)
											{"Reborn": 4, "Severed": 2}, 		  #(3)
											{"Severed": 7}])					  #(4)
											
	zombie_spawner_5.set_waves_from_dicts([{},									            #(0)
											{},									            #(0)
											{"Severed": 2, "Reborn":5}, 		            #(2)
											{"Severed": 1, "Reborn": 5, "Unhallower": 1}])  #(7)


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
	hide_all_demon_buttons_with_exception(["Crawler","Occulum"])
	toolTips.set_basic_tutorial_text(TUTORIAL_SELECT_MAW, false)
	_setup_tutorial()
	demonSelectionMenu.canSwapScenes = true
	#print("Go To Step Spinal Occulum Select")
	go_to_step("EXPLAIN_SPINAL_OCCULUM")
	levelSwitcher.update_level(level04, level04Alt)
	levelSwitcher.update_current_level(thisLevel, thisAltLevel)
	#Global.unHideDemonSelectionMenu()
	Global.unhide_ui_layer()
	
func _start_free_play() -> void:
	hide_all_demon_buttons_with_exception(["Crawler","Occulum","SpinalOcculum"])
	world_swap_button.visible = true
	demonSelectionMenu.canSwapScenes = true
	waveManager.can_start = true
	Global.show_pip()
	Global.unhide_ui_layer()
	Global.unHideDemonSelectionMenu()
	place_spinal_occulum()
	await get_tree().physics_frame
	await get_tree().physics_frame
	await get_tree().physics_frame
	get_green_dimension().hide_all_demon_buttons_with_exception(["Occulum", "Crawler", "SpinalOcculum"])

func place_spinal_occulum()->void:
	demonManager.add_blood(150)
	await get_tree().physics_frame
	demonSelectionMenu._on_SpinalOcculumButton_pressed()
	demonManager.place_demon(Vector2(176,240))
	await get_tree().physics_frame
	demonSelectionMenu._on_SpinalOcculumButton_pressed()
	demonManager.place_demon(Vector2(176,112))
	await get_tree().physics_frame
	demonSelectionMenu._on_SpinalOcculumButton_pressed()
	demonManager.place_demon(Vector2(176,176))
	await get_tree().physics_frame
	get_green_dimension().pre_place_spinal_occulum()

func getIsPurpleDimension():
	return
#endregion


#region Input
func _input(event: InputEvent) -> void:
	_filter_tutorial_input(event)
#endregion


#region Step Entry Functions (same sequential order as definitions above)

func _start_explain_spinal_occulum() -> void:
	await get_tree().physics_frame

	#print("Explain Spinal Occulum Demon")
	Global.hide_notification_bar()
	
	toolTips.set_visual_demon_tutorial_text(TUTORIAL_EXPLAIN_SPINAL_OCCULUM, true, tr("TIP_TITLE_NEW_DEMON_SPINALOCCULUM"))
	toolTips.set_visual_demon_tutorial_visual(spinal_occulum_demo_scene.instantiate(),true,Vector2(0,-16))
	hide_demon_selection_menu()

#func _start_force_select_spinal_occulum()->void:
#
	#show_demon_selection_menu()
	##print("Starting Force Select")
	##Global.unHideDemonSelectionMenu()
	#toolTips.set_basic_tutorial_text(TUTORIAL_SELECT_DEMON, false)
	#hide_all_demon_buttons_with_exception(["SpinalOcculum"])
	#demonSelectionMenu.add_pulsing_button_highlight(spinal_occulum_button)
	#demonSelectionMenu.get_spinal_occulum_button().show()
#
#func _start_force_place_spinal_occulum()->void:
	#hide_all_demon_buttons_with_exception(["Crawler","Occulum","SpinalOcculum"])
	#toolTips.set_basic_tutorial_text(TUTORIAL_PLACE_MAW, false)
	#demonSelectionMenu.stop_glow_pulse(spinal_occulum_button)

func _explain_pre_placed_spinal_occulum()->void:
	green_dimension = get_green_dimension()
	#print("Explain Pre Placed Spinal Occulum")
	show_demon_selection_menu()
	hide_all_demon_buttons_with_exception(["Crawler","Occulum"])
	place_spinal_occulum()
	toolTips.set_basic_tutorial_text(TUTORIAL_EXPLAIN_PRE_PLACED_LVL2, false)
	auto_advance = true 
	set_auto_advance_toolTip(7)

func _start_explain_unhallower() -> void:
	auto_advance = false
	toolTips.set_visual_tutorial_text(TUTORIAL_EXPLAIN_BUCKETHEAD_ZOMBIE)
	toolTips.set_visual_tutorial_visual(buckethead_zombie_demo_scene.instantiate(),true,Vector2(0,32))


func _resume_game()->void:
	toolTips.hide()
	
	
func _spinal_occulum_unlocked()->void:
	#print("Spinal Occulum Unlocked")
	green_dimension._spinal_occulum_unlocked()
	auto_advance = true 
	hide_all_demon_buttons_with_exception(["Occulum", "Crawler", "SpinalOcculum"])
	demonSelectionMenu.highlight_demon_card("SpinalOcculum")
	toolTips.set_basic_tutorial_text(TUTORIAL_SPINAL_OCCULUM_UNLOCKED, false)
	set_auto_advance_toolTip(7)

func _hide_spinal_occulum_highlight()->void:
	#print("Hide Spinal Occulum Highlight")
	demonSelectionMenu.unhighlight_demon_card("SpinalOcculum")
	green_dimension._hide_spinal_occulum_highlight()
	toolTips.hide()
	

func _start_tutorial_p1_done() -> void:
	#print("Start Tutorial P1 Done")
	toolTips.hide()
	hide_all_demon_buttons_with_exception(["Occulum", "Crawler", "SpinalOcculum"])
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

func show_zombie_tutorial(_unlocked_zombie : String)->void:
	_start_explain_unhallower()
	 

func _start_explain_codex() -> void:
	#hbox.get_node("Codex").visible = true
	codex_button.show()
	codex_button.visible = true
	codex_button.pressed.connect(toolTips._on_visual_tutorial_understood_button_pressed)
	#toolTips.set_basic_tutorial_text(TUTORIAL_SELECT_CODEX, false)
	#print("Codex Explain")
	toolTips.set_visual_tutorial_text(TUTORIAL_SELECT_CODEX)
	
	demonSelectionMenu.add_pulsing_button_highlight(demonSelectionMenu.get_codex_button())
	#print("Add Glow Pulse F")
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
	#hide_spotlight()
	#print("Tooltip Hidden")
	match get_current_step_name():
		#"FORCE_SELECT_SPINALOCCULUM":
			##print("Go to Step FORCE_PLACE_SPINAL_OCCULUM")
			#go_to_step("FORCE_PLACE_SPINAL_OCCULUM")
		"EXPLAIN_SPINAL_OCCULUM":
			go_to_step("EXPLAIN_PRE_PLACED_SPINAL")
		"FORCE_PLACE_SPINAL_OCCULUM":
			pass
		"EXPLAIN_UNHALLOWER":
			go_to_step("RESUME_GAME")
		"FORCE_PLACE_MAW":
			get_tree().paused = false

		"EXPLAIN_FLESHEATER_ZOMBIE":
			get_tree().paused = false

		"EXPLAIN_CODEX":
			_start_explain_codex()

func _on_spinal_occulum_button_pressed() -> void:
	if get_current_step_name() == "FORCE_SELECT_SPINALOCCULUM":
		#print("Go to Step FORCE_PLACE_SPINAL_OCCULUM")
		go_to_step("FORCE_PLACE_SPINAL_OCCULUM")

func _on_spinal_occulum_placed(_grid_position) -> void:
	if get_current_step_name() == "FORCE_PLACE_SPINAL_OCCULUM":
		#print("Should Hide ToolTip")
		toolTips.hide()
	else:
		pass
		#print("Current Step is ", get_current_step_name())
				
func _on_wave_started(wave_index: int) -> void:
	if skip_tutorials:
		return
	match wave_index:
		0:
			pass
		1:
			pass
		2: 
			go_to_step("SPINAL_OCCULUM_UNLOCKED")
		3:
			pass
			#go_to_step("EXPLAIN_UNHALLOWER")
			
			
func _on_maw_button_pressed() -> void:
	if get_current_step_name() == "FORCE_SELECT_MAW":
		advance_tutorial() # → FORCE_PLACE_MAW


func _on_maw_placed(_grid_pos: Vector2) -> void:
	if get_current_step_name() == "FORCE_PLACE_MAW":
		advance_tutorial() # → TUTORIAL_P1_DONE


func _on_codex_button_pressed() -> void:
	go_to_step("TUTORIAL_P2_DONE")




#func _on_wave_started(wave_index: int) -> void:
	#match wave_index:
		#1: go_to_step("EXPLAIN_FLESHEATER_ZOMBIE")
		#2: go_to_step("EXPLAIN_CODEX")
#endregion


#region UI Helpers
func setup_demon_selection_menu() -> void:
	#hbox.get_node("Maw").visible = true
	demonSelectionMenu.get_maw_button().show()
	#hbox.get_node("WorldSwap").visible = true
	demonSelectionMenu.get_world_swap_button().show()
	#hbox.get_node("RemoveDemon").visible = true
	#demonSelectionMenu.get_remove_demon_button().show()
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


func show_unlock_zombie_button(new_zombie_unlocked:String)->void:
	match new_zombie_unlocked:
		"Unhallower":
			ui_layer.new_zombie_unlocked_button.show()
			ui_layer.set_zombie_icon_texture(new_zombie_unlocked)

			
			
