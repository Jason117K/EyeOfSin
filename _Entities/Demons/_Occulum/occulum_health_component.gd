extends DemonHealthComponent


@export var maw_health = 500 

func receive_buff(demonName):
	#print("Buff Name is ", newDemon.name)

	match demonName:
		"Maw" :
			health = maw_health
