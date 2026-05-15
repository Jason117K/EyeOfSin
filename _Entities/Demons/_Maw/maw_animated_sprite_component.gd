extends DemonSpriteComp

func receive_buff(demonName):
	super(demonName)
	match demonName:
		"SpinalOcculum" :
			speed_scale = 0.7
		"Wyrm" :
			speed_scale = speed_scale * 1.5
			
