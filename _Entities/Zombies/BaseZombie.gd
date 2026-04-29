extends Area2D
#BaseZombie.gd

class_name Zombie 
# Defines basic behavior for all zombie types

signal zombie_death

@onready var compManager = $ComponentManager

var slow_field_scene = preload("res://_Entities/Demons/WebTile/web_tile_slow.tscn")

func _ready() -> void:
	if self.is_in_group("Green"):
	#	print("SET TO GTREEEEEEEN SO CAN ATTTACK GREEEN")
		self.set_collision_layer_value(1,false)
		self.set_collision_layer_value(2,false)
		self.set_collision_layer_value(3,true)
	else:
		self.set_collision_layer_value(1,false)
		self.set_collision_layer_value(2,true)
		self.set_collision_layer_value(3,false)
	#set_hue_shift
# Component Manager Getter
func getCompManager():
	return compManager

# Tells Comp Manager the Zombie is Fighting a Hive Drone 
func fightDrone():
	compManager.fightDrone()

func make_spawn_slow_on_death():
	compManager.spawn_slow_field = true 
	
	
# Tells Comp Manager the Zombie Stopped Fighting a Hive Drone 
func stopFightingDrone():
	compManager.stopFightingDrone()

#Tells Comp Manager This Zombie Will Explode When Killed 
func fightDroneExplode():
	compManager.fightDroneExplode()
	
#Tells Comp Manager to execute this Zombie's special move
func special_move():
	compManager.special_move()

#TODO Pick Up Here Left Off Here 
func set_hue_shift(hue_shift_degrees):
	compManager.set_hue_shift(hue_shift_degrees)
	
#Kills the Zombie 
func die():
	if compManager.spawn_slow_field == true :
		spawn_slow_field_on_death()
	#if compMana
#	print("Should die")
	zombie_death.emit()
	queue_free()

func spawn_slow_field_on_death():
	var slow_field
	slow_field = slow_field_scene.instantiate()
	slow_field.global_position = self.global_position
	#slow_field.position = position + Vector2(32, 8)  # Adjust starting position
	get_parent().add_child(slow_field)  # Add the projectile to the game layer DOUBLE CHECK
	
	
	
func change_dimensions(new_position):
	print("Swap Parent Was ", get_parent())
	self.reparent(Global.get_game_controller().get_alt_dimension().get_node("GameLayer"))
	if self.is_in_group("Green"):
		print("Swap Green to Purple")
		self.remove_from_group("Green")
		self.add_to_group("Purple")
		self.set_collision_layer_value(2,true)
		set_hue_shift(-86)
	else:
		print("Swap Purple to Green")
		self.remove_from_group("Purple")
		self.add_to_group("Green")
		self.set_collision_layer_value(3,true)
		set_hue_shift(125)
	self.global_position = new_position
	print("Swa Parent IS ", get_parent())
	
