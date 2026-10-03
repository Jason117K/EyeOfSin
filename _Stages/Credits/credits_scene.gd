extends Control

@onready var creditsText := $CenterContainer/VBoxContainer/RichTextLabel

var startScreen := ("res://_Stages/StartScreen/StartScreen.tscn")

func _ready() -> void:
	creditsText.append_text("Creative Director : Jason King\n")
	creditsText.append_text("Producer : Darrow Mohammadi-hall\n")
	creditsText.append_text("Marketing Lead: Meg Thurmeier\n")
	creditsText.append_text("Gameplay Designers : Augustus Sabino, Jason King\n")
	creditsText.append_text("Art: Tobi, Jason King, Ren Grunberg (Capsule Art)\n")
	creditsText.append_text("Writers : Meg Thurmeier., Jason King\n")
	creditsText.append_text("Socials and Marketing Team: Beck Lyons, Dashieel Alexander, Kamryn Driver, Jason King, Barbie\n")
	creditsText.append_text("Music : August Draper, Autumn Kirkpatrick\n")
	creditsText.append_text("SFX : Sourced from Zapsplat\n")
	creditsText.append_text("Asset Packs Used From : Aurora Sprites, Admurin and Penusbmic\n")
	
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


func _on_button_pressed() -> void:
	#print("Change to Start ", startScreen)
	Global.game_controller.change_scene(startScreen)
