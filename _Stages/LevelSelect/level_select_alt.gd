extends Control


var canPlayLevel2 := false
var canPlayLevel3 := false
var canPlayLevel4 := false
var canPlayLevel5 := false
var canPlayLevel6 := false
var canPlayLevel7 := false

var startScreen := ("res://_Stages/StartScreen/StartScreen.tscn")
var level_select := "res://_Stages/LevelSelect/level_select.tscn"



var level0_1 := ("res://_Stages/Level1/Level0-1.tscn")
var level0_1Alt := ("res://_Stages/Level1/Level0-1_Alternate.tscn")
var level0_2 := ("res://_Stages/Level2/Level0-2.tscn")
var level0_2Alt := ("res://_Stages/Level2/Level0-2_Alternate.tscn")


var level0_3 := ("res://_Stages/Level2/Level0-3B.tscn")
var level0_3Alt := ("res://_Stages/Level3/Level0-3_Alternate_B.tscn")


#var level0_3 := ("res://_Stages/Level3/Level0-3.tscn")
#var level0_3Alt := ("res://_Stages/Level3/Level0-3_Alternate.tscn")
var level0_4 := ("res://_Stages/Level4/Level0-4.tscn")
var level0_4Alt := ("res://_Stages/Level4/Level0-4_Alternate.tscn")
var level0_5 := ("res://_Stages/Level5/Level0-5.tscn")
var level0_5Alt := ("res://_Stages/Level5/Level0-5_Alternate.tscn")
var level0_6 := ("res://_Stages/Level6/Level0-6.tscn")
var level0_6Alt := ("res://_Stages/Level6/Level0-6_Alternate.tscn")
var level7 := ("res://_Stages/Level7/Level7.tscn")
var level7_alt := ("res://_Stages/Level7/Level7_Alternate.tscn")
var level8 := "res://_Stages/Level8/Level8.tscn"
var level8_alt := "res://_Stages/Level8/Level8_Alternate.tscn"
var level9 := "res://_Stages/Level9/Level9.tscn"
var level9_alt := "res://_Stages/Level9/Level9_Alternate.tscn"

var level_jason := "res://_Stages/Level_Jason_Testing/Level_Jason_Testing.tscn"
var level_jason_alt := "res://_Stages/Level_Jason_Testing/Level_Jason_Testing_Alternate.tscn"

var level_Gus_1 := ("res://_Stages/Level-Testing/TestLevel1/Level_Gus_1.tscn")
var level_Gus_1_alt := ("res://_Stages/Level-Testing/TestLevel1/Level_Gus_1_Alternate.tscn")

var testing_gus_0 := "res://_Stages/Level-Testing/TestLevel0/Level0-TestingGus.tscn"
var testing_gus_0Alt := "res://_Stages/Level-Testing/TestLevel0/Level0-TestingGus_Alternate.tscn"


var testing_gus_1 := "res://_Stages/Level-Testing/TestLevel0/Level02-TestingGus.tscn"
var testing_gus_1Alt := "res://_Stages/Level-Testing/TestLevel0/Level02-TestingGus_Alternate.tscn"

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

@onready var act_panel_container : PanelContainer = $Acts_MarginContainer/Acts_Hbox/ScrollContainer/Acts_Vbox/Act_1_PanelContainer
@onready var act_scroll_container : ScrollContainer = $Acts_MarginContainer/Acts_Hbox/ScrollContainer

@onready var purple_bg := $BG_Purple
@onready var green_bg := $BG_Green

