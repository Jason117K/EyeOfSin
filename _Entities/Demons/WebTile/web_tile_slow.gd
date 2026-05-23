extends Area2D

	
func activate() -> void:
	show()
	monitoring = true 
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
		
	for area in get_overlapping_areas():
		if area.is_in_group("Zombie"):
			area.slow()


func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("Zombie"):
		area.slow()
