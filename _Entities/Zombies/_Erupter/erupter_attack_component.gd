extends AttackComponent
@onready var AOEHit := $"../AOEHit"

#Handles Ticker Zombie Explosion Animation
func attack_demon(collider) -> void:
	super(collider)
	AOEHit.goBoom()
