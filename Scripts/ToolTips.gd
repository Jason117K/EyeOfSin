extends PanelContainer

@onready var label_text = $VBoxContainer/RichTextLabel
@onready var popup_image = $VBoxContainer/CenterContainer/TextureRect
@onready var anim_texture = $VBoxContainer/CenterContainer/TextureRect
@onready var button = $VBoxContainer/Button
@onready var mainVbox = $VBoxContainer
@onready var synergyVBox = $SynergyVBox
@onready var synergyLabel = $SynergyVBox/CenterContainer/VBoxContainer/SynergyLabel
@onready var complexSceneContainer = $SynergyVBox/CenterContainer/VBoxContainer

signal ToolTipHid

#TODO Combine both set text functions

func _ready() -> void:
	#print("Anim Texture is , ",anim_texture.name )
	pass

#Sets the current toolTip Text
func set_text(newFile : String):
	mainVbox.visible = true
	synergyVBox.visible = false 
	var file = FileAccess.open(newFile, FileAccess.READ)
	var newText = file.get_as_text()
	file.close()
	label_text.text = newText

func setComplexSceneText(newFile : String):
	var file = FileAccess.open(newFile, FileAccess.READ)
	var newText = file.get_as_text()
	file.close()
	synergyLabel.text = newText
	


#Sets the current toolTip Text while also pausing the game
func set_text_pause(newFile : String):
	mainVbox.visible = true
	synergyVBox.visible = false 
	var file = FileAccess.open(newFile, FileAccess.READ)
	var newText = file.get_as_text()
	file.close()
	label_text.text = newText	
	
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

#Shows the tooltip Without the Button 
func noButtonShow():
	show()
	button.visible = false
	pass
	
func setImage(newImage):
	#TextureRect
	pass

func setComplexScene(newScene):
	show()
	mainVbox.visible = false
	synergyVBox.visible = true 
	
	#Clean Up Any Previous Complex Scenes 
	for node in complexSceneContainer.get_children():
		print("NNNOde is ", node.name)
		if node is Label:
			pass
		else:
			print("Queue Free ", node.name)
			node.queue_free()
	#Add New Complex Scene to Container 
	var this_new_scene = newScene.instantiate()
	complexSceneContainer.add_child(this_new_scene)
	complexSceneContainer.move_child(this_new_scene, 0)
	for node in complexSceneContainer.get_children():
		print("Node is ", node.name)


	
#Hides the tooltip and unpauses the game when the player clicks the button
func _on_Button_pressed():
	hide()
	ToolTipHid.emit()
	get_tree().paused = false


func _on_button_2_pressed() -> void:
	hide()
	ToolTipHid.emit()
