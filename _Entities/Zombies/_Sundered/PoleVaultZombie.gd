extends Zombie
#PoleVaultZombie.gd

# Handles PoleVault Zombie specific functionality

@onready var specialMoveComp := $SpecialMoveComp
@onready var attack_comp := $AttackComponent

# Specific Pole Vault Special Move
func special_move() -> void:
	#compManager.special_move()
	specialMoveComp.executeMove()
	animatedSprite.setSpecialMoveTrue()

# Gets whether or not the special Move has finished executing
func getIsMoveFinished() -> bool:
	return specialMoveComp.isMoveFinished()

func get_zombie_name() -> String:
	return " SUNDERED "

func silence() -> void:
	print(self, "Is Silenced")
	super()
	specialMoveComp.silence()
	attack_comp.canSpecial = false
	silence_field.position = silence_field_position

func get_special_description() -> String:
	return sundered_special_description


func get_zombie_icon() -> CompressedTexture2D:
	return Global.sundered_icon
