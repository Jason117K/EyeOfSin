extends Zombie 
#PoleVaultZombie.gd

# Handles PoleVault Zombie specific functionality

@onready var specialMoveComp = $SpecialMoveComp
@onready var attack_comp := $AttackComponent

# Specific Pole Vault Special Move 
func special_move():
	#compManager.special_move()
	specialMoveComp.executeMove()
	animatedSprite.setSpecialMoveTrue()
	
# Gets whether or not the special Move has finished executing 
func getIsMoveFinished():
	return specialMoveComp.isMoveFinished()

func get_zombie_name():
	return " SUNDERED "

func silence():
	print(self, "Is Silenced")
	super()
	specialMoveComp.silence()
	attack_comp.canSpecial = false
	silence_field.position = silence_field_position
