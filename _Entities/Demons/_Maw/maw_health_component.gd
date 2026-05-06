extends DemonHealthComponent

@export var walnutHealth = 600



func receiveBuff(demonName):
	#print("Buff Name is ", newPlant.name)
	if !demon.get_is_buffed():
		match demonName:
			"Walnut":
				health = walnutHealth
			"Hive" :
				health = 200
