extends DemonSpriteComp

var has_shot := false 

func _ready() -> void:
	super()
	frame_changed.connect(_on_AnimatedSprite_frame_changed)
	#animation_finished.connect(_on_AnimatedSprite_animation_finished)

func _on_AnimatedSprite_frame_changed() -> void:
	emit_signal("frame_changed_signal", animation, frame)

func _on_animation_finished() -> void:
	super()
	if demon.get_can_attack():
		animation = currentAttackAnim
		play()
	else:
		animation = currentAnim
		play()
				
#func _on_AnimatedSprite_animation_finished():
	#has_shot = false
	##if animSpriteComp.animation == "attack":
		##beatOfDeathCirle.scale = EXPAND_SCALE
		##beatOfDeathCirle.modulate.a = 0.0
	#
	#if animation == "spawn":
		#$LightningSpawn.play()
		#visible = false
		##spawn_done()
		#return
	#demon.check_attack_rays()
	#if demon.canAttack:
		#animation = currentAttackAnim
	#else:
		#animation = currentAnim
	#
	#play()
	
func spawn_done() -> void:
	if spawnAnimDone:
		animation = currentAnim
		play()
	else:
		position = Vector2(position.x, position.y -8.5)
		animation = currentAnim
		play()
		spawnAnimDone = true 
		
