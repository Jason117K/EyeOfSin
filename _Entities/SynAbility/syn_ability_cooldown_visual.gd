extends Control

@onready var syn_ability_button := $SynAbilityPanelContainer/MarginContainer/HBoxContainer/SynAbilityButton
@onready var syn_ability_progress_bar := $SynAbilityPanelContainer/MarginContainer/HBoxContainer/SynAbilityProgressBar

# Syn cards ship at different resolutions (Lightning Strike 64px .. Death Mark 32px);
# a fixed slot keeps every card the same size instead of drawing each at native size.
const CARD_SLOT_SIZE := Vector2(64, 64)

func _ready() -> void:
	syn_ability_button.ignore_texture_size = true
	syn_ability_button.custom_minimum_size = CARD_SLOT_SIZE
	syn_ability_button.stretch_mode = TextureButton.STRETCH_KEEP_ASPECT_CENTERED

func get_button()->TextureButton:
	return syn_ability_button
	
func set_icon(new_icon_texture)->void:
	syn_ability_button.texture_normal = new_icon_texture
	syn_ability_button.show()
	syn_ability_progress_bar.show()

func set_progress_bar(new_val:float)->void:
	syn_ability_progress_bar.value = new_val
