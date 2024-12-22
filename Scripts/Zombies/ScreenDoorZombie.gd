extends Area2D
#ScreenDoorZombie.gd

onready var compManager = $ComponentManager
onready var healthCom = compManager.getHealthComponent()
onready var altSprite = $TransformedSpriteComp
onready var startSprite = $AnimatedSprite

var deathCount = 0 

func getCompManager():
	return compManager
	
func die():
	deathCount = deathCount+1
	if deathCount < 2:
		transform()
	else:
		queue_free()
	
func transform():
	altSprite.visible = true
	startSprite.visible = false
	compManager.setMaterial(altSprite)
	healthCom.resetHealth()
