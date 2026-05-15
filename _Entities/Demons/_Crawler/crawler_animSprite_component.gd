extends DemonSpriteComp


func _ready():
	super()
	frame_changed.connect(_on_AnimatedSprite_frame_changed)

func spawn_done():
	
	if spawnAnimDone:
		animation = currentAnim
		play()
	else:
		position = Vector2(position.x, position.y -8.5)
		animation = currentAnim
		play()
		spawnAnimDone = true 

func _on_AnimatedSprite_frame_changed():
	emit_signal("frame_changed_signal", animation, frame)
		#if(animation.contains("ttack")):
			##print("The frame is ", animSpriteComp.frame)
			#if(frame == 3):
				#demon.shoot_projectile()

func _on_animation_finished():
	super()
	if demon.get_can_attack():
		animation = currentAttackAnim
		play()
	else:
			animation = currentAnim
			play()

func receive_buff(demonName):
	super(demonName)
	match demonName:
		"SpinalOcculum" :
			speed_scale = 0.7
		"Hive":
			speed_scale = 1.3
