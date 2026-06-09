extends Area2D

@export var is_alt := false 

func _ready() -> void:
	if is_alt:
		self.add_to_group("Green")
	else:
		self.add_to_group("Purple")
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


func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("Zombie"):
		Global.lose_game()
		
