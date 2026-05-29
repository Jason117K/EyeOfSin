extends Control

@onready var syn_ability_button := $SynAbilityButton

func get_button()->TextureButton:
	return syn_ability_button
