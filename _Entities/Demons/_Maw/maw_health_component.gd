extends DemonHealthComponent

@export var spinalOcculumHealth = 1500
@export var spinal_occulum_max_health = 1500



func receive_buff(demonName):
	match demonName:
		"SpinalOcculum":
			health = spinalOcculumHealth
			maxHealth = spinal_occulum_max_health
