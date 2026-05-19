extends AttackComponent



func _ready() -> void:
	set_process(false)

func silence():
	attack_power = attack_power/2
	
	
		
	
# Attack State Getter 
func getAttackState():
	return false

# Sets is_attacking to true and plays the audio will also starting the attack cooldown timer
func attack_demon(collider):
	pass

# Damages the target demon and decides whether or not to keep attacking
func _on_AttackTimer_timeout():
	pass

# Stops the attack and resumes movement
func stop_attack():
	pass

func tick(_delta):
	pass
