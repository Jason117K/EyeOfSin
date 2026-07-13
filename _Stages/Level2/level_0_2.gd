extends LevelTemplate
# level_0_2.gd - Level 0-2 Tutorial Controller
#55
#75
#75
#600
# Preloaded demo scenes
var hive_wyrm_buff_scene := preload("res://_UI/GameDemonstrations/DemonTutorials/wyrm_spine_buff.tscn")
var crawler_occulum_buff_scene := preload("res://_UI/GameDemonstrations/DemonTutorials/crawler_occulum_buff.tscn")
var occulum_crawler_buff_scene := preload("res://_UI/GameDemonstrations/DemonTutorials/occulum_crawler_buff.tscn")
var buff_demo_scene := preload("res://_UI/GameDemonstrations/DemonTutorials/blood_buff_demo.tscn")
var buckethead_zombie_demo_scene := preload("res://_UI/GameDemonstrations/ZombieTutorials/buckethead_zombie_demo.tscn")

var occulum_demo_scene = load("res://_UI/GameDemonstrations/DemonTutorials/occulum_demo_scene.tscn")
# Level paths
var thisLevel := "res://_Stages/Level2/Level0-2.tscn"
var thisAltLevel := "res://_Stages/Level2/Level0-2_Alternate.tscn"
var level02 := "res://_Stages/Level2/Level0-2.tscn"
var level02Alt := "res://_Stages/Level2/Level0-2_Alternate.tscn"
var level03 := "res://_Stages/Level3/Level0-3.tscn"
var level03Alt := "res://_Stages/Level3/Level0-3_Alternate.tscn"

# Text file paths

var tutorial_place_crawler := "res://_Assets/Text/TextFiles/Level0_2_Tutorial_PlaceCrawler.txt"

# Tutorial tracking
var tutorial_occulum : Demon = null
var tutorial_crawler : Demon = null 
var waiting_for_blood := false
var bucketHeadExplained := false
var blood_before_pickup := 0
var tutorial_occulum_grid_pos: Vector2 = Vector2.ZERO
var tutorial_blood_instance: Node2D = null
var occulum_glow_added := false
var crawler_placed := false



# Cached button references
@onready var zombie_spawner_1 := $GameLayer/ZombieSpawner1
@onready var zombie_spawner_2 := $GameLayer/ZombieSpawner2
@onready var zombie_spawner_3 := $GameLayer/ZombieSpawner3
@onready var occulum_button :TextureButton= demonSelectionMenu.get_occulum_button()
@onready var crawler_button :TextureButton= demonSelectionMenu.get_crawler_button()
@onready var spinal_occulum_button :TextureButton= demonSelectionMenu.get_spinal_occulum_button()
@onready var hbox := demonSelectionMenu.get_node("PanelContainer/VBoxContainer/HBoxContainer")


#region Tutorial Step Definitions (sequential order — read top to bottom)
func _setup_tutorial() -> void:
	define_tutorial_steps([
		{
			"name": "EXPLAIN_OCCULUM",
			"enter": _start_explain_occulum,
		},
		{
			"name": "FORCE_SELECT_OCCULUM",
			"enter": _start_force_select_occulum,
			"input_filter": _filter_block_keyboard,
		},
		{
			"name": "FORCE_PLACE_OCCULUM",
			"enter": _start_force_place_occulum,
			"input_filter": _filter_block_deselect,
		},
		{
			"name": "EXPLAIN_BLOOD_GENERATION",
			"enter": _start_explain_blood_gen,
		},
		{
			"name": "FORCE_SELECT_CRAWLER",
			"enter": _start_force_select_crawler_after_blood,
			"input_filter": _filter_block_keyboard,
		},
		{
			"name": "FORCE_PLACE_CRAWLER_BEHIND",
			"enter": _start_force_place_crawler_behind,
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
			"name": "EXPLAIN_BLOOD_BUFFS_3",
			"enter": _start_explain_blood_buffs_3,
		},
		{
			"name": "EXPLAIN_BLOOD_BUFFS_4",
			"enter": _start_explain_blood_buffs_4,
		},
		{
			"name": "EXPLAIN_BLOOD_BUFFS_5",
			"enter": _start_explain_blood_buffs_5,
		},
		{
			"name": "HIDE_BUFF_FIVE",
			"enter": _hide_blood_buff_5,
		},
	])
	
