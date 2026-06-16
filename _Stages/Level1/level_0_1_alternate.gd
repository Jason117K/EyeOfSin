extends LevelTemplate

@onready var zombie_spawner_green := $GameLayer/ZombieSpawner2Green
@onready var wave_preview := $GameLayer/ZombieSpawner2Green/WavePreview

var wave_1_completed := false
var wave_2_completed := false 

func _ready() -> void:
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
	zombie_spawner_green.set_waves_from_dicts([{}, {"Reborn": 4}, {"Severed": 3}])


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
			
			
func _on_tooltip_hidden() -> void:
	
	toolTips.visible = false 
