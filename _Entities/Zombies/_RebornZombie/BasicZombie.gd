extends Zombie
# BasicZombie.gd





func get_zombie_name():
	return " REBORN "
	
func silence():
	super()
	attackComp.silence()

	
	
	
func get_special_description():
	return reborn_special_description


func get_zombie_icon()->CompressedTexture2D:
	return Global.reborn_icon
