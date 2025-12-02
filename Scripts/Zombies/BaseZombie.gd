extends Area2D
#BaseZombie.gd

class_name Zombie 
# Defines basic behavior for all zombie types

signal zombie_death

@onready var compManager = $ComponentManager

var slow_field_scene = preload("res://Scenes/PlantScenes/web_tile_slow.tscn")
var gridPos = Vector2(0,0)
var laneNumber = 0 

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
	if compManager.can_respawn_enraged == true :
		#TODO Add Probabilty Based Chance Here 
		if randf() < 0.5:
			compManager.enrage()
			print("I WILL NOT DIE")
			return 
	#if compMana
	print("Should die")
	zombie_death.emit()
	queue_free()

func spawn_slow_field_on_death():
	var slow_field
	slow_field = slow_field_scene.instantiate()
	slow_field.global_position = self.global_position
	#slow_field.position = position + Vector2(32, 8)  # Adjust starting position
	get_parent().add_child(slow_field)  # Add the projectile to the game layer DOUBLE CHECK
	
	
func move_to_lane(laneNumber):
	self.global_position = Vector2(self.global_position.x,laneNumber * 32)

func flip_dimension():
	print("D Flipping")
	if self.is_in_group("Green"):
		print("Flip to Purple")
		reparent(Global.game_controller.get_purple_scene())
	elif self.is_in_group("Purple"):
		print("Flip to Green")
		reparent(Global.game_controller.get_green_scene())
	
func get_laneNumber():
	var laneNumber 
	gridPos = Vector2(self.global_position.x / 32, self.global_position.y /32)
	gridPos = Vector2(gridPos.x+0.5,gridPos.y + 0.5)
	laneNumber = gridPos.y	
	return laneNumber
