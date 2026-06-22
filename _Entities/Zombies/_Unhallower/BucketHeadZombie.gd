extends Zombie
# BucketHeadZombie.gd

func _ready()->void:
	super()
	if Global.gameIsStarted && self.is_demo == false:
		Global.unlock_zombie("Rohan")

func get_zombie_name() -> String:
	return " ROHAN "


func silence() -> void:
	super()
	attackComp.silence()

func get_special_description() -> String:
	return unhallower_special_description

func get_zombie_icon() -> CompressedTexture2D:
	return Global.unhallower_icon
