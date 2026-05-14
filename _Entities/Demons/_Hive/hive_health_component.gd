extends DemonHealthComponent

@export var spinalOcculumHealth := 650


func receiveBuff(demonName):
	#print("Buff Name is ", newDemon.name)
	if !demon.get_is_buffed():
		match demonName:
			"SpinalOcculum" :
				health = spinalOcculumHealth
