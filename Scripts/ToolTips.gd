extends PanelContainer

@onready var label_text = $VBoxContainer/RichTextLabel
@onready var popup_image = $VBoxContainer/CenterContainer/TextureRect
@onready var anim_texture = $VBoxContainer/CenterContainer/AnimatedTextureRect

signal ToolTipHid


func set_text(newFile : String):
	
	var file = FileAccess.open(newFile, FileAccess.READ)
	var newText = file.get_as_text()
	file.close()
	label_text.text = newText
	

func setAnim(newAnim : SpriteFrames):
	anim_texture.sprites =  newAnim
	anim_texture.playing = true

func noButtonShow():
	show()
	$VBoxContainer/Button.visible = false
	pass
	
func setImage(newImage):
	#TextureRect
	pass
	

func _on_Button_pressed():
	hide()
	ToolTipHid.emit()
