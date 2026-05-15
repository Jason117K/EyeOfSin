extends DemonHealthComponent

@export var spinalOcculumHealth = 375

func receive_buff(demonName):
	#print("Buff Name is ", newDemon.name)

	match demonName:
		"SpinalOcculum" :
			health = spinalOcculumHealth
			isSpinalOcculumBuffed = true 


func debuff():
	super() 
