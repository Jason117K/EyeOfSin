extends Area2D
#DancerZombie.gd


onready var compManager = $ComponentManager

func getCompManager():
	return compManager


func die():
	queue_free()


func fightDrone():
	compManager.fightDrone()


func stopFightingDrone():
	compManager.stopFightingDrone()

func fightDroneExplode():
	compManager.fightDroneExplode()