#endregion


#region Lifecycle
func _ready() -> void:
	Global.disable_ultimate()
	level_title = tr("LEVEL_TITLE_0_2")
	extended_new_power_description = "POWER_SPINAL_OCCULUM_DESC_LONG"
	super()
	levelSwitcher.visible = false
	demonSelectionMenu.visible = false
	get_tree().paused = false
	waveManager = get_parent().get_node("WaveManager")
	#waveManager.wave_delays = [35.0, 55.0]
	waveManager.wave_delays = [wave2StartTime,wave3StartTime]
	waveManager.wave_started.connect(_on_wave_started)
	waveManager.level_ended.connect(_on_level_ended)
	_configure_waves()
	attach_script_to_sway_children()

	setup_demon_selection_menu()
	pause_Button.set_restart_levels(level02, level02Alt)
	process_mode = Node.PROCESS_MODE_ALWAYS
	toolTips.set_basic_tutorial_text(TUTORIAL_SELECT_OCCULUM, false)
	
	Global.resetOcculumCount()
	call_deferred("_find_green_dimension")

	# Connect signals
	if not toolTips.ToolTipHid.is_connected(_on_tooltip_hidden):
		toolTips.ToolTipHid.connect(_on_tooltip_hidden)
	#toolTips.connect("ToolTipHid", Callable(self, "_on_tooltip_hidden"))
	demonManager.connect("occulum_placed", Callable(self, "_on_occulum_placed"))
	demonManager.connect("crawler_placed", Callable(self, "_on_crawler_placed"))
	demonManager.connect("spinalOcculum_placed", Callable(self, "_on_spinalOcculum_placed"))

	occulum_button.connect("pressed", Callable(self, "_on_occulum_button_pressed"))
	crawler_button.connect("pressed", Callable(self, "_on_crawler_button_pressed"))
	spinal_occulum_button.connect("pressed", Callable(self, "_on_spinalOcculum_button_pressed"))

	toolTips.hide()
	Dialogic.timeline_ended.connect(finish_ready)
	#print("Crawler Button at ready is : ", crawler_button)
	Global.hide_ui_layer()
	if debug or skip_tutorials:
		finish_ready()
	else:
		Dialogic.start(level_2_start_dialog)
	#finish_ready()
	
func _start_free_play() -> void:
	hide_all_demon_buttons_with_exception(["Crawler","Occulum",])
	world_swap_button.visible = true
	demonSelectionMenu.canSwapScenes = true
	waveManager.can_start = true
	Global.show_pip()
	Global.unhide_ui_layer()
	Global.unHideDemonSelectionMenu()

func _configure_waves() -> void:
	pass
	zombie_spawner_1.set_waves_from_dicts([{},
											{"Severed": 2},                #(2)
											{"Severed": 5}])               #(3)
	zombie_spawner_2.set_waves_from_dicts([{"Reborn": 5},                  #(1)
											{"Reborn": 5, "Severed": 2},   #(2)
											{"Reborn": 5, "Severed": 3}])  #(3)  
	zombie_spawner_3.set_waves_from_dicts([{"Reborn": 5},                  #(1)
											{"Reborn": 5, "Severed": 2},   #(2)
											{"Severed": 5}])               #(3)


func _find_green_dimension() -> void:
	green_dimension = get_parent().get_node("Level0-2_Alternate")


