extends ZombieAttackRefCountedComponent
class_name RangedZombieAttackComponent
# RangedZombieAttackComponent.gd


# Fires instead of biting: no melee contact, so Maw eat / thorn reflects don't trigger.
func _strike(_target: Node) -> void:
	parent_zombie.shoot_projectile(attack_power, target_group)
