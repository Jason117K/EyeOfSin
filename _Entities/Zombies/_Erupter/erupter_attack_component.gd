extends AttackComponent
@onready var AOEHit := $"../AOEHit"

#Handles Ticker Zombie Explosion Animation
func attack_demon(collider:Node) -> void:
	super(collider)
	AOEHit.goBoom()
