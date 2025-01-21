# BasicZombie.gd
extends Area2D

onready var compManager = $ComponentManager

func getCompManager():
	return compManager


func die():
	queue_free()


func fightDrone():
	compManager.fightDrone()


func stopFightingDrone():
	compManager.stopFightingDrone()
