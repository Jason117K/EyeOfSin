extends Control

@onready var creditsText := $CenterContainer/VBoxContainer/RichTextLabel

var startScreen = ("res://Scenes/LevelScenes/StartScreen.tscn")

func _ready() -> void:
	creditsText.append_text("Creative Director : Jason King\n")
	creditsText.append_text("Art : Jason King,Admurin, and Penusbmic\n")
	creditsText.append_text("Music : Autumn Kirkpatrick\n")
	creditsText.append_text("SFX : Sourced from Zapsplat")
	$GridManager.set_tiles_for_rows(0,1, 68)
	$GridManager.set_tiles_for_rows(1,2, 66)
	
	$GridManager.set_tiles_for_rows(2,3, 63)
	$GridManager.set_tiles_for_rows(3,4, 63)
	$GridManager.set_tiles_for_rows(4,5, 63)
	$GridManager.set_tiles_for_rows(5,6, 63)
	$GridManager.set_tiles_for_rows(6,7, 63)
	
	$GridManager.set_tiles_for_rows(7,8, 66)
	$GridManager.set_tiles_for_rows(8,9, 69)


func _on_button_pressed() -> void:
	Global.game_controller.change_scene(startScreen)
