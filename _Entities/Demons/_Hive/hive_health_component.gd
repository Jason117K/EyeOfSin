extends DemonHealthComponent

@export var walnutHealth := 650


func receiveBuff(demonName):
	#print("Buff Name is ", newPlant.name)
	if !demon.get_is_buffed():
		match demonName:
			"WalnutTree" :
				health = walnutHealth
