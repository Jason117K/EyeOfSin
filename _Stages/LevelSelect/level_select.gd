extends Control

var startScreen := ("res://_Stages/StartScreen/StartScreen.tscn")

var act_1_level_select := "res://_Stages/LevelSelect/LevelSelect_A1.tscn"
var act_2_level_select := "res://_Stages/LevelSelect/LevelSelect_A2.tscn"
var act_3_level_select := "res://_Stages/LevelSelect/LevelSelect_A3.tscn"


func _on_act_1_button_pressed() -> void:
	Global.game_controller.change_scene(act_1_level_select)


func _on_act_2_button_pressed() -> void:
	Global.game_controller.change_scene(act_2_level_select)


func _on_act_3_button_pressed() -> void:
	Global.game_controller.change_scene(act_3_level_select)


func _on_back_button_pressed() -> void:
	Global.game_controller.change_scene(startScreen)