@onready var level_1_label := $"Acts_MarginContainer/Acts_Hbox/ScrollContainer/Acts_Vbox/Act_1_PanelContainer/Act_1_MarginContainer/Act_1_Vbox/Levels_1-3_Container/Level_1_PanelContainer/Level_Vbox/Level_Label"
@onready var level_2_label := $"Acts_MarginContainer/Acts_Hbox/ScrollContainer/Acts_Vbox/Act_1_PanelContainer/Act_1_MarginContainer/Act_1_Vbox/Levels_1-3_Container/Level_2_PanelContainer/Level_Vbox/Level_Label"
@onready var level_3_label := $"Acts_MarginContainer/Acts_Hbox/ScrollContainer/Acts_Vbox/Act_1_PanelContainer/Act_1_MarginContainer/Act_1_Vbox/Levels_1-3_Container/Level_3_PanelContainer/Level_Vbox/Level_Label"
@onready var level_4_label := $"Acts_MarginContainer/Acts_Hbox/ScrollContainer/Acts_Vbox/Act_1_PanelContainer/Act_1_MarginContainer/Act_1_Vbox/Levels_4-6_Container/Level_4_PanelContainer/Level_Vbox/Level_Label"
@onready var level_5_label := $"Acts_MarginContainer/Acts_Hbox/ScrollContainer/Acts_Vbox/Act_1_PanelContainer/Act_1_MarginContainer/Act_1_Vbox/Levels_4-6_Container/Level_5_PanelContainer/Level_Vbox/Level_Label"
@onready var level_6_label := $"Acts_MarginContainer/Acts_Hbox/ScrollContainer/Acts_Vbox/Act_1_PanelContainer/Act_1_MarginContainer/Act_1_Vbox/Levels_4-6_Container/Level_6_PanelContainer/Level_Vbox/Level_Label"
@onready var level_7_label := $"Acts_MarginContainer/Acts_Hbox/ScrollContainer/Acts_Vbox/Act_1_PanelContainer/Act_1_MarginContainer/Act_1_Vbox/Levels_7-9_Container/Level_7_PanelContainer/Level_Vbox/Level_Label"
@onready var level_8_label := $"Acts_MarginContainer/Acts_Hbox/ScrollContainer/Acts_Vbox/Act_1_PanelContainer/Act_1_MarginContainer/Act_1_Vbox/Levels_7-9_Container/Level_8_PanelContainer/Level_Vbox/Level_Label"
@onready var level_9_label := $"Acts_MarginContainer/Acts_Hbox/ScrollContainer/Acts_Vbox/Act_1_PanelContainer/Act_1_MarginContainer/Act_1_Vbox/Levels_7-9_Container/Level_9_PanelContainer/Level_Vbox/Level_Label"

@onready var level_1_image_earth := $"Acts_MarginContainer/Acts_Hbox/ScrollContainer/Acts_Vbox/Act_1_PanelContainer/Act_1_MarginContainer/Act_1_Vbox/Levels_1-3_Container/Level_1_PanelContainer/Level_Vbox/LevelMarginContainer/LevelPanelContainer/LevelTexture"
@onready var level_1_image_syn := $"Acts_MarginContainer/Acts_Hbox/ScrollContainer/Acts_Vbox/Act_1_PanelContainer/Act_1_MarginContainer/Act_1_Vbox/Levels_1-3_Container/Level_1_PanelContainer/Level_Vbox/LevelMarginContainer/LevelPanelContainer/LevelTextureAlt"

@onready var level_2_image_earth := $"Acts_MarginContainer/Acts_Hbox/ScrollContainer/Acts_Vbox/Act_1_PanelContainer/Act_1_MarginContainer/Act_1_Vbox/Levels_1-3_Container/Level_2_PanelContainer/Level_Vbox/LevelMarginContainer/LevelPanelContainer/LevelTexture"
@onready var level_2_image_syn := $"Acts_MarginContainer/Acts_Hbox/ScrollContainer/Acts_Vbox/Act_1_PanelContainer/Act_1_MarginContainer/Act_1_Vbox/Levels_1-3_Container/Level_2_PanelContainer/Level_Vbox/LevelMarginContainer/LevelPanelContainer/LevelTextureAlt"

