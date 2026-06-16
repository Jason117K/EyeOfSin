extends Zombie
# BasicZombie.gd


func _ready() -> void:
	super()
	Global.unlock_zombie("Reborn")


func get_zombie_name() -> String:
	return " REBORN "

func silence() -> void:
	super()
	attackComp.silence()


func get_special_description() -> String:
	return reborn_special_description


func get_zombie_icon() -> CompressedTexture2D:
	return Global.reborn_icon
