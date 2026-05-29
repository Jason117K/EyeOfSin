extends Area2D

@onready var lightning_anim := $AnimatedSprite2D
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
		
	lightning_anim.frame_changed.connect(damage_zombies)
	lightning_anim.show()
	lightning_anim.play()
	
func damage_zombies()->void:
	print("Lightning Frame is ", lightning_anim.frame)
	if lightning_anim.frame == 2:
		for zombie in self.get_overlapping_areas():
			if zombie.is_in_group("Zombie"):
				zombie.take_damage(damage)
