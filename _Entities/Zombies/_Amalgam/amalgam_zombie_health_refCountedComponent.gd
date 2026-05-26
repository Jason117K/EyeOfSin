class_name AmalgamHealthRefCounted extends ZombieHealthRefCountedComponent


func take_damage(damage: float, piercing: bool = false) -> void:
	#print(zombie.name, " just took, ", damage)
	health -= damage
	if piercing:
		#print(zombie.name, " just took, ", damage)
		health -= damage
	injured = health < halfHealth
	AudioManager.create_2d_audio_at_location(parent_zombie.global_position, SoundEffect.SOUND_EFFECT_TYPE.ZOMBIE_TAKE_DAMAGE)

	if health <= 0:
		parent_zombie.check_for_maw(damage)
		if(explode_from_drone):
			var bomb := bomb_scene.instantiate()
			bomb.position = parent_zombie.position + Vector2(0, 0)  # Adjust starting position
			parent_zombie.get_parent().add_child(bomb)

		emit_signal("enemy_died", self)

		var gameLayer := parent_zombie.get_parent()
		var currentLevel := gameLayer.get_parent()
		var demon_manager := currentLevel.get_node("DemonManager")

		if demon_manager:
			demon_manager.add_blood(bloodWorth)
		else:
			pass

		parent_zombie.die()
