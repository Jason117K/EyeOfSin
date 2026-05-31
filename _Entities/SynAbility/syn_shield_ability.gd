extends Area2D

@export var ability_duration :float= 10 

@onready var syn_shield :PackedScene= preload("res://_Entities/SynAbility/syn_shield_anim_sprite.tscn")

func _ready() -> void:
	if self.is_in_group("Green"):
		self.set_collision_mask_value(1,false)
		self.set_collision_mask_value(2,false)
		self.set_collision_mask_value(3,true)
	else:
		self.set_collision_mask_value(1,false)
		self.set_collision_mask_value(2,true)
		self.set_collision_mask_value(3,false)
	await get_tree().physics_frame
	await get_tree().physics_frame
	await get_tree().physics_frame	
	shield_demons()
	
func shield_demons()->void:
	print("Shield Demons Called ", self.get_overlapping_areas())
	for demon in self.get_overlapping_areas():
		if demon.is_in_group("Demons"):
			print("Shield Demon ", demon)
			demon.shield(syn_shield,ability_duration)
	queue_free()
	
func connect_shields(shield_to_connect : Area2D)->void:
	print("Attempt Connect Shields")
	
