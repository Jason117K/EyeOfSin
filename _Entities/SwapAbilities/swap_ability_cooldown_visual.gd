extends Control

@export var ability_name : String = "Swap Ability"
@onready var swap_ability_label := $SwapAbilityCooldownPanel/SwapAbilityProgressBar/SwapAbilityLabel

func _ready() -> void:
	swap_ability_label.text = ability_name
	
