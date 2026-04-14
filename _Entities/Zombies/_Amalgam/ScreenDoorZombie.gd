extends Zombie
#ScreenDoorZombie.gd

# Handles ScreenDoor Zombie specific behavior 

@onready var healthCom = compManager.getHealthComponent()
@onready var altSprite = $TransformedSpriteComp
@onready var startSprite = $AnimatedSprite2D

# Stores death count for transformation purposes 
var deathCount = 0 


# First transforms zombie 'death' 1, then kills zombie 'death' 2
func die():
	#TODO Restore to work with Maw
	queue_free()
	deathCount = deathCount+1
	if deathCount < 2:
		transform()
	else:
		queue_free()

# Switches visible sprite to transform zombie 
func transform():
	altSprite.visible = true
	startSprite.visible = false
	compManager.setMaterial(altSprite)
	healthCom.resetHealth()
