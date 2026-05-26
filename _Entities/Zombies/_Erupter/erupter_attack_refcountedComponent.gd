class_name ErupterAttackRefCounted extends ZombieAttackRefCountedComponent


func attack_demon(collider:Node) -> void:
	super(collider)
	parent_zombie.goBoom()
