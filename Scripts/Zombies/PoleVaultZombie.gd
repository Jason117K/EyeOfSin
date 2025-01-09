extends Area2D
#PoleVaultZombie.gd

onready var compManager = $ComponentManager
onready var rayCast = $DMGRayCast2D
onready var specialMoveComp = $SpecialMoveComp

func getCompManager():
	return compManager


func die():
	queue_free()


func special_move():
	print("Pole Vault Special DOS 2")
	compManager.special_move()

func getBusy():
	return specialMoveComp.isMoveFinished()
