extends Zombie
# BucketHeadZombie.gd


func get_zombie_name():
	return " UNHALLOWER "
	
	
func silence():
	super()
	attackComp.silence()
