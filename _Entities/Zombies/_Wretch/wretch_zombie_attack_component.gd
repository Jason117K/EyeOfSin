extends AttackComponent


func _ready() -> void:
	set_process(false)

func silence() -> void:
	attack_power = attack_power/2


# Attack State Getter
func getAttackState() -> bool:
	return false

# Sets is_attacking to true and plays the audio will also starting the attack cooldown timer
func attack_demon(_collider:Node) -> void:
	pass

# Damages the target demon and decides whether or not to keep attacking
func _on_AttackTimer_timeout() -> void:
	pass

# Stops the attack and resumes movement
func stop_attack() -> void:
	pass

func tick(_delta: float) -> void:
	pass
