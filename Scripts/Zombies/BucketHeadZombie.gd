extends Area2D
#BucketHeadZombie.gd

onready var compManager = $ComponentManager

func getCompManager():
	return compManager


func die():
	queue_free()
