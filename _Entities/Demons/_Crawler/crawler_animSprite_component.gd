extends DemonSpriteComp


func spawn_done():
	
	if spawnAnimDone:
		#print("Spyder Self Spawn Adjust 1")
		animation = currentAnim
		play()
	else:
		#print("Spyder Self Spawn Adjust 2")
		position = Vector2(position.x, position.y -8.5)
		animation = currentAnim
		play()
		spawnAnimDone = true 


func _on_animation_finished():
	super()
	if demon.canAttack:
		#print(self, "Should Be Red Spider AttackZ")
		animation = currentAttackAnim
		play()
	else:
			animation = currentAnim
			play()
