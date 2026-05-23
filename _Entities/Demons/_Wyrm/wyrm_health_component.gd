extends DemonHealthComponent

var spinalOcculumBuffed_health = 650
var mawBuffed_health = 350

func _ready():
	super()
	spinalOcculumBuffed_health = demon.spinalOcculumBuffed_health
	mawBuffed_health = demon.mawBuffed_health

func receive_buff(demonName):
	#print("Buff Name is ", demonName)

	match demonName:
		"SpinalOcculum" :
			health = spinalOcculumBuffed_health
		"Maw":
			health = mawBuffed_health