func finish_ready() -> void:
	Global.show_pip()
	if skip_tutorials:
		_start_free_play()
		return
	toolTips.show()
	_setup_tutorial()
	go_to_step("EXPLAIN_OCCULUM")
	levelSwitcher.update_level(level03, level03Alt)
	levelSwitcher.update_current_level(thisLevel, thisAltLevel)
	levelSwitcher.visible = false
	Global.unHideDemonSelectionMenu()
	Global.unhide_ui_layer()
#endregion


#region Input
func _input(event: InputEvent) -> void:
	_filter_tutorial_input(event)
#func _unhandled_input(event: InputEvent) -> void:
	#_filter_tutorial_input(event)

#endregion


#region Step Entry Functions (same sequential order as definitions above)

func _start_explain_occulum() -> void:
	print("Start Explain Occulum")
	demonSelectionMenu.block_clicks()
	Global.hide_notification_bar()
	toolTips.set_visual_demon_tutorial_text(TUTORIAL_EXPLAIN_OCCULUM,true,tr("TIP_TITLE_NEW_DEMON_OCCULUM"))
	toolTips.set_visual_demon_tutorial_visual(occulum_demo_scene.instantiate(),true,Vector2(0,0))
	toolTips.new_demon_visual_minimum_size()


func _start_force_select_occulum() -> void:
	print("Start Force Select Occulum")
	demonSelectionMenu.unblock_clicks()
	toolTips.set_basic_tutorial_text(TUTORIAL_SELECT_OCCULUM,false)

	#show_only_demon_buttons(["Occulum"])
	hide_all_demon_buttons_with_exception(["Occulum"])
	if occulum_glow_added == false:
		demonSelectionMenu.add_pulsing_button_highlight(occulum_button)
		occulum_glow_added = true
	
	#show_spotlight_at_node(occulum_button)
	waveManager.can_start = false
	demonSelectionMenu.canSwapScenes = false


func _start_force_place_occulum() -> void:
	print("Start Force Place Occulum")

	toolTips.set_basic_tutorial_text(TUTORIAL_PLACE_OCCULUM,false)
	
	#demonSelectionMenu.remove_button_highlight(occulum_button)
	demonSelectionMenu.stop_glow_pulse(occulum_button)
	#hide_spotlight()


func _start_explain_blood_gen() -> void:
	print("Start Explain Blood Gen")
	toolTips.set_basic_tutorial_text(TUTORIAL_BLOOD_GEN, false)

	waiting_for_blood = true
	blood_before_pickup = demonManager.blood_points


func _start_force_select_crawler_after_blood() -> void:
	print("Start Force Select Crawler After Blood")
	toolTips.set_basic_tutorial_text(TUTORIAL_SELECT_CRAWLER_AFTER, false)
	hide_all_demon_buttons_with_exception(["Crawler"])
	#show_only_demon_buttons(["Crawler"])
	#print("Crawler Button is now : ", crawler_button)
	demonSelectionMenu.add_pulsing_button_highlight(crawler_button)
	#print("Add Glow Pulse A")
	#show_spotlight_at_node(crawler_button)
	
	demonSelectionMenu.canSwapScenes = false
	get_tree().paused = true


func _start_force_place_crawler_behind() -> void:
	print("Start Force Place Crawler Behind")
	Global.is_blocking = true
	toolTips.set_visual_demon_tutorial_text(tutorial_place_crawler,true,tr("TIP_TITLE_BLOOD_BUFFS"))
	toolTips.set_visual_demon_tutorial_visual(buff_demo_scene.instantiate())
	toolTips.new_demon_visual_minimum_size(Vector2(600,0))
	
	#demonSelectionMenu.remove_button_highlight(crawler_button)
	demonSelectionMenu.stop_glow_pulse(crawler_button)
	tutorial_occulum.show_buff_preview_nodes()

	var expected_pos_1 :Vector2= tutorial_occulum_grid_pos - Vector2(32, 0)
	var expected_pos_2 :Vector2= tutorial_occulum_grid_pos - Vector2(64, 0)
	var expected_pos_array : Array[Vector2] = [expected_pos_1,expected_pos_2]
	$GameLayer/GridManager/TileMapLayer.highlight_rectangles(expected_pos_array)
	#show_spotlight_at_position(valid_pos, 0.12)


