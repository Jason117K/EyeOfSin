extends Syn_Ability_Instance

var highest_health := -1 
var current_target_health : int 
var current_zombie_target : Zombie
var num_targets_marked := 0 
var max_targets_marked := 3 
var targets_marked : Array = []

func _ready() -> void:
	detect_zombies = true 
	super()	
	#mark_zombies()
	
func activate_ability()->void:
	for zombie in get_overlapping_areas():
		if zombie != null && !(zombie in targets_marked):
			current_target_health = zombie.get_health()
			if current_target_health > highest_health && zombie != null:
					highest_health = current_target_health
					current_zombie_target = zombie
					
	if current_zombie_target != null && !(current_zombie_target in targets_marked):
		if num_targets_marked < max_targets_marked:
			current_zombie_target.syn_mark(ability_duration)
			targets_marked.append(current_zombie_target)
			num_targets_marked += 1 
			highest_health = -1 
			activate_ability()

func connect_ability(_marked_to_connect : Area2D)->void:
	print(self, " syn ability mark will now light on fire : ", targets_marked)
	for target in targets_marked:
		target.set_on_fire()
