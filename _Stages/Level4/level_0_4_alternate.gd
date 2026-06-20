extends LevelTemplate
#500



var purple_dimension: Control

@onready var zombie_spawner_1 := $GameLayer/ZombieSpawner1
@onready var zombie_spawner_2 := $GameLayer/ZombieSpawner2
@onready var zombie_spawner_3 := $GameLayer/ZombieSpawner3
@onready var zombie_spawner_4 := $GameLayer/ZombieSpawner4
@onready var zombie_spawner_5 := $GameLayer/ZombieSpawner5
@onready var zombie_spawner_6 := $GameLayer/ZombieSpawner6
@onready var zombie_spawner_7 := $GameLayer/ZombieSpawner7

const TUTORIAL_EXPLAIN_SYN_ABILITY_5 = "res://_Assets/Text/TextFiles/Tutorial_Explain_Syn_Ability_5.txt"
const TUTORIAL_EXPLAIN_SYN_ABILITY_6 = "res://_Assets/Text/TextFiles/Tutorial_Explain_Syn_Ability_6.txt"
const TUTORIAL_EXPLAIN_SYN_ABILITY_7 = "res://_Assets/Text/TextFiles/Tutorial_Explain_Syn_Ability_7.txt"

var _on_step_6 := false 
var _on_step_7 := false 

func _ready() -> void:
	super()
	hide_all_demon_buttons_with_exception(["Crawler","Occulum","SpinalOcculum"])
	attach_script_to_sway_children()
	_configure_waves()
	#toolTips.ToolTipHid.connect(_on_tooltip_hidden)

func _configure_waves() -> void:
	zombie_spawner_1.set_waves_from_dicts([{"Reborn":6,"Severed":2},
											{"Severed": 5},
											{"Severed": 3, "Unhallower":1}, 
											{"Reborn": 6, "Unhallower": 3, "Reanimator":2}])
	zombie_spawner_2.set_waves_from_dicts([{},
											{"Severed" : 3}, 
											{"Severed": 2, "Reborn": 6}, 
											{"Severed": 2, "Unhallower": 1, "Reanimator" : 1}])
	zombie_spawner_3.set_waves_from_dicts([{},
											{}, 
											{"Reborn": 1, "Severed": 3}, 
											{ "Severed": 9}])
	zombie_spawner_4.set_waves_from_dicts([{"Severed": 4}, 
											{"Severed": 3, "Reborn":5},
											{"Reborn": 4, "Severed": 1}, 
											{"Severed": 6, "Unhallower":2}]) 
	zombie_spawner_5.set_waves_from_dicts([{},
											{}, 
											{"Reborn": 4, "Severed": 1}, 
											{"Severed": 4}])
	zombie_spawner_6.set_waves_from_dicts([{}, 
											{"Severed": 4, "Reborn":9},
											{"Reborn": 4, "Severed": 1}, 
											{"Severed": 8}]) 
	zombie_spawner_7.set_waves_from_dicts([{"Reborn":5,"Severed":2}, 
											{"Severed": 2, "Reborn":6, "Unhallower":1},
											{"Reborn": 4, "Severed": 1, "Reanimator":1}, 
											{"Reborn": 9, "Reanimator":2}])
func getIsGreenDimension() -> bool:
	return isGreenDimension

func start_game() -> void:
	hide_all_demon_buttons_with_exception(["Occulum", "Crawler", "SpinalOcculum"])
	for node in get_parent().get_children():
		if node.has_method("getIsPurpleDimension"):
			purple_dimension = node
	purple_dimension.start_game()

func show_guide() -> void:
	$GameLayer/GridManager/TileMapLayer.place_rectangles_on_rows(3, 11)

func _start_explain_syn_ability_5()->void:
	print("Start Syn 5")
	Global.syn_ability_manager.syn_sorcery_activated.connect(_on_syn_sorcery_activated_again)
	toolTips.set_basic_tutorial_text(TUTORIAL_EXPLAIN_SYN_ABILITY_5,false)

func _on_syn_sorcery_activated_again()->void:
	_start_explain_syn_ability_6()

func _start_explain_syn_ability_6()->void:
	print("Start Syn 6")
	toolTips.set_basic_tutorial_text(TUTORIAL_EXPLAIN_SYN_ABILITY_6,false)
	auto_advance = true 
	set_auto_advance_toolTip(5)
	_on_step_6 = true

#func _on_tooltip_hidden() -> void:
	#if _on_step_6:
		#_start_explain_syn_ability_7()
	#if _on_step_7:
		#toolTips.hide()

func _start_explain_syn_ability_7()->void:
	print("Start Syn 7")
	_on_step_7 = true 
	toolTips.set_basic_tutorial_text(TUTORIAL_EXPLAIN_SYN_ABILITY_7,false)
	#auto_advance = true 
	#set_auto_advance_toolTip(5)



func _pre_start_game()->void:
	print("Hide Tooltips")
	toolTips.hide()
	pass
	
		
func progress_time_passed()->void:
	print("Progress Time Passed ")
	if !_on_step_6:
		_start_explain_syn_ability_6()
	if _on_step_6:
		_start_explain_syn_ability_7()
	#if _on_step_7:
		#toolTips.hide()
	
	
	
	
	
