extends Zombie
# FootBallZombie.gd



func get_zombie_name():
	return " FLESHEATER "

func silence():
	super()
	attackComp.silence()
