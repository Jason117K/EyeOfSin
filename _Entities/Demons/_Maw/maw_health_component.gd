extends DemonHealthComponent

@export var spinalOcculumHealth = 600



func receiveBuff(demonName):
	#print("Buff Name is ", newDemon.name)
	if !demon.get_is_buffed():
		match demonName:
			"SpinalOcculum":
				health = spinalOcculumHealth
			"Hive" :
				health = 200
