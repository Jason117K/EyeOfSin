extends LevelTemplate

var basic_zombie_demo_scene := preload("res://_UI/GameDemonstrations/ZombieTutorials/basic_zombie_demo.tscn")
var severed_zombie_demo_scene := preload("res://_UI/GameDemonstrations/ZombieTutorials/severed_zombie_demo.tscn")
var wave_1_completed := false
var wave_2_completed := false 
var current_completed_wave_number := 0
var wave3StartTimer: Timer
@export var this_wave_3_start_time := 20

@onready var crawler_button :TextureButton= demonSelectionMenu.get_crawler_button()
@onready var zombie_spawner := $GameLayer/ZombieSpawner

const HIDEABLE_demon_NAMES = ["Occulum", "SpinalOcculum", "Wyrm", "Maw", "Hive", "Heart", "Portal", "WorldSwap"]

@export var debug_wave_2_start_time := 30

@onready var wave_preview := $GameLayer/ZombieSpawner/WavePreview



var first_hover := false
var demon_never_clicked := true 




#region Tutorial Step Definitions (sequential order — read top to bottom)
func _setup_tutorial() -> void:
	define_tutorial_steps([
		{
			"name": "FORCE_SELECT_CRAWLER",
			"enter": _start_force_select_crawler,
			"input_filter": _filter_block_keyboard,
		},
		{
			"name": "FORCE_PLACE_demon",
			"enter": _start_force_place_demon,
			"input_filter": _filter_block_deselect_and_swap,
		},
		{
			"name": "EXPLAIN_BLOOD_COST",
			"enter": _start_explain_blood_cost,
		},
		{
			"name": "EXPLAIN_DEMON_HOVER",
			"enter": _start_explain_demon_hover,
		},
		{
			"name": "EXPLAIN_DEMON_CLICK",
			"enter": _start_explain_demon_click,
		},
		{
			"name":"EXPLAIN_HOVER_SKULL",
			"enter": _start_explain_hover_skull,
			"input_filter": _filter_block_deselect_and_swap,
			
		},
		{
			"name":"EXPLAIN_CLICK_SKULL",
			"enter": _start_explain_click_skull,
			"input_filter": _filter_block_deselect_and_swap,
			
		},
		{
			"name": "WAVE_1_ACTIVE",
			"enter": _start_wave_1,
			"input_filter": _filter_block_swap,
		},
		#{
			#"name": "EXPLAIN_BASIC_ZOMBIE",
			#"enter": _start_explain_basic_zombie,
			#"input_filter": _filter_block_swap,
		#},
		{
			"name": "EXPLAIN_HEALTH",
			"enter": _start_explain_health,
			"input_filter": _filter_block_swap,
		},
		{
			"name": "CONTINUE_WAVE_1",
			"enter": _continue_wave_1,
			"input_filter": _filter_block_swap,
		},
		{
			"name": "FORCE_PRESS_Y",
			"enter": _start_force_press_y,
			"input_filter": _filter_only_allow_y,
		},
		{
			"name": "EXPLAIN_GREEN_DIMENSION",
			"enter": _start_explain_green_dimension,
		},
		{
			"name": "WAVE_2_ACTIVE",
			"enter": _start_wave_2_both_dimensions,
		},
		#{
			#"name": "EXPLAIN_CALL_WAVE_EARLY",
			##"enter": _start_wave_2_both_dimensions,
		#},
		#{
			#"name": "EXPLAIN_SEVERED_ZOMBIE",
			#"enter": _start_explain_severed_zombie,
		#},
	])
#endregion


#region Lifecycle
func _ready() -> void:
	Global.disable_ultimate()
	level_title = "0-1:AWAKENING"
	extended_new_power_description = "GENERATES BLOOD OVER TIME. SYNERGIES IMPROVE BLOOD GENERATION. VITAL FOR ANY DEFENSE."
	super()
	
	#Dialogic.Inputs.auto_skip.enabled = true
	#progress_timer = Timer.new()
	#progress_timer.wait_time = progress_timer_wait_time 
	#progress_timer.timeout.connect(progress_tutorial)
	#progress_timer.one_shot = true 
	#progress_timer.autostart = false 
	
	#unlock_power.hide()
	

	
			
	Dialogic.timeline_ended.connect(finish_ready)

	#Global.current_level = self
	Global.resetOcculumCount()
	Global.reset_swap_ability()

	#waveManager.wave_delays = [-1, -1]
	waveManager.wave_delays = [wave2StartTime,wave3StartTime]

		
	waveManager.wave_started.connect(_on_wave_started)
	#waveManager.level_ended.connect(_on_level_ended)
	wave_preview.game_start_requested.connect(_on_tooltip_hidden)
	wave_preview.hover_over_preview.connect(_on_tooltip_hidden)
	_configure_waves()

	setup_demon_selection_menu()
	pause_Button.set_restart_levels(current_level, current_level_alt)
	process_mode = Node.PROCESS_MODE_ALWAYS

	toolTips.connect("ToolTipHid", Callable(self, "_on_tooltip_hidden"))
	#if not skip_tutorials:
		#toolTips.set_basic_tutorial_text(TUTORIAL_SELECT_CRAWLER, false)

	demonManager.crawler_placed.connect(func(_grid_position): _on_crawler_placed())
	crawler_button.connect("pressed", Callable(self, "_on_crawler_button_pressed"))
 
	toolTips.hide()
	zombie_spawner.wave_exhausted.connect(wave_exhausted)
	
	waveManager.preview_lead_time = 20
	
	Global.hide_ui_layer()
	if debug or skip_tutorials:
		finish_ready()
	else:
		Dialogic.start(level_1_start_dialog)

	#finish_ready()