@onready var level_3_image_earth := $"Acts_MarginContainer/Acts_Hbox/ScrollContainer/Acts_Vbox/Act_1_PanelContainer/Act_1_MarginContainer/Act_1_Vbox/Levels_1-3_Container/Level_3_PanelContainer/Level_Vbox/LevelMarginContainer/LevelPanelContainer/LevelTexture"
@onready var level_3_image_syn := $"Acts_MarginContainer/Acts_Hbox/ScrollContainer/Acts_Vbox/Act_1_PanelContainer/Act_1_MarginContainer/Act_1_Vbox/Levels_1-3_Container/Level_3_PanelContainer/Level_Vbox/LevelMarginContainer/LevelPanelContainer/LevelTextureAlt"

@onready var level_4_image_earth := $"Acts_MarginContainer/Acts_Hbox/ScrollContainer/Acts_Vbox/Act_1_PanelContainer/Act_1_MarginContainer/Act_1_Vbox/Levels_4-6_Container/Level_4_PanelContainer/Level_Vbox/LevelMarginContainer/LevelPanelContainer/LevelTexture"
@onready var level_4_image_syn := $"Acts_MarginContainer/Acts_Hbox/ScrollContainer/Acts_Vbox/Act_1_PanelContainer/Act_1_MarginContainer/Act_1_Vbox/Levels_4-6_Container/Level_4_PanelContainer/Level_Vbox/LevelMarginContainer/LevelPanelContainer/LevelTextureAlt"

@onready var level_5_image_earth := $"Acts_MarginContainer/Acts_Hbox/ScrollContainer/Acts_Vbox/Act_1_PanelContainer/Act_1_MarginContainer/Act_1_Vbox/Levels_4-6_Container/Level_5_PanelContainer/Level_Vbox/LevelMarginContainer/LevelPanelContainer/LevelTexture"
@onready var level_5_image_syn := $"Acts_MarginContainer/Acts_Hbox/ScrollContainer/Acts_Vbox/Act_1_PanelContainer/Act_1_MarginContainer/Act_1_Vbox/Levels_4-6_Container/Level_5_PanelContainer/Level_Vbox/LevelMarginContainer/LevelPanelContainer/LevelTextureAlt"

@onready var level_6_image_earth := $"Acts_MarginContainer/Acts_Hbox/ScrollContainer/Acts_Vbox/Act_1_PanelContainer/Act_1_MarginContainer/Act_1_Vbox/Levels_4-6_Container/Level_6_PanelContainer/Level_Vbox/LevelMarginContainer/LevelPanelContainer/LevelTexture"
@onready var level_6_image_syn := $"Acts_MarginContainer/Acts_Hbox/ScrollContainer/Acts_Vbox/Act_1_PanelContainer/Act_1_MarginContainer/Act_1_Vbox/Levels_4-6_Container/Level_6_PanelContainer/Level_Vbox/LevelMarginContainer/LevelPanelContainer/LevelTextureAlt"

@onready var level_7_image_earth := $"Acts_MarginContainer/Acts_Hbox/ScrollContainer/Acts_Vbox/Act_1_PanelContainer/Act_1_MarginContainer/Act_1_Vbox/Levels_7-9_Container/Level_7_PanelContainer/Level_Vbox/LevelMarginContainer/LevelPanelContainer/LevelTexture"
@onready var level_7_image_syn := $"Acts_MarginContainer/Acts_Hbox/ScrollContainer/Acts_Vbox/Act_1_PanelContainer/Act_1_MarginContainer/Act_1_Vbox/Levels_7-9_Container/Level_7_PanelContainer/Level_Vbox/LevelMarginContainer/LevelPanelContainer/LevelTextureAlt"

@onready var level_8_image_earth := $"Acts_MarginContainer/Acts_Hbox/ScrollContainer/Acts_Vbox/Act_1_PanelContainer/Act_1_MarginContainer/Act_1_Vbox/Levels_7-9_Container/Level_8_PanelContainer/Level_Vbox/LevelMarginContainer/LevelPanelContainer/LevelTexture"
@onready var level_8_image_syn := $"Acts_MarginContainer/Acts_Hbox/ScrollContainer/Acts_Vbox/Act_1_PanelContainer/Act_1_MarginContainer/Act_1_Vbox/Levels_7-9_Container/Level_8_PanelContainer/Level_Vbox/LevelMarginContainer/LevelPanelContainer/LevelTextureAlt"

