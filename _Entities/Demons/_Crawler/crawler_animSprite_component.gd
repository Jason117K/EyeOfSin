extends DemonSpriteComp
signal frame_changed_signal(animation_name: String, frame_index: int)


func _ready():
	super()
	frame_changed.connect(_on_AnimatedSprite_frame_changed)

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

func _on_AnimatedSprite_frame_changed():
	emit_signal("frame_changed_signal", animation, frame)
		#if(animation.contains("ttack")):
			##print("The frame is ", animSpriteComp.frame)
			#if(frame == 3):
				##print("ABOUT Shoot Proj From Spider ")
				#demon.shoot_projectile()

func _on_animation_finished():
	super()
	if demon.get_can_attack():
		#print(self, "Should Be Red Spider AttackZ")
		animation = currentAttackAnim
		play()
	else:
			animation = currentAnim
			play()

func receiveBuff(demonName):
	#print("Buff Name is ", newPlant.name)
	if !demon.get_is_buffed():
		match demonName:
			"WalnutTree" :
				speed_scale = 0.7
			"Hive":
				speed_scale = 1.3
