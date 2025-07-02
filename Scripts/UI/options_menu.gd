extends Control

var startScreen = ("res://Scenes/LevelScenes/StartScreen.tscn")

func _on_back_button_pressed() -> void:
	print("back button clicked")
	Global.game_controller.change_scene(startScreen)
