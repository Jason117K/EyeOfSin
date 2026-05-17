extends DemonHealthComponent

@export var spinalOcculumHealth := 800


func receive_buff(demonName):
	#print("Buff Name is ", newDemon.name)

	match demonName:
		"SpinalOcculum" :
			health = spinalOcculumHealth
