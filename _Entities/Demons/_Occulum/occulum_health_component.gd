extends DemonHealthComponent


@export var maw_health = 500 

func receiveBuff(demonName):
	#print("Buff Name is ", newPlant.name)
	if !demon.get_is_buffed():
		match demonName:
			"Maw" :
				health = maw_health
