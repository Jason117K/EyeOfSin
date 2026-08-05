extends DemonHealthComponent

var spinalOcculumHealth := 375

func _ready() -> void:
	super()
	spinalOcculumHealth = demon.spinalOcculumHealth

func receive_buff(demonName: String) -> void:
	##print("Buff Name is ", newDemon.name)

	match demonName:
		"SpinalOcculum" :
			health = spinalOcculumHealth
			maxHealth = spinalOcculumHealth
			isSpinalOcculumBuffed = true


func debuff() -> void:
	super()
