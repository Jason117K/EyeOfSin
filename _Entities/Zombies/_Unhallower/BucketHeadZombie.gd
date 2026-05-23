extends Zombie
# BucketHeadZombie.gd


func get_zombie_name():
	return " UNHALLOWER "
	
	
func silence():
	super()
	attackComp.silence()

func get_special_description():
	return unhallower_special_description

func get_zombie_icon()->CompressedTexture2D:
	return Global.unhallower_icon
