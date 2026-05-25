extends DemonSpriteComp

func _process(_delta: float) -> void:
	if animation == "spawn":
		return
	else:
		pass
		#TODO Restore Hurt Anims, Move to Health Component 
		#if health > (maxHealth * 0.9):
			#animSpriteComp.animation = "default"
		#elif health < maxHealth && health > ((maxHealth/3)*2) :
			#animSpriteComp.animation = "hurt1"
		#elif (health < ((maxHealth/3)*2)) && health > (maxHealth/3):
			#animSpriteComp.animation = "hurt2"
		#else:
			#animSpriteComp.animation = "hurt3"
