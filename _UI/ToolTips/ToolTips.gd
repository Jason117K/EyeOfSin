extends Control

@onready var basicTutorialMessageContainer := $BasicTutorialMessage
@onready var basicTutorialLabel := $BasicTutorialMessage/BasicTutorialVbox/BasicTutorialLabel
@onready var basicTutorialButton := $BasicTutorialMessage/BasicTutorialVbox/BasicTutorialUnderstoodButton

@onready var visualTutorialContainer := $VisualTutorialVBox
@onready var visualTutorialLabel := $VisualTutorialVBox/VisualTutorialPanelContainer/VisualTutorialMarginContainer/VisualTutorialHBox/VisualTutorialLabel
@onready var visualTutorialButton := $VisualTutorialVBox/VisualTutorialUnderstoodButton
@onready var visualTutorialVisual : CenterContainer = $VisualTutorialVBox/VisualTutorialPanelContainer/VisualTutorialMarginContainer/VisualTutorialHBox/VisualTutorialVisual
@onready var visualTutorialVisualParent := $VisualTutorialVBox/VisualTutorialPanelContainer/VisualTutorialMarginContainer/VisualTutorialHBox

@export var max_basic_tutorial_characters := 100
@export var small_basic_tutorial_text := 16
@export var large_basic_tutorial_text := 32 
@export var max_visual_tutorial_characters := 200
@export var small_visual_tutorial_text := 20
@export var large_visual_tutorial_text := 24 

var char_count 
var index

signal ToolTipHid

func _ready() -> void:
	hide()
	basicTutorialButton.pressed.connect(_on_basic_tutorial_understood_button_pressed)
	visualTutorialButton.pressed.connect(_on_visual_tutorial_understood_button_pressed)
	index = visualTutorialVisual.get_index()
	
func set_basic_tutorial_text(newFile : String, shouldPause : bool):
	show()
	hide_basic_tutorial_button()
	basicTutorialMessageContainer.visible = true
	visualTutorialContainer.visible = false 
	
	var file = FileAccess.open(newFile, FileAccess.READ)
	var newText = file.get_as_text()
	file.close()
	
	basicTutorialLabel.text = newText
	char_count = newText.length()
	if char_count > max_basic_tutorial_characters:
		basicTutorialLabel.add_theme_font_size_override("normal_font_size", small_basic_tutorial_text)
	else:
		basicTutorialLabel.add_theme_font_size_override("normal_font_size", large_basic_tutorial_text)
	
	if shouldPause:
		show_basic_tutorial_button()
		get_tree().paused = true 


func show_basic_tutorial_button():
	basicTutorialButton.show()


func hide_basic_tutorial_button():
	basicTutorialButton.hide()
		

func _on_basic_tutorial_understood_button_pressed() -> void:
	hide()
	ToolTipHid.emit()
	get_tree().paused = false
	
			
func set_visual_tutorial_text(newFile : String):
	show()
	basicTutorialMessageContainer.visible = false
	visualTutorialContainer.visible = true
	 
	var file = FileAccess.open(newFile, FileAccess.READ)
	var newText = file.get_as_text()
	file.close()
	
	visualTutorialLabel.text = newText
	char_count = newText.length()
	get_tree().paused = true 
	if char_count > max_visual_tutorial_characters:
		visualTutorialLabel.add_theme_font_size_override("normal_font_size", small_visual_tutorial_text)
	else:
		visualTutorialLabel.add_theme_font_size_override("normal_font_size", large_visual_tutorial_text)
	
		
func set_visual_tutorial_visual(newVisual : CenterContainer):
	visualTutorialVisualParent.remove_child(visualTutorialVisual)
	visualTutorialVisual.queue_free()
	visualTutorialVisualParent.add_child(newVisual)
	visualTutorialVisualParent.move_child(newVisual, index)
	visualTutorialVisual = newVisual
	
	
func _on_visual_tutorial_understood_button_pressed() -> void:
	hide()
	ToolTipHid.emit()
	get_tree().paused = false

	
