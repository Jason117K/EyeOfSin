extends DemonHealthComponent

var spinalOcculumHealth = 375

func _ready():
	super()
	spinalOcculumHealth = demon.spinalOcculumHealth

func receive_buff(demonName):
	#print("Buff Name is ", newDemon.name)

	match demonName:
		"SpinalOcculum" :
			health = spinalOcculumHealth
			isSpinalOcculumBuffed = true 


func debuff():
	super() 
