extends DemonHealthComponent

@export var spinalOcculumHealth := 650


func receive_buff(demonName):
	#print("Buff Name is ", newDemon.name)
	if !demon.get_is_buffed():
		match demonName:
			"SpinalOcculum" :
				health = spinalOcculumHealth
