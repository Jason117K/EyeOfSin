extends Area2D

@export var is_green := false 

var is_launched := false 
var speed := 200
var max_distance := 800
var distance_traveled := 0 


func _ready() -> void:
	init_collision()


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
			print(self,"Now Queue Free Mower")
			queue_free()
		#Queue Free When Gone Too Far


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
