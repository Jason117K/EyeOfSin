extends Control


var startScreen := ("res://_Stages/StartScreen/StartScreen.tscn")
var level_select := "res://_Stages/LevelSelect/level_select.tscn"


var ability_screen := "res://_UI/ability_control_panel.tscn"

var all_panel_containers : Array = []
var show_green := false

@onready var swap_icon := $Acts_MarginContainer/Acts_Hbox/Loadout_Vbox/MarginContainer/DemonPanelContainer/MarginContainer/LoadOutVboxes/AbilitiesVbox/SwapPanelContainer/SwapMarginContainer/SwapSorcery
@onready var syn_icon := $Acts_MarginContainer/Acts_Hbox/Loadout_Vbox/MarginContainer/DemonPanelContainer/MarginContainer/LoadOutVboxes/AbilitiesVbox/SynPanelContainer/SynMarginContainer/SynSorcery

@onready var crawler_icon := $Acts_MarginContainer/Acts_Hbox/Loadout_Vbox/MarginContainer/DemonPanelContainer/MarginContainer/LoadOutVboxes/DemonVbox/DemonGridContainer/Crawler
@onready var occulum_icon := $Acts_MarginContainer/Acts_Hbox/Loadout_Vbox/MarginContainer/DemonPanelContainer/MarginContainer/LoadOutVboxes/DemonVbox/DemonGridContainer/Occulum
@onready var spinal_occulum_icon := $Acts_MarginContainer/Acts_Hbox/Loadout_Vbox/MarginContainer/DemonPanelContainer/MarginContainer/LoadOutVboxes/DemonVbox/DemonGridContainer/SpinalOcculum
@onready var wyrm_icon := $Acts_MarginContainer/Acts_Hbox/Loadout_Vbox/MarginContainer/DemonPanelContainer/MarginContainer/LoadOutVboxes/DemonVbox/DemonGridContainer/Wyrm
@onready var maw_icon := $Acts_MarginContainer/Acts_Hbox/Loadout_Vbox/MarginContainer/DemonPanelContainer/MarginContainer/LoadOutVboxes/DemonVbox/DemonGridContainer/Maw
@onready var hive_icon := $Acts_MarginContainer/Acts_Hbox/Loadout_Vbox/MarginContainer/DemonPanelContainer/MarginContainer/LoadOutVboxes/DemonVbox/DemonGridContainer/Hive

@onready var green_earth := $GreenEarth
@onready var purple_earth := $PurpleEarth

@onready var act_panel_container : PanelContainer = $Acts_MarginContainer/Acts_Hbox/ScrollContainer/Acts_Vbox/Act_2_PanelContainer

@onready var purple_bg := $BG_Purple
@onready var green_bg := $BG_Green


var level_10 := ("res://_Stages/Level10/Level10.tscn")
var level_10_alt := ("res://_Stages/Level10/Level10_Alternate.tscn")

var level_11 := ("res://_Stages/Level11/Level11.tscn")
var level_11_alt := ("res://_Stages/Level11/Level11_Alternate.tscn")

var level_12 := ("res://_Stages/Level12/Level12.tscn")
var level_12_alt := ("res://_Stages/Level12/Level12_Alternate.tscn")

var level_13 := ("res://_Stages/Level13/Level13.tscn")
var level_13_alt := ("res://_Stages/Level13/Level13_Alternate.tscn")

var level_14 := ("res://_Stages/Level14/Level14.tscn")
var level_14_alt := ("res://_Stages/Level14/Level14_Alternate.tscn")



func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	Global.hideDemonSelectionMenu()
	swap_icon.texture = Global.get_swap_icon()
	syn_icon.texture = Global.get_syn_icon()
	
	Global.swap_scenes_signal.connect(swap_textures)
	
	assemble_panel_containers(self)
	set_demon_unlocks()
	
	
	
func set_demon_unlocks()->void:
	crawler_icon.visible = Global.crawler_unlocked
	occulum_icon.visible = Global.occulum_unlocked
	spinal_occulum_icon.visible = Global.spinal_occulum_unlocked
	wyrm_icon.visible = Global.wyrm_unlocked
	maw_icon.visible = Global.maw_unlocked
	hive_icon.visible = Global.hive_unlocked
	

func assemble_panel_containers(given_node : Node)->void:
	for node in given_node.get_children():
		if node.name == "LevelPanelContainer":
			all_panel_containers.append(node)
		assemble_panel_containers(node)
		
	
	
func swap_textures()->void:
	show_green = !show_green
	
	for panel_container:PanelContainer in all_panel_containers:
		if show_green:
			panel_container.get_child(0).show()
			panel_container.get_child(1).hide()
			green_earth.visible = true 
			purple_earth.visible = false
			act_panel_container.get_theme_stylebox("panel").bg_color = Color("00240ab5")
			purple_bg.hide()
			green_bg.show()
		elif !show_green:
			panel_container.get_child(0).hide()
			panel_container.get_child(1).show()
			green_earth.visible = false 
			purple_earth.visible = true
			act_panel_container.get_theme_stylebox("panel").bg_color = Color("2400309b")
			purple_bg.show()
			green_bg.hide()
	


func _on_back_pressed() -> void:
	Global.game_controller.change_scene(startScreen)


func _on_current_sorcery_button_pressed() -> void:
	Global.game_controller.change_scene(ability_screen)


func _on_back_button_pressed() -> void:
	Global.game_controller.change_scene(level_select)


func _on_level_1_button_pressed() -> void:
	Global.game_controller.change_dual_scenes(level_10,level_10_alt)


func _on_level_2_button_pressed() -> void:
	Global.game_controller.change_dual_scenes(level_11,level_11_alt)


func _on_level_3_button_pressed() -> void:
	Global.game_controller.change_dual_scenes(level_12,level_12_alt)


func _on_level_4_button_pressed() -> void:
	Global.game_controller.change_dual_scenes(level_13,level_13_alt)


func _on_level_5_button_pressed() -> void:
	Global.game_controller.change_dual_scenes(level_14,level_14_alt)