func _configure_waves() -> void:
	zombie_spawner.set_waves_from_dicts([{"Reborn": 2}, {"Reborn": 4}, {"Reborn": 5, "Severed" : 1}])


func finish_ready() -> void:
	#Global.hide_pip()

	if skip_tutorials:
		waveManager.wave_delays = [debug_wave_2_start_time,wave3StartTime]
		_start_free_play()
		return
	_setup_tutorial()
	zombie_spawner.hide()
	go_to_step("FORCE_SELECT_CRAWLER")
	Global.unhide_ui_layer()
	Global.unHideDemonSelectionMenu()
	


func _start_free_play() -> void:
	hide_all_demon_buttons_with_exception(["Crawler"])
	world_swap_button.visible = true
	demonSelectionMenu.canSwapScenes = true
	waveManager.can_start = true
	Global.show_pip()
	var green := get_parent().get_node("Level0-1_Alternate")
	if green and green.has_method("setup_wave_2_ui"):
		green.setup_wave_2_ui()
	Global.unhide_ui_layer()
	Global.unHideDemonSelectionMenu()

func wave_exhausted() -> void:
	if wave_1_completed:
		zombie_spawner.show_preview_icon.connect(_start_explain_early_wave_call)
		wave_2_completed = true 
		#_start_explain_early_wave_call()
	wave_1_completed = true


#endregion


#region Input
func _input(event: InputEvent) -> void:
	_filter_tutorial_input(event)
#endregion


#region Step Entry Functions (same sequential order as definitions above)
func _start_force_select_crawler() -> void:
	print("Strart FORCE SELECR CRAWLER")
	toolTips.set_basic_tutorial_text(TUTORIAL_SELECT_CRAWLER, false)
	hide_all_demon_buttons_with_exception(["Crawler"])
	#hide_all_demon_buttons_except_crawler()
	if has_pulsed == false:
		highlight_crawler_button()
		has_pulsed = true
	waveManager.can_start = true
	demonSelectionMenu.canSwapScenes = false
	#Global.hide_pip()


func _start_force_place_demon() -> void:
	toolTips.set_basic_tutorial_text(TUTORIAL_PLACE_CRAWLER, false)

	unhighlight_crawler_button()
#	#hide_spotlight()


func _start_explain_blood_cost() -> void:
	toolTips.set_basic_tutorial_text(TUTORIAL_BLOOD_COST, false)
	toolTips.add_pulsing_button_highlight(Global.get_blood_panel())
	print("Set Check Progress True 1 ")
	set_auto_advance_toolTip(3)
	#check_progress = true 

func _start_explain_demon_hover() -> void:
	toolTips.stop_glow_pulse(Global.get_blood_panel())
	toolTips.set_basic_tutorial_text(TUTORIAL_DEMON_HOVER, false)
	set_auto_advance_toolTip(0.1)
	#check_progress = true 
	print("Set Check Progress True 2", check_progress)
	pass

func _start_explain_hover_skull()->void:
	zombie_spawner.show()
	toolTips.set_basic_tutorial_text(TUTORIAL_SKULL_HOVER, false, Vector2(0,-48))

func _start_explain_demon_click()->void:
	toolTips.set_basic_tutorial_text(TUTORIAL_DEMON_CLICK, false)
	pass
	

	
func demon_hover()->void:
	print("Demon Hover", first_hover)
	if first_hover:
		toolTips.hide()
		_on_tooltip_hidden()
		first_hover = false 
	
func progress_time_passed()->void:
	print("Progress Time Passed ")
	match progress_count:
		0:
			print("Hide Button In Progress Time Passed")
			toolTips._on_basic_tutorial_understood_button_pressed()
		1:
			first_hover = true 
	progress_count += 1
	
	
