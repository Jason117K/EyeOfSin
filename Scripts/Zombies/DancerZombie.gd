extends Area2D

onready var speedComp = $SpeedComponent
onready var animatedSpriteComp = $AnimatedSprite
onready var healthComp = $HealthComponent

var isSlow = 0

func getHealthComponent():
	return healthComp
	
func getSlow():
	return isSlow 
	
func slow():
	print("SLOWING")
	isSlow = isSlow + 100 
	speedComp.slow()


