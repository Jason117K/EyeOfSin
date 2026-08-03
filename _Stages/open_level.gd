extends Control

@onready var level_title := $CenterContainer/PanelContainer/Level_Vbox/Level_Label
@onready var level_description := $CenterContainer/PanelContainer/Level_Vbox/LevelMarginContainer/LevelImagePanelContainer/VBoxContainer/LevelDescription
@onready var level_image_earth  := $CenterContainer/PanelContainer/Level_Vbox/LevelMarginContainer/LevelImagePanelContainer/VBoxContainer/LevelTexture
@onready var level_image_syn  :=  $CenterContainer/PanelContainer/Level_Vbox/LevelMarginContainer/LevelImagePanelContainer/VBoxContainer/LevelTextureAlt

var level_earth
var level_syn 

func set_level_title(new_title : String)->void:
	level_title.text = new_title
	
func set_level_description(new_description : String) -> void:
	level_description.text = (FileAccess.open(new_description, FileAccess.READ)).get_as_text()
	
func set_level_images (new_earth_image : TextureRect, new_syn_image : TextureRect)->void:
	level_image_earth = new_earth_image
	level_image_syn = new_syn_image

func set_levels(new_earth_level : String, new_syn_level : String) -> void:
	level_earth = new_earth_level
	level_syn = new_syn_level

func _on_play_button_pressed() -> void:
	Global.game_controller.change_dual_scenes(level_earth,level_syn)