func demon_clicked()->void:
	print("demon clicked")
	if demon_never_clicked:
		toolTips.hide()
		_on_tooltip_hidden()
		demon_never_clicked = false 
		

func _start_explain_click_skull()->void:
	zombie_spawner.show()
	
	toolTips.add_pulsing_button_highlight(zombie_spawner.get_preview_icon_panel())
	toolTips.set_basic_tutorial_text(TUTORIAL_CLICK_SKULL, false, Vector2(0,-48))

func _start_wave_1() -> void:
	print("STAT WAVE !1")
	toolTips.stop_glow_pulse(zombie_spawner.get_preview_icon_panel())
	waveManager.can_start = true
	wave_1_active = false
	wave_1_complete = false


func start_game() -> void:
	_start_wave_1()

func show_zombie_tutorial(unlocked_zombie : String)->void:
	print("Unlocked Zombie Is ", unlocked_zombie)
	match unlocked_zombie:
		"Reborn":
			_start_explain_basic_zombie()
		"Severed":
			_start_explain_severed_zombie()

func _start_explain_basic_zombie() -> void:
	print("Explain Basic Zombie")
	Global.hide_notification_bar()
	toolTips.set_visual_tutorial_text(TUTORIAL_EXPLAIN_BASIC_ZOMBIE)
	toolTips.set_visual_tutorial_visual(basic_zombie_demo_scene.instantiate(),true,Vector2(0,20))

func _start_explain_health()->void:
	toolTips.add_pulsing_button_highlight(Global.get_health_panel())
	toolTips.set_basic_tutorial_text(TUTORIAL_EXPLAIN_HEALTH,true,Vector2(0,-26))

func _continue_wave_1()->void:
	print("Should Stop the Glow Pulse")
	toolTips.stop_glow_pulse(Global.get_health_panel())
	
func _start_force_press_y() -> void:
	demonSelectionMenu.get_world_swap_button().visible = true
	#demonSelectionMenu.get_node("PanelContainer/VBoxContainer/HBoxContainer/WorldSwap").visible = true
	toolTips.set_basic_tutorial_text(TUTORIAL_PRESS_Y, false)


func _start_explain_green_dimension() -> void:
	green_dimension = Global.game_controller.get_green_dimension()
	green_dimension.toolTips.set_basic_tutorial_text(TUTORIAL_GREEN_DIMENSION, true)


func _start_wave_2_both_dimensions() -> void:
	
	Global.show_pip()
	#green_dimension = get_parent().get_node("Level0-1_Alternate")
	if green_dimension and green_dimension.has_method("setup_wave_2_ui"):
		green_dimension.setup_wave_2_ui()

	#waveManager.start_next_wave()
	demonSelectionMenu.canSwapScenes = true
	_start_explain_early_wave_call()

func _start_explain_early_wave_call()->void:
	if wave_2_completed:
		Global.game_controller.get_green_dimension().toolTips.set_basic_tutorial_text(TUTORIAL_EXPLAIN_WAVES,false)
		toolTips.set_basic_tutorial_text(TUTORIAL_EXPLAIN_WAVES,false)
		#toolTips.show_basic_tutorial_button()

func _start_explain_severed_zombie() -> void:
	toolTips.set_visual_tutorial_text(TUTORIAL_EXPLAIN_SEVERED_ZOMBIE)
	toolTips.set_visual_tutorial_visual(severed_zombie_demo_scene.instantiate())

#endregion


#region Input Filters
func _filter_block_keyboard(event: InputEvent) -> void:
	if event is InputEventKey:
		get_viewport().set_input_as_handled()


