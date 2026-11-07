extends Control

const TUTORIAL_ON_COLOR := Color("410054")
const TUTORIAL_OFF_COLOR := Color.BLACK

@onready var level_title := $CenterContainer/PanelContainer/Level_Vbox/Level_Label
@onready var level_description := $CenterContainer/PanelContainer/Level_Vbox/LevelMarginContainer/LevelImagePanelContainer/VBoxContainer/LevelDescription
@onready var level_image_earth  := $CenterContainer/PanelContainer/Level_Vbox/LevelMarginContainer/LevelImagePanelContainer/VBoxContainer/LevelTexture
@onready var level_image_syn  :=  $CenterContainer/PanelContainer/Level_Vbox/LevelMarginContainer/LevelImagePanelContainer/VBoxContainer/LevelTextureAlt
@onready var show_tutorial_box := $CenterContainer/PanelContainer/Level_Vbox/Rank_HBox/TutorialMarginContainer
@onready var toggle_tutorial_button := $CenterContainer/PanelContainer/Level_Vbox/Rank_HBox/TutorialMarginContainer/TutorialVbox/ToggleTutorialButton
var tutorial_active : bool = true

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
	_reset_tutorial_option(Progress.level_for_scene(new_earth_level))

func _reset_tutorial_option(level : int) -> void:
	var attempted := Progress.is_level_attempted(level)
	show_tutorial_box.visible = attempted and Progress.level_has_tutorial(level)
	_set_tutorial_active(not attempted)

func _set_tutorial_active(active : bool) -> void:
	tutorial_active = active
	toggle_tutorial_button.self_modulate = TUTORIAL_ON_COLOR if active else TUTORIAL_OFF_COLOR

func _on_play_button_pressed() -> void:
	Global.skip_tutorials = not tutorial_active
	Global.game_controller.change_dual_scenes(level_earth,level_syn)

func _on_toggle_tutorial_button_pressed() -> void:
	_set_tutorial_active(not tutorial_active)
