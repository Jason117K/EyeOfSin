extends Area2D
#BucketHeadZombie.gd

onready var compManager = $ComponentManager
onready var rayCast = $DMGRayCast2D


func getCompManager():
	return compManager


func die():
	queue_free()


func special_move():
	compManager.special_move()


func fightDrone():
	compManager.fightDrone()


func stopFightingDrone():
	compManager.stopFightingDrone()


func fightDroneExplode():
	compManager.fightDroneExplode()
