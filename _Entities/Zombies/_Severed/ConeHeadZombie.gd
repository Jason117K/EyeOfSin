extends Zombie
# ConeHeadZombie.gd

func get_zombie_name():
	return " SEVERED "


	
func silence():
	super()
	attackComp.silence()
