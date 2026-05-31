extends Control

@onready var syn_ability_button := $SynAbilityButton
@onready var syn_ability_progress_bar := $SynAbilityProgressBar

func get_button()->TextureButton:
	return syn_ability_button
	
func set_icon(new_icon_texture)->void:
	syn_ability_button.texture_normal = new_icon_texture

func set_progress_bar(new_val:float)->void:
	syn_ability_progress_bar.value = new_val
