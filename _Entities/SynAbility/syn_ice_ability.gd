extends Area2D

@export var ice_bleed_amount := 7
@export var on_hit_damage := 25 
@onready var blood_ice_anim := $Blood_Ice_Anim

func _ready() -> void:
	if self.is_in_group("Green"):
		self.set_collision_mask_value(1,false)
		self.set_collision_mask_value(2,false)
		self.set_collision_mask_value(3,false)
		self.set_collision_mask_value(4,false)
		self.set_collision_mask_value(5,true)
	else:
		self.set_collision_mask_value(1,false)
		self.set_collision_mask_value(2,false)
		self.set_collision_mask_value(3,false)
		self.set_collision_mask_value(4,true)
		
	await get_tree().physics_frame
	await get_tree().physics_frame
	await get_tree().physics_frame
	
	ice_attack()
	
	
	
func ice_attack()->void:
	blood_ice_anim.frame_changed.connect(ice_bleed_zombies)
	blood_ice_anim.animation_finished.connect(end_attack)
	blood_ice_anim.play()
	
	
	
func ice_bleed_zombies()->void:
	if blood_ice_anim.frame == 2:
		for zombie in get_overlapping_areas():
			if zombie.is_in_group("Zombie"):
				zombie.take_damage(on_hit_damage)
				zombie.bleed(ice_bleed_amount)
		
		
		
func end_attack()->void:
	queue_free()
	
	
	
	
	
	
	
	
	
	##
