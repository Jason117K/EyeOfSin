extends Area2D
#DancerZombie.gd


onready var compManager = $ComponentManager

func getCompManager():
	return compManager


func die():
	queue_free()
