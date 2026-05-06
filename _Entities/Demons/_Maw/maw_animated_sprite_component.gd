extends DemonSpriteComp

func receiveBuff(demonName):
	#print("Buff Name is ", newPlant.name)
	if !demon.get_is_buffed():
		match demonName:
			"WalnutTree" :
				speed_scale = 0.7
			"EggWorm" :
				speed_scale = speed_scale * 1.5
				
