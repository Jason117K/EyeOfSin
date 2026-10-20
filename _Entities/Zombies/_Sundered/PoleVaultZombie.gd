extends Zombie
#PoleVaultZombie.gd

# Handles PoleVault Zombie specific functionality

# Read by SpecialMoveComp (VaultSpecialMoveComp.gd) in its _ready
@export_category("Vault")
@export var vault_duration := 3.3   # Duration of the vault movement in seconds
@export var vault_distance := -110  # Distance to move left (negative for leftward movement)
@export var silenced_speed := 26    # Walk speed once silenced

@onready var specialMoveComp := $SpecialMoveComp


func _ready() -> void:
	super()
	specialMoveComp.attack_comp = attackComp
	Global.unlock_zombie("Sundered")

# Specific Pole Vault Special Move
func special_move() -> void:
	#compManager.special_move()
	specialMoveComp.executeMove(get_speed())
	animatedSprite.setSpecialMoveTrue()

# Gets whether or not the special Move has finished executing
func getIsMoveFinished() -> bool:
	return specialMoveComp.isMoveFinished()

func get_zombie_name() -> String:
	return " SUNDERED "

func silence() -> void:
	#print(self, "Is Silenced")
	super()
	specialMoveComp.silence()
	attackComp.canSpecial = false
	silence_field.position = silence_field_position

func get_special_description() -> String:
	return sundered_special_description


func get_zombie_icon() -> CompressedTexture2D:
	return Global.sundered_icon