func _filter_block_deselect_and_swap(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_X or event.keycode == KEY_Y:
			get_viewport().set_input_as_handled()


func _filter_block_swap(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_Y:
			get_viewport().set_input_as_handled()


func _filter_only_allow_y(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_Y:
			Global.swap_scenes()
			#print("Advancing Tutorial Should Explian Green")
			advance_tutorial() # → EXPLAIN_GREEN_DIMENSION
			return
		else:
			get_viewport().set_input_as_handled()
	elif event is InputEventMouseButton:
		get_viewport().set_input_as_handled()
#endregion


#region Signal Handlers
func _on_tooltip_hidden() -> void:
	toolTips.visible = false 
	print("Tooltip Was Hidden, Current Step is ", get_current_step_name() )
	#hide_spotlight()
	match get_current_step_name():
		"EXPLAIN_BLOOD_COST":
			pass
			go_to_step("EXPLAIN_DEMON_HOVER")
		"EXPLAIN_DEMON_HOVER":
			go_to_step("EXPLAIN_DEMON_CLICK")
		"EXPLAIN_DEMON_CLICK":
			print("Should Go To Step Click Skull")
			go_to_step("EXPLAIN_HOVER_SKULL")
		"EXPLAIN_HOVER_SKULL":
			go_to_step("EXPLAIN_CLICK_SKULL")
		"EXPLAIN_CLICK_SKULL":
			go_to_step("WAVE_1_ACTIVE")
		"EXPLAIN_BASIC_ZOMBIE":
			go_to_step("EXPLAIN_HEALTH")
		"EXPLAIN_HEALTH":
			go_to_step("CONTINUE_WAVE_1")
		"EXPLAIN_GREEN_DIMENSION":
			go_to_step("WAVE_2_ACTIVE")
		"WAVE_2_ACTIVE":
			pass


func _on_crawler_placed() -> void:
	if get_current_step_name() == "FORCE_PLACE_demon":
		#print("Advancing YTutorial Here from : ", get_current_step_name())
		advance_tutorial() # → EXPLAIN_BLOOD_COST


func _on_crawler_button_pressed() -> void:
	if get_current_step_name() == "FORCE_SELECT_CRAWLER":
		#print("Advancing WTutorial Here from : ", get_current_step_name())
		advance_tutorial() # → FORCE_PLACE_demon


func _on_wave_started(wave_index: int) -> void:
	if wave_2_completed:
		_on_tooltip_hidden()
	if skip_tutorials:
		return
	print("Wave Starteddd")
	match wave_index:
		0:
			wave_1_active = true
			print("Advacning Tutoiral Should Explain Basic Zomvie / HEALTH FR")
			advance_tutorial() # → EXPLAIN_BASIC_ZOMBIE
		1:
			pass
			#demonManager.add_blood(50)
		2: #Last Wave
			demonManager.add_blood(25)
			#go_to_step("EXPLAIN_SEVERED_ZOMBIE")
			



func _on_demon_manager_crawler_placed(_grid_position: Vector2) -> void:
	_on_crawler_placed()
#endregion


#region Wave Completion Detection
func _physics_process(_delta: float) -> void:
	var step_name := get_current_step_name()
	if step_name == "WAVE_1_ACTIVE" or step_name == "EXPLAIN_BASIC_ZOMBIE" or "CONTINUE_WAVE_1":
		if not wave_1_complete:
			var alive_zombies := get_tree().get_nodes_in_group("Alive-Enemies")

			var purple_zombies: Array = []
			for zombie in alive_zombies:
				if not zombie.is_in_group("Green"):
					purple_zombies.append(zombie)
			if wave_1_completed :
				if purple_zombies.size() == 0 and wave_1_active:
					wave_1_complete = true
					go_to_step("FORCE_PRESS_Y")
#endregion


#region UI Helpers
func setup_demon_selection_menu() -> void:
	print("Demon Selection Menu is ", demonSelectionMenu)
	demonSelectionMenu.get_world_swap_button().visible = false
	#demonSelectionMenu.get_remove_demon_button().visible = false
	demonSelectionMenu.get_codex_button().visible = false
	#TODO Should We Adjust Size Here?
	demonSelectionMenu.get_panel_container().size.x = 71


func highlight_crawler_button() -> void:
	demonSelectionMenu.add_pulsing_button_highlight(crawler_button)


func unhighlight_crawler_button() -> void:
	demonSelectionMenu.remove_button_highlight(crawler_button)
	demonSelectionMenu.stop_glow_pulse(crawler_button)


func show_guide() -> void:
	$GameLayer/GridManager/TileMapLayer.place_rectangles_on_rows(4, 4)
	
#endregion


func progress_tutorial()->void:
	toolTips._on_basic_tutorial_understood_button_pressed()
	pass


func show_unlock_zombie_button(new_zombie_unlocked:String)->void:
	match new_zombie_unlocked:
		"Reborn":
			ui_layer.new_zombie_unlocked_button.show()
			ui_layer.set_zombie_icon_texture(new_zombie_unlocked)
		"Severed":
			ui_layer.new_zombie_unlocked_button.show()
			ui_layer.set_zombie_icon_texture(new_zombie_unlocked)
			






func _on_level_ended() -> void:
	super()
	#if Global.game_controller.get_active_dimension() != Global.game_controller.get_purple_dimension():
		#Global.swap_scenes()
	#new_power_unlock_rune.unlock_done.connect(show_new_demon)
	#new_power_unlock_rune.activate()
	##levelSwitcher.visible = true
	#toolTips.visible = false
	#get_tree().paused = true
	
	
	#if skip_end_dialog:
		#_on_end_dialog_finished()
	#else:
		#Dialogic.timeline_ended.connect(_on_end_dialog_finished, CONNECT_ONE_SHOT)
		#Dialogic.start(new_end_dialog)

		
		
		
		
		
		
		
		
		
		
		
		
		##
