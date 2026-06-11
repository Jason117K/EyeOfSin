extends Control

@export var ability_name : String = "Swap Ability"
@onready var swap_ability_label := $SwapAbilityCooldownPanel/MarginContainer/SwapAbilityProgressBar/SwapAbilityLabel
@onready var swap_ability_cooldown_panel := $SwapAbilityCooldownPanel

func _ready() -> void:
	swap_ability_label.text = ability_name
	
func get_panel_container()->PanelContainer:
	return swap_ability_cooldown_panel
