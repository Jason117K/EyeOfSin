extends Control

@onready var new_power_texture := $PowerUnlockPanel/MarginContainer/AllElementsVbox/NewPowerTexture
@onready var title_label := $PowerUnlockPanel/MarginContainer/AllElementsVbox/NewPowerTitle
@onready var description_label := $PowerUnlockPanel/MarginContainer/AllElementsVbox/NewPowerDescription
@onready var new_power_unlock_label := $PowerUnlockPanel/MarginContainer/AllElementsVbox/NewDemonLabel



func _on_next_level_button_pressed() -> void:
	AudioManager.create_audio(SoundEffect.SOUND_EFFECT_TYPE.UI_CLICK)
	Global.game_controller.change_from_dual_scenes("res://_Stages/LevelSelect/LevelSelect_Map.tscn")
	self.visible = false

func set_new_unlock_label(new_unlock_label_text:String="UI_NEW_DEMON")->void:
	new_power_unlock_label.text = tr(new_unlock_label_text)

func set_new_power_texture(new_texture : Texture)->void:
	new_power_texture.texture = new_texture
	

func set_new_power_title(new_title:String)->void:
	title_label.text = tr(new_title)
	if title_label.text.length() > 11:
		title_label.push_font_size(11)
	else:
		title_label.push_font_size(14)
	

func set_new_power_description(new_description:String)->void:
	description_label.text = tr(new_description)
	
