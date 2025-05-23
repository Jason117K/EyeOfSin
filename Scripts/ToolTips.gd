extends PanelContainer

@onready var label_text = $VBoxContainer/RichTextLabel
@onready var popup_image = $VBoxContainer/CenterContainer/TextureRect
var redColor := "Red"

@export var bloodTutorial = "res://Assets/Text/TextFiles/BloodTutorial.tres"
#var file = File.new()
#var currentFile
#
#
#
#func _on_button_pressed() -> void:
	#hide()
#
#
#func set_text(newFile : String):
	##label_text.set_text(meleeLoreText)
	#
	#show()
	#
	#currentFile = file.open(newFile, File.READ)
	#var newText = file.get_as_text()
	#file.close()
	#
	#label_text.text = newText
	#Node3D
	
func setImage(newImage):
	#TextureRect
	pass
	



func _on_Button_pressed():
	hide()
