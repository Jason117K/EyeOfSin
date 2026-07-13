extends Control

@export var ability_name : String = "Swap Ability"
@onready var swap_ability_label := $SwapAbilityCooldownPanel/MarginContainer/SwapAbilityProgressBar/SwapAbilityLabel
@onready var swap_ability_cooldown_panel := $SwapAbilityCooldownPanel
@onready var swap_ability_lock_visual := $LockedVisual

func _ready() -> void:
	swap_ability_label.text = tr(ability_name)
	swap_ability_lock_visual.hide()
	
func get_panel_container()->PanelContainer:
	return swap_ability_cooldown_panel

func lock_unlock_swap_ability()->void:
	if swap_ability_lock_visual.visible == true:
		swap_ability_lock_visual.hide()
	else:
		swap_ability_lock_visual.show()
