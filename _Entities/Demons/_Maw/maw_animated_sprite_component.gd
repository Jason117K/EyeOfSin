extends DemonSpriteComp

func receiveBuff(demonName):
	#print("Buff Name is ", newDemon.name)
	if !demon.get_is_buffed():
		match demonName:
			"SpinalOcculum" :
				speed_scale = 0.7
			"Wyrm" :
				speed_scale = speed_scale * 1.5
				
