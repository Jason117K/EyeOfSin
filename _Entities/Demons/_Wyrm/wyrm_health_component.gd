extends DemonHealthComponent

@export var spinalOcculumBuffed_health = 650
@export var mawBuffed_health = 350


func receive_buff(demonName):
	print("Buff Name is ", demonName)

	match demonName:
		"SpinalOcculum" :
			health = spinalOcculumBuffed_health
		"Maw":
			health = mawBuffed_health
