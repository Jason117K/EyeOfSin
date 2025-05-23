extends Zombie 
#PoleVaultZombie.gd

# Handles PoleVault Zombie specific functionality

@onready var specialMoveComp = $SpecialMoveComp


# Specific Pole Vault Special Move 
func special_move():
	print("Pole Vault Special DOS 2")
	compManager.special_move()
	
# Gets whether or not the special Move has finished executing 
func getBusy():
	return specialMoveComp.isMoveFinished()