@onready var level_9_image_earth := $"Acts_MarginContainer/Acts_Hbox/ScrollContainer/Acts_Vbox/Act_1_PanelContainer/Act_1_MarginContainer/Act_1_Vbox/Levels_7-9_Container/Level_9_PanelContainer/Level_Vbox/LevelMarginContainer/LevelPanelContainer/LevelTexture"
@onready var level_9_image_syn := $"Acts_MarginContainer/Acts_Hbox/ScrollContainer/Acts_Vbox/Act_1_PanelContainer/Act_1_MarginContainer/Act_1_Vbox/Levels_7-9_Container/Level_9_PanelContainer/Level_Vbox/LevelMarginContainer/LevelPanelContainer/LevelTextureAlt"



@onready var open_level_screen := $OpenLevel

var level_1_description := "res://_Assets/Text/TextFiles/Level_Descriptions/Level_1_Description.txt"
var level_2_description := "res://_Assets/Text/TextFiles/Level_Descriptions/Level_2_Description.txt"
var level_3_description := "res://_Assets/Text/TextFiles/Level_Descriptions/Level_3_Description.txt"
var level_4_description := "res://_Assets/Text/TextFiles/Level_Descriptions/Level_4_Description.txt"
var level_5_description := "res://_Assets/Text/TextFiles/Level_Descriptions/Level_5_Description.txt"
var level_6_description := "res://_Assets/Text/TextFiles/Level_Descriptions/Level_6_Description.txt"
var level_7_description := "res://_Assets/Text/TextFiles/Level_Descriptions/Level_7_Description.txt"
var level_8_description := "res://_Assets/Text/TextFiles/Level_Descriptions/Level_8_Description.txt"
var level_9_description := "res://_Assets/Text/TextFiles/Level_Descriptions/Level_9_Description.txt"



func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	canPlayLevel2 = Global.getCanPlayLevel2()
	canPlayLevel3 = Global.getCanPlayLevel3()
	canPlayLevel4 = Global.getCanPlayLevel4()
	canPlayLevel5 = Global.getCanPlayLevel5()
	canPlayLevel6 = Global.getCanPlayLevel6()
	canPlayLevel7 = Global.getCanPlayLevel7()
	
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

func get_level_title(level_num:int)->String:
	match level_num:
		1:
			return level_1_label.text
		1:
			return level_2_label.text
		1:
			return level_3_label.text
		1:
			return level_4_label.text
		1:
			return level_5_label.text
		1:
			return level_6_label.text
		1:
			return level_7_label.text
		1:
			return level_8_label.text
		1:
			return level_9_label.text
			
	return level_1_label.text


	
