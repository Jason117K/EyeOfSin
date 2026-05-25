extends Zombie
# BucketHeadZombie.gd


func get_zombie_name() -> String:
	return " UNHALLOWER "


func silence() -> void:
	super()
	attackComp.silence()

func get_special_description() -> String:
	return unhallower_special_description

func get_zombie_icon() -> CompressedTexture2D:
	return Global.unhallower_icon
