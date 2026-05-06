extends DemonHealthComponent

@export var walnutBuffed_health = 550
@export var mawBuffed_health = 350


func receiveBuff(demonName):
	#print("Buff Name is ", newPlant.name)
	if !demon.get_is_buffed():
		match demonName:
			"WalnutTree" :
				health = walnutBuffed_health
			"Maw":
				health = mawBuffed_health
