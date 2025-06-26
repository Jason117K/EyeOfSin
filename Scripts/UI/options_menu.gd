extends Control

var startScreen = ("res://Scenes/LevelScenes/StartScreen.tscn")

func _on_back_button_pressed() -> void:
	Global.game_controller.change_scene(startScreen)
