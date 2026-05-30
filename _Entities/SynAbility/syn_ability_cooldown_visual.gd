extends Control

@onready var syn_ability_button := $SynAbilityButton

func get_button()->TextureButton:
	return syn_ability_button
	
func set_icon(new_icon_texture)->void:
	syn_ability_button.texture_normal = new_icon_texture