func _start_explain_blood_buffs() -> void:
	print("Start Explain Blood Buffs")
	
	get_tree().paused = true
	toolTips.set_visual_demon_tutorial_text(TUTORIAL_BLOOD_BUFFS,true, tr("TIP_TITLE_SYNERGY_CRAWLEROCCULUM"))
	toolTips.set_visual_demon_tutorial_visual(crawler_occulum_buff_scene.instantiate())


func _start_explain_blood_buffs_2() -> void:
	print("Start Explain Blood Buffs 2")
	get_tree().paused = true
	toolTips.set_visual_demon_tutorial_text(TUTORIAL_BLOOD_BUFFS_2,true,tr("TIP_TITLE_SYNERGY_OCCULUMCRAWLER"))
	toolTips.set_visual_demon_tutorial_visual(occulum_crawler_buff_scene.instantiate())
	tutorial_occulum.hide_buff_preview_nodes()
	tutorial_crawler.hide_buff_preview_nodes()


func _start_wave_1() -> void:
	print("Start Wave 1")
	demonSelectionMenu.canSwapScenes = true
	waveManager.can_start = true
	green_dimension.start_game()
	hide_all_demon_buttons_with_exception(["Occulum","Crawler"])
	#show_only_demon_buttons(["Occulum", "Crawler"])
	wave_1_active = false
	wave_1_complete = false
	go_to_step("EXPLAIN_BLOOD_BUFFS_3")

func _start_explain_blood_buffs_3() -> void:
	print("Start Explain Blood Buffs 3")
	auto_advance = true 
	toolTips.set_basic_tutorial_text(TUTORIAL_BLOOD_BUFFS_3,false)
	set_auto_advance_toolTip(4)

	
func _start_explain_blood_buffs_4() -> void:
	print("Start Explain Blood Buffs 4")
	toolTips.set_basic_tutorial_text(TUTORIAL_BLOOD_BUFFS_4,false)
	set_auto_advance_toolTip(4)
	
func _start_explain_blood_buffs_5() -> void:
	print("Start Explain Blood Buffs 5")
	toolTips.set_basic_tutorial_text(TUTORIAL_BLOOD_BUFFS_5,false)
	set_auto_advance_toolTip(4)

func start_game() -> void:
	_start_wave_1()

func _hide_blood_buff_5()->void:
	toolTips.hide()

func _start_explain_buckethead_zombie() -> void:
	bucketHeadExplained = true
	toolTips.set_visual_tutorial_text(TUTORIAL_EXPLAIN_BUCKETHEAD_ZOMBIE)
	toolTips.set_visual_tutorial_visual(buckethead_zombie_demo_scene.instantiate())


func _start_force_select_spinalOcculum() -> void:
	toolTips.set_basic_tutorial_text(TUTORIAL_PLACE_SPINALOCCULUM, false)
	hide_all_demon_buttons_with_exception(["SpinalOcculum"])
	print("Add Glow Pulse C")
	#show_only_demon_buttons(["SpinalOcculum"])
	demonSelectionMenu.add_pulsing_button_highlight(spinal_occulum_button)
	demonSelectionMenu.get_spinal_occulum_button().show()
	#hbox.get_node("SpinalOcculum").visible = true
	#show_spotlight_at_node(spinal_occulum_button)
	demonManager.add_blood(50.0)
	green_dimension.add_blood(50.0)


func _start_force_place_spinalOcculum() -> void:
	print("PLACING WALL NUT")
	toolTips.set_basic_tutorial_text(TUTORIAL_PLACE_SPINALOCCULUM, false)
	
	#demonSelectionMenu.remove_button_highlight(spinal_occulum_button)
	demonSelectionMenu.stop_glow_pulse(spinal_occulum_button)
	#hide_spotlight()
