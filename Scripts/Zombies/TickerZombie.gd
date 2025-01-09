extends Area2D
#TickerZombie.gd

onready var compManager = $ComponentManager
onready var rayCast = $DMGRayCast2D
#onready var specialMoveComp = $SpecialMoveComp


func getCompManager():
	return compManager


func die():
	queue_free()
