extends DemonHealthComponent


@export var maw_health = 500 

func receive_buff(demonName):
	#print("Buff Name is ", newDemon.name)
	if !demon.get_is_buffed():
		match demonName:
			"Maw" :
				health = maw_health
