extends DemonHealthComponent

@export var spinalOcculumBuffed_health = 550
@export var mawBuffed_health = 350


func receive_buff(demonName):
	#print("Buff Name is ", newDemon.name)

	match demonName:
		"SpinalOcculum" :
			health = spinalOcculumBuffed_health
		"Maw":
			health = mawBuffed_health
