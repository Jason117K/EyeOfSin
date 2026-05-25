extends Area2D

@export var damage := 75

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


func _on_explosion_anim_fx_animation_finished() -> void:
	for area in self.get_overlapping_areas():
		if area.is_in_group("Zombie"):
			area.take_damage(damage)
	queue_free()
