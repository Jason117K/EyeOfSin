extends DemonHealthComponent

var spinalOcculumHealth = 1500
var spinal_occulum_max_health = 1500

func _ready():
	super()
	spinalOcculumHealth = demon.spinalOcculumHealth
	spinal_occulum_max_health = demon.spinal_occulum_max_health

func receive_buff(demonName):
	match demonName:
		"SpinalOcculum":
			health = spinalOcculumHealth
			maxHealth = spinal_occulum_max_health
