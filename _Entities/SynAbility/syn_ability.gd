extends Node

@onready var syn_ability_cooldown := $SynAbilityCooldown
@onready var syn_ability_crosshair : AnimatedSprite2D = $SynAbilityCrosshair
var syn_crosshair_active := false 

func _ready() -> void:
	syn_ability_cooldown.get_button().pressed.connect(set_ability_targeting_active)
	
	
func set_ability_targeting_active()->void:
	pass
	
