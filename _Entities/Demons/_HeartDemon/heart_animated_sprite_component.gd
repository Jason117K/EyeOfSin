extends DemonSpriteComp

var has_shot := false 

func _ready() -> void:
	super()
	frame_changed.connect(_on_AnimatedSprite_frame_changed)
	animation_finished.connect(_on_AnimatedSprite_animation_finished)

func _on_AnimatedSprite_frame_changed():
	if self != null:
		if( animation.contains("ttack") ):
			if(frame == 3) && not has_shot:
				has_shot = true
				demon.shoot_projectile()
			if(frame == 2):
				has_shot = false
				
				
func _on_AnimatedSprite_animation_finished():
	has_shot = false
	#if animSpriteComp.animation == "attack":
		#beatOfDeathCirle.scale = EXPAND_SCALE
		#beatOfDeathCirle.modulate.a = 0.0
	
	if animation == "spawn":
		$LightningSpawn.play()
		visible = false
		#spawn_done()
		return
	demon.check_attack_rays()
	if demon.canAttack:
		animation = currentAttackAnim
	else:
		animation = currentAnim
	
	play()
	
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
