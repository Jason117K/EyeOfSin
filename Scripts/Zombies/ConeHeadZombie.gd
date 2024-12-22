extends Area2D
#ConeHeadZombie.gd

onready var compManager = $ComponentManager

func getCompManager():
	return compManager

func die():
	queue_free()
