extends DemonSpriteComp

signal frame_changed_signal(animation_name: String, frame_index: int)

var true_once:= false


func _ready() -> void:
	super()
	frame_changed.connect(_on_AnimatedSprite_frame_changed)

func spawn_done() -> void:
	
	if spawnAnimDone:
		animation = currentAnim
		play()
	else:
		position = Vector2(position.x, position.y -8.5)
		animation = currentAnim
		play()
		spawnAnimDone = true 
		demon.can_show_preview = true 

func _on_AnimatedSprite_frame_changed() -> void:
	emit_signal("frame_changed_signal", animation, frame)
		#if(animation.contains("ttack")):
			##print("The frame is ", animSpriteComp.frame)
			#if(frame == 3):
				#demon.shoot_projectile()

func _on_animation_finished() -> void:
	super()
	if !true_once:
		#print("Should Have Called Anim Finished")
		true_once = true
	# Attack timing is now controlled by the shoot timer,
	# not by checking canAttack on animation finish.

func receive_buff(demonName: String) -> void:
	super(demonName)
	match demonName:
		"SpinalOcculum" :
			speed_scale = 0.7
		"Hive":
			speed_scale = 1.3
