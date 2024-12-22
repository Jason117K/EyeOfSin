# BasicZombie.gd
extends Area2D

onready var compManager = $ComponentManager

func getCompManager():
	return compManager


func die():
	queue_free()
