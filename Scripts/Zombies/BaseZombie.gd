extends Area2D
#BaseZombie.gd

class_name Zombie 
# Defines basic behavior for all zombie types


@onready var compManager = $ComponentManager

# Component Manager Getter
func getCompManager():
	return compManager

# Tells Comp Manager the Zombie is Fighting a Hive Drone 
func fightDrone():
	compManager.fightDrone()

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
	print("Should die")
	queue_free()
