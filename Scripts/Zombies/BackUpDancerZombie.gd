extends Area2D
#BackUpDancerZombie.gd


onready var compManager = $ComponentManager

func getCompManager():
	return compManager

func die():
	queue_free()