#endregion


#region Input Filters


func _filter_block_keyboard(event: InputEvent) -> void:
	if event is InputEventKey:
		get_viewport().set_input_as_handled()


func _filter_block_deselect(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_X:
			get_viewport().set_input_as_handled()

#func _unhandled_input(event: InputEvent) -> void:
	#if event is InputEventMouseButton and event.pressed:
		#_filter_block_place_demon_and_deselect(event)

func _filter_block_place_demon_and_deselect(event: InputEvent) -> void:
	
	if event is InputEventMouseButton and event.pressed:
		print("TRYING TO FILTER INPUT")
		if get_viewport().is_input_handled():
			print(event, " Event WAS Handled")
			pass
		else:
			print(event, " Event WAS NOT Handled")
			get_viewport().set_input_as_handled()
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_X:
			get_viewport().set_input_as_handled()
#endregion


#region Signal Handlers
func _on_tooltip_hidden() -> void:
	#hide_spotlight()

	match get_current_step_name():
		"EXPLAIN_OCCULUM":
			go_to_step("FORCE_SELECT_OCCULUM")
		"EXPLAIN_BLOOD_BUFFS":
			get_tree().paused = false
			#print("Advancing Tutorial2 1")
			advance_tutorial() # → EXPLAIN_BLOOD_BUFFS_2

		"EXPLAIN_BLOOD_BUFFS_2":
			get_tree().paused = false
			#hbox.get_node("WorldSwap").visible = true
			demonSelectionMenu.get_world_swap_button().show()
			#print("Advancing Tutorial3 1")
			advance_tutorial() # → WAVE_1_ACTIVE

		"EXPLAIN_BUCKETHEAD_ZOMBIE":
			get_tree().paused = false
			# No transition — wait for wave3Started signal

		"FORCE_PLACE_CRAWLER_BEHIND":
			# Error tooltip acknowledged — player retries placement
			get_tree().paused = false


func _on_occulum_button_pressed() -> void:
	if get_current_step_name() == "FORCE_SELECT_OCCULUM":
		#print("Advancing Tutorial12 1")
		advance_tutorial() # → FORCE_PLACE_OCCULUM


func _on_occulum_placed(grid_pos: Vector2) -> void:
	print("OCCULUM PLACED")
	if get_current_step_name() != "FORCE_PLACE_OCCULUM":
		return

	tutorial_occulum_grid_pos = grid_pos

	# Wait for occulum to instantiate, then force blood generation
	await get_tree().create_timer(0.3).timeout

	var occulums := get_tree().get_nodes_in_group("Demons")
	#print("occulums is ", occulums)
	for demon in occulums:
		#print("DEMON IS ", demon)
		if "Occulum" in demon.name:
			#print("OCCULUM FOUND")
			tutorial_occulum = demon
			break

	if tutorial_occulum and tutorial_occulum.has_method("generate_blood"):
		advance_tutorial() # → EXPLAIN_BLOOD_GENERATION
		tutorial_blood_instance = tutorial_occulum.force_generate_blood()
		print("Should Generate Blood ")

		if tutorial_blood_instance and tutorial_blood_instance.has_node("Auto_pick_up_timer"):
			tutorial_blood_instance.get_node("Auto_pick_up_timer").stop()

		await get_tree().create_timer(0.15).timeout
		if tutorial_blood_instance:
			#TODO Add Highlight
			pass
			#show_spotlight_at_position(tutorial_blood_instance.global_position, 0.12)
	#print("Advancing Tutorial 222222")
#	advance_tutorial() # → EXPLAIN_BLOOD_GENERATION


func _on_crawler_button_pressed() -> void:
	if get_current_step_name() == "FORCE_SELECT_CRAWLER":
		#print("Advancing7 Tutorial 12222222222222232132323424")
		advance_tutorial() # → FORCE_PLACE_CRAWLER_BEHIND


func _on_crawler_placed(grid_pos: Vector2) -> void:
	
	if get_current_step_name() != "FORCE_PLACE_CRAWLER_BEHIND":
		print("Current Step Is ", get_current_step_name())
		return
	else:
		print("Current Step Is " , get_current_step_name())
	if crawler_placed == false:
		var expected_pos_1 := tutorial_occulum_grid_pos - Vector2(32, 0)
		var expected_pos_2 := tutorial_occulum_grid_pos - Vector2(64, 0)
	
		if grid_pos != expected_pos_1 && grid_pos != expected_pos_2:
			# Invalid placement — delete, refund, show error, let player retry
			await get_tree().create_timer(0.15).timeout
			demonManager.clear_space(grid_pos)
			demonManager.add_blood(50)
			get_tree().paused = true
			toolTips.set_basic_tutorial_text(TUTORIAL_INVALID_CRAWLER, true)
			#TODO Add Highlight
			#show_spotlight_at_position(expected_pos, 0.12)
		else:
			#print("Advancing Tutorial 91")
			crawler_placed = true
		await get_tree().create_timer(0.3).timeout
		var crawlers := get_tree().get_nodes_in_group("Demons")
		#print("Crawler is ", occulums)
		#print("All CHuhDemons is ", crawlers)
		for demon in crawlers:
			#print("Looking for Crawler, DEMON IS ", demon)
			if demon.name.contains("Crawler"):
				#print("Crawler demon is ", demon)
				tutorial_crawler = demon
				break

		advance_tutorial() # → EXPLAIN_BLOOD_BUFFS


func _on_spinalOcculum_button_pressed() -> void:
	if get_current_step_name() == "FORCE_SELECT_SPINALOCCULUM":
		#print("Advancing Tutorial 1Nut")
		advance_tutorial() # → FORCE_PLACE_SPINALOCCULUM


func _on_spinalOcculum_placed(grid_pos: Vector2) -> void:
	if get_current_step_name() == "FORCE_PLACE_SPINALOCCULUM":
		toolTips.hide()
		#show_only_demon_buttons(["Occulum", "Crawler", "Spinal-Occulum"])
		hide_all_demon_buttons_with_exception(["Occulum", "Crawler", "SpinalOcculum"])


func _on_wave_started(wave_index: int) -> void:
	match wave_index:
		0:
			print("Sussy1")
			#show_only_demon_buttons(["Occulum", "Crawler"])
			hide_all_demon_buttons_with_exception(["Occulum", "Crawler"])
			wave_1_active = true
		1:
			go_to_step("EXPLAIN_BUCKETHEAD_ZOMBIE")
		2:
			go_to_step("FORCE_SELECT_SPINALOCCULUM")
#endregion


#region Blood Pickup Detection
func _physics_process(_delta: float) -> void:
	if waiting_for_blood and demonManager.blood_points > blood_before_pickup:
		waiting_for_blood = false
		toolTips.hide()
		#hide_spotlight()
		get_tree().paused = false
		#print("Advancing Tutorial 1")
		advance_tutorial() # → FORCE_SELECT_CRAWLER
#endregion


#region UI Helpers
func setup_demon_selection_menu() -> void:
	hide_all_demon_buttons_with_exception(["Occulum"])


func show_only_demon_buttons(visible_containers: Array) -> void:
	for container_name in ALL_DEMON_CONTAINERS:
		var container := hbox.get_node(container_name)
		var should_show :bool= container_name in visible_containers
		for child in container.get_children():
			child.visible = should_show



func show_guide() -> void:
	$GameLayer/GridManager/TileMapLayer.place_rectangles_on_rows(3, 5)
#endregion

func get_true_name() -> String:
	return "Level0-2"


			
			
			
