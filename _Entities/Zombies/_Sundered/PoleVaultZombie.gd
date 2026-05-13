extends Zombie 
#PoleVaultZombie.gd

# Handles PoleVault Zombie specific functionality

@onready var specialMoveComp = $SpecialMoveComp


# Specific Pole Vault Special Move 
func special_move():
	compManager.special_move()
	
# Gets whether or not the special Move has finished executing 
func getIsMoveFinished():
	return specialMoveComp.isMoveFinished()
