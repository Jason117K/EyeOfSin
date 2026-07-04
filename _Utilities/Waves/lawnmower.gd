extends Area2D

@export var is_green := false 

var is_launched := false
var speed := 200
var max_distance := 800
var distance_traveled := 0

@onready var _home_position := position


func _ready() -> void:
	init_collision()


# DIAGNOSTIC (remove once the culprit is found): mowers are pooled and should
# never leave the tree mid-session, yet something frees launched mowers.
# When this fires, the warning + stack in the output names the caller.
func _exit_tree() -> void:
	push_warning("[MOWER] '%s' leaving tree (launched=%s, pos=%s, parent=%s)"
			% [name, str(is_launched), str(position), str(get_parent())])
	print_stack()


func init_collision()->void:
	if is_green:
		self.set_collision_mask_value(5,true)
	else:
		self.set_collision_mask_value(4,true)
	

func _physics_process(delta: float) -> void:
	if is_launched:
		self.position.x += delta * speed
		distance_traveled +=  delta * speed
		if distance_traveled > max_distance:
			print(self,"Now Deactivate Mower")
			_deactivate()


# Pooled, not freed: mowers are children of the persistent WaveManager, so a
# freed mower would be gone for every later level/restart.
func _deactivate()->void:
	is_launched = false
	visible = false
	set_deferred("monitoring", false)


func reset_for_level()->void:
	position = _home_position
	distance_traveled = 0
	is_launched = false
	visible = true
	set_deferred("monitoring", true)


func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("Zombie"):
		if area.has_method("true_death"):
			area.true_death()
		else:
			area.die()

func kill_zombie(area : Area2D):
	if area.has_method("true_death"):
		area.true_death()
	else:
		area.die()

func launch(launch_area : Area2D)->void:
	print("Should Launch, new global pos is ", launch_area.global_position)
	
	self.global_position = launch_area.global_position
	
	for zombie in get_overlapping_areas():
		kill_zombie(zombie)
		
	is_launched = true 
	
	
	
	
	
	
	
	
##
