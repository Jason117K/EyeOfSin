extends DemonHealthComponent

var spinalOcculumHealth := 800

func _ready():
	super()
	spinalOcculumHealth = demon.spinalOcculumHealth

func receive_buff(demonName):
	match demonName:
		"SpinalOcculum" :
			health = spinalOcculumHealth
