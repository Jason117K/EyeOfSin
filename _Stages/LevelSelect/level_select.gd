extends Control


var canPlayLevel2 := false
var canPlayLevel3 := false
var canPlayLevel4 := false
var canPlayLevel5 := false
var canPlayLevel6 := false
var canPlayLevel7 := false

var startScreen := ("res://_Stages/StartScreen/StartScreen.tscn")



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

var testing_gus_0 := "res://_Stages/Level-Testing/TestLevel0/Level0-TestingGus.tscn"
var testing_gus_0Alt := "res://_Stages/Level-Testing/TestLevel0/Level0-TestingGus_Alternate.tscn"


var testing_gus_1 := "res://_Stages/Level-Testing/TestLevel0/Level02-TestingGus.tscn"
var testing_gus_1Alt := "res://_Stages/Level-Testing/TestLevel0/Level02-TestingGus_Alternate.tscn"

var ability_screen := "res://_UI/ability_control_panel.tscn"
@onready var swap_icon := $SorceryPanel/MarginContainer/VBoxContainer/SwapSorcery
@onready var syn_icon := $SorceryPanel/MarginContainer/VBoxContainer/SynSorcery

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
	
	
	
	
	#$GridManager.set_tiles_for_rows(0,1, 68)
	#$GridManager.set_tiles_for_rows(1,2, 66)
	#
	#$GridManager.set_tiles_for_rows(2,3, 63)
	#$GridManager.set_tiles_for_rows(3,4, 63)
	#$GridManager.set_tiles_for_rows(4,5, 63)
	#$GridManager.set_tiles_for_rows(5,6, 63)
	#$GridManager.set_tiles_for_rows(6,7, 63)
	#
	#$GridManager.set_tiles_for_rows(7,8, 66)
	#$GridManager.set_tiles_for_rows(8,9, 69)



func _on_level_1_pressed() -> void:
	#assert(get_tree().change_scene_to_file(level1) ==OK)
	#Global.game_controller.change_scene(level1)
	Global.game_controller.change_dual_scenes(level0_1,level0_1Alt)

	


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





func _on_back_pressed() -> void:
	Global.game_controller.change_scene(startScreen)


func _on_testing_gus_button_0_pressed() -> void:
	Global.game_controller.change_dual_scenes(testing_gus_0, testing_gus_0Alt)


func _on_testing_gus_button_1_pressed() -> void:
	Global.game_controller.change_dual_scenes(testing_gus_1, testing_gus_1Alt)


func _on_button_pressed() -> void:
	Global.game_controller.change_scene(ability_screen)
