extends DemonHealthComponent

@export var spinalOcculumBuffed_health = 550
@export var mawBuffed_health = 350


func receiveBuff(demonName):
	#print("Buff Name is ", newDemon.name)
	if !demon.get_is_buffed():
		match demonName:
			"SpinalOcculum" :
				health = spinalOcculumBuffed_health
			"Maw":
				health = mawBuffed_health
