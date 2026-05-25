extends Zombie
# TickerZombie.gd

# Handles Any Ticker Zombie Specific Logic
@onready var aoe := $AOEHit

func get_zombie_name() -> String:
	return " ERUPTER "


func silence() -> void:
	super()
	aoe.silence()
	silence_field.position = silence_field_position

func get_special_description() -> String:
	return erupter_special_description

func get_zombie_icon() -> CompressedTexture2D:
	return Global.erupter_icon
