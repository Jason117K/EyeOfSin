extends LevelTemplate

@onready var zombie_spawner_green := $GameLayer/ZombieSpawner2Green
@onready var wave_preview := $GameLayer/ZombieSpawner2Green/WavePreview

var basic_zombie_demo_scene := preload("res://_UI/GameDemonstrations/ZombieTutorials/basic_zombie_demo.tscn")
var severed_zombie_demo_scene := preload("res://_UI/GameDemonstrations/ZombieTutorials/severed_zombie_demo.tscn")
var wave_1_completed := false
var wave_2_completed := false 

func _ready() -> void:
	level_title = "0-1:AWAKENING"
	extended_new_power_description = "GENERATES BLOOD OVER TIME. SYNERGIES IMPROVE BLOOD GENERATION. VITAL FOR ANY DEFENSE."
	super()
	
	hide_all_demon_buttons_with_exception(["Crawler"])
	waveManager.wave_started.connect(_on_wave_started)
	process_mode = Node.PROCESS_MODE_ALWAYS
	#attach_script_to_sway_children()
	attach_script_to_sway_children()
	_configure_waves()
	toolTips.ToolTipHid.connect(Global.game_controller.get_purple_dimension()._on_tooltip_hidden) 
	wave_preview.hover_over_preview.connect(_on_tooltip_hidden)


func _configure_waves() -> void:
	zombie_spawner_green.set_waves_from_dicts([{}, {"Reborn": 4}, {"Severed": 2}])


func setup_wave_2_ui() -> void:
	hide_all_demon_buttons_with_exception(["Crawler"])


func show_guide() -> void:
	$GameLayer/GridManager/TileMapLayer.place_rectangles_on_rows(4, 4)

func wave_exhausted() -> void:
	if wave_1_completed:
		#zombie_spawner.show_preview_icon.connect(_start_explain_early_wave_call)
		wave_2_completed = true 
		#_start_explain_early_wave_call()
	wave_1_completed = true
	
func _on_wave_started(wave_index: int) -> void:

		
	match wave_index:
		0:
			pass
		1:
			pass
			#demonManager.add_blood(50)
		2:
			_on_tooltip_hidden()
			demonManager.add_blood(25)
			
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
	
func _start_explain_severed_zombie() -> void:
	toolTips.set_visual_tutorial_text(TUTORIAL_EXPLAIN_SEVERED_ZOMBIE)
	toolTips.set_visual_tutorial_visual(severed_zombie_demo_scene.instantiate())
	
								
func _on_tooltip_hidden() -> void:
	toolTips.visible = false 


func show_unlock_zombie_button(new_zombie_unlocked:String)->void:
	match new_zombie_unlocked:
		"Reborn":
			ui_layer.new_zombie_unlocked_button.show()
			ui_layer.set_zombie_icon_texture(new_zombie_unlocked)
		"Severed":
			ui_layer.new_zombie_unlocked_button.show()
			ui_layer.set_zombie_icon_texture(new_zombie_unlocked)
			
