extends Area2D

onready var speedComp = $SpeedComponent



var isSlow = 0


func getSlow():
	return isSlow 
	
func slow():
	print("SLOWING")
	isSlow = isSlow + 100 
	speedComp.slow()
