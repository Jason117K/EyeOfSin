extends Area2D

var highest_health := -1 
var current_target_health : int 
var current_zombie_target : Zombie
var num_targets_marked := 0 
var max_targets_marked := 3 
var targets_marked : Array = []

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
	mark_zombies()
	
func mark_zombies()->void:
	for zombie in get_overlapping_areas():
		if zombie != null && !(zombie in targets_marked):
			current_target_health = zombie.get_health()
			if current_target_health > highest_health && zombie != null:
					highest_health = current_target_health
					current_zombie_target = zombie
					
	if current_zombie_target != null && !(current_zombie_target in targets_marked):
		if num_targets_marked < max_targets_marked:
			current_zombie_target.syn_mark()
			targets_marked.append(current_zombie_target)
			num_targets_marked += 1 
			highest_health = -1 
			mark_zombies()
