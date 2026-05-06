extends DemonHealthComponent

@export var walnutHealth = 375

func receiveBuff(demonName):
	#print("Buff Name is ", newPlant.name)
	if !zombie.get_is_buffed():
		match demonName:
			"WalnutTree" :
				health = walnutHealth
				isSpinalOcculumBuffed = true 


func debuff():
	super() 
