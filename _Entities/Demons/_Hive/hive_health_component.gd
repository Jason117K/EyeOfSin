extends DemonHealthComponent

var spinalOcculumHealth := 800

func _ready() -> void:
	super()
	spinalOcculumHealth = demon.spinalOcculumHealth

func receive_buff(demonName: String) -> void:
	match demonName:
		"SpinalOcculum" :
			health = spinalOcculumHealth