func set_level_details(level_number:int)->void:
	#open_level_screen.set_level_title(get_level_title(level_number))
	#open_level_screen.set_level_description(get_level_description(level_number))
	#open_level_screen.set_level_images(get_level_images(level_number))
	open_level_screen.show()
	act_scroll_container.modulate = Color(1,1,1,0)
	match level_number:
		1:
			open_level_screen.set_level_title(level_1_label.text)
			open_level_screen.set_level_description(level_1_description)
			open_level_screen.set_level_images(level_1_image_earth,level_1_image_syn)
			open_level_screen.set_levels(level0_1,level0_1Alt)
		2:
			open_level_screen.set_level_title(level_2_label.text)
			open_level_screen.set_level_description(level_2_description)
			open_level_screen.set_level_images(level_2_image_earth,level_2_image_syn)
			open_level_screen.set_levels(level0_2,level0_2Alt)
		3:
			open_level_screen.set_level_title(level_3_label.text)
			open_level_screen.set_level_description(level_3_description)
			open_level_screen.set_level_images(level_3_image_earth,level_3_image_syn)
			open_level_screen.set_levels(level0_3,level0_3Alt)
		4:
			open_level_screen.set_level_title(level_4_label.text)
			open_level_screen.set_level_description(level_4_description)
			open_level_screen.set_level_images(level_6_image_earth,level_6_image_syn)
			open_level_screen.set_levels(level0_4,level0_4Alt)
		5:
			open_level_screen.set_level_title(level_5_label.text)
			open_level_screen.set_level_description(level_5_description)
			open_level_screen.set_level_images(level_5_image_earth,level_5_image_syn)
			open_level_screen.set_levels(level0_5,level0_5Alt)
		6:
			open_level_screen.set_level_title(level_6_label.text)
			open_level_screen.set_level_description(level_6_description)
			open_level_screen.set_level_images(level_6_image_earth,level_6_image_syn)
			open_level_screen.set_levels(level0_6,level0_6Alt)
		7:
			open_level_screen.set_level_title(level_7_label.text)
			open_level_screen.set_level_description(level_7_description)
			open_level_screen.set_level_images(level_7_image_earth,level_7_image_syn)
			open_level_screen.set_levels(level7,level7_alt)
		8:
			open_level_screen.set_level_title(level_8_label.text)
			open_level_screen.set_level_description(level_8_description)
			open_level_screen.set_level_images(level_8_image_earth,level_8_image_syn)
			open_level_screen.set_levels(level8,level8_alt)
		9:
			open_level_screen.set_level_title(level_9_label.text)
			open_level_screen.set_level_description(level_9_description)
			open_level_screen.set_level_images(level_9_image_earth,level_9_image_syn)
			open_level_screen.set_levels(level9,level9_alt)



	
func _on_level_1_pressed() -> void:
	set_level_details(1)
	
	#Global.game_controller.change_dual_scenes(level0_1,level0_1Alt)

	


func _on_level_2_pressed() -> void:
	if canPlayLevel2:
		#assert(get_tree().change_scene_to_file(level2) ==OK)
		#Global.game_controller.change_scene(level2)
		Global.game_controller.change_dual_scenes(level0_2, level0_2Alt)



func _on_level_3_pressed() -> void:
	if canPlayLevel3:
		#assert(get_tree().change_scene_to_file(level3) ==OK)
		Global.game_controller.change_dual_scenes(level0_3, level0_3Alt)


func _on_level_4_pressed() -> void:
	if canPlayLevel4:
		#assert(get_tree().change_scene_to_file(level4) ==OK)
		Global.game_controller.change_dual_scenes(level0_4, level0_4Alt)


func _on_level_5_pressed() -> void:
	if canPlayLevel5:
		#assert(get_tree().change_scene_to_file(level5) ==OK)
		Global.game_controller.change_dual_scenes(level0_5, level0_5Alt)



func _on_level_6_pressed() -> void:
	if canPlayLevel6:
		#assert(get_tree().change_scene_to_file(level6) ==OK)
		Global.game_controller.change_dual_scenes(level0_6, level0_6Alt)

func _on_level_7_button_pressed() -> void:
	Global.game_controller.change_dual_scenes(level8, level8_alt)
	



func _on_back_pressed() -> void:
	Global.game_controller.change_scene(startScreen)


func _on_testing_gus_button_0_pressed() -> void:
	Global.game_controller.change_dual_scenes(testing_gus_0, testing_gus_0Alt)


func _on_testing_gus_button_1_pressed() -> void:
	Global.game_controller.change_dual_scenes(testing_gus_1, testing_gus_1Alt)




func _on_test_gus_level_1_pressed() -> void:
	Global.game_controller.change_dual_scenes(level_Gus_1, level_Gus_1_alt)


func _on_level_8_pressed() -> void:
	Global.game_controller.change_dual_scenes(level7, level7_alt)


func _on_level_9_pressed() -> void:
	Global.game_controller.change_dual_scenes(level9, level9_alt)
	
	
	
	
	
	
	
	##


func _on_level_jason_testing_pressed() -> void:
	Global.game_controller.change_dual_scenes(level_jason, level_jason_alt)


func _on_current_sorcery_button_pressed() -> void:
	Global.game_controller.change_scene(ability_screen)


func _on_back_button_pressed() -> void:
	Global.game_controller.change_scene(level_select)
