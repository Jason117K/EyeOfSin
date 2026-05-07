extends Control

@onready var label_text = $BasicTutorialVbox/BasicTutorialLabel
@onready var popup_image = $BasicTutorialVbox/CenterContainer/TextureRect
@onready var anim_texture = $BasicTutorialVbox/CenterContainer/TextureRect
@onready var button = $BasicTutorialVbox/Button
@onready var complexButton = $ComplexTutorialVBox/VBoxContainer/Button2
@onready var mainVbox = $BasicTutorialVbox
@onready var synergyVBox = $ComplexTutorialVBox
@onready var synergyLabel = $ComplexTutorialVBox/VBoxContainer/ComplexTutorialLabel
@onready var syngergyButton = $ComplexTutorialVBox/VBoxContainer/Button2
@onready var complexSceneContainer = $ComplexTutorialVBox/VBoxContainer
@onready var greyBG = $BasicTutorialVbox/CenterContainer/TextureRect2
@onready var border = $BasicTutorialVbox/CenterContainer/TextureRect3
signal ToolTipHid

var char_count 

#TODO Combine both set text functions

func _ready() -> void:
	#TODO Change Back
	#print("Anim Texture is , ",anim_texture.name )
	visible = false
	anim_texture.visible = false
	greyBG.visible = false
	border.visible = false 
	pass

#Sets the current toolTip Text
func set_text(newFile : String):
	mainVbox.visible = true
	synergyVBox.visible = false 
	var file = FileAccess.open(newFile, FileAccess.READ)
	var newText = file.get_as_text()
	file.close()
	label_text.text = newText
	char_count = newText.length()
	if char_count > 100:
		label_text.add_theme_font_size_override("normal_font_size", 16)
	else:
		label_text.add_theme_font_size_override("normal_font_size", 32)
	#label_text.set_auto_text(newText)

func setComplexSceneText(newFile : String):
	var file = FileAccess.open(newFile, FileAccess.READ)
	var newText = file.get_as_text()
	file.close()
	synergyLabel.text = newText
	
func setComplexSceneTextPause(newFile : String):
	var file = FileAccess.open(newFile, FileAccess.READ)
	var newText = file.get_as_text()
	file.close()
	synergyLabel.text = newText
	print("PAUSE GAM 1E")
	get_tree().paused = true
	pass

#Sets the current toolTip Text while also pausing the game
func set_text_pause(newFile : String):
	mainVbox.visible = true
	synergyVBox.visible = false 
	var file = FileAccess.open(newFile, FileAccess.READ)
	var newText = file.get_as_text()
	file.close()
	label_text.text = newText	
	print("PAUSE GAME 2")
	get_tree().paused = true
	pass

#Shows the tooltip with the button
func showButton():
	show()
	button.visible = true 
	pass
	
#Sets the current tooltip animation 
func setAnim(newAnim : SpriteFrames):
	anim_texture.sprites =  newAnim
	anim_texture.playing = true
	anim_texture.visible = true
	greyBG.visible = true

#Shows the tooltip Without the Button 
func noButtonShow():
	show()
	button.visible = false
	pass

func complexNoButtonShow():
	#show()
	syngergyButton.visible = false
	pass
		
func setImage(newImage):
	#TextureRect
	pass

func setComplexScene(newScene):
	syngergyButton.visible = true 
	show()
	mainVbox.visible = false
	synergyVBox.visible = true 
	complexButton.visible = true
	#Clean Up Any Previous Complex Scenes 
	for node in complexSceneContainer.get_children():
		#print("NNNOde is ", node.name)
		if node is Label || node is RichTextLabel || node is VScrollBar:
		#	print("Will Now Pass ", node.name)
			pass

		else:
			if (node == Button) || "Button" in node.name || (node == RichTextLabel):
				pass
			#	print("Node is button ", node.name)
			elif node != Button:
				if node != RichTextLabel:
				#	print("Queue Free ", node.name)
					node.queue_free()
	#Add New Complex Scene to Container 
	var this_new_scene = newScene.instantiate()
	complexSceneContainer.add_child(this_new_scene)
	complexSceneContainer.move_child(this_new_scene, 0)
	for node in complexSceneContainer.get_children():
		pass
		#print("Node is ", node.name)

func hideComplexSceneButton():
	complexButton.visible = false

	
#Hides the tooltip and unpauses the game when the player clicks the button
func _on_Button_pressed():
	hide()
	ToolTipHid.emit()
	#print("UNPPAUSE HERE1")
	print("UNPAUSE GAME")
	get_tree().paused = false


func _on_button_2_pressed() -> void:
	hide()
	ToolTipHid.emit()
	#print("UNPPAUSE HERE2")
	print("UNPAUSE GAME")
	get_tree().paused = false
