extends Node

@export var syn_ability_instance :PackedScene = preload("res://_Entities/SynAbility/syn_lightning_ability_bolt.tscn")
@export var icon_texture := preload("res://_Entities/SynAbility/SynShieldCard.png")

@onready var syn_ability_cooldown := $SynAbilityCooldown
@onready var syn_ability_crosshair : AnimatedSprite2D = $SynAbilityCrosshair
var syn_crosshair_active := false 

func _ready() -> void:
	syn_ability_cooldown.get_button().pressed.connect(set_ability_targeting_active)
	syn_ability_crosshair.hide()
	syn_ability_cooldown.set_icon(icon_texture)
	
	
func set_ability_targeting_active()->void:
	syn_crosshair_active = true 
	syn_ability_crosshair.show()
	
func _process(_delta: float) -> void:
	if syn_crosshair_active:
		syn_ability_crosshair.global_position = get_viewport().get_mouse_position()
	else:
		syn_ability_crosshair.hide()
	
func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		if syn_crosshair_active:
			print("Syn Ability CLICK")
			activate_syn_ability(get_viewport().get_mouse_position())



func activate_syn_ability(target_pos:Vector2)->void:
	var new_syn_ability_instance :Node= syn_ability_instance.instantiate()
	new_syn_ability_instance.global_position = target_pos
	if Global.is_on_purple_dimension():
		new_syn_ability_instance.add_to_group("Purple")
	else:
		new_syn_ability_instance.add_to_group("Green")
	get_parent().get_active_dimension().add_child(new_syn_ability_instance)
	syn_crosshair_active = false
	
	
	
	
	
	
