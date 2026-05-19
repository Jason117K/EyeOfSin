extends DemonHealthComponent

var maw_health = 500

func _ready():
	super()
	maw_health = demon.maw_health

func receive_buff(demonName):
	#print("Buff Name is ", newDemon.name)

	match demonName:
		"Maw" :
			health = maw_health
