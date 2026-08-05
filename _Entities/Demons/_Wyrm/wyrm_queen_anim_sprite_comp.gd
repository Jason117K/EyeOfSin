extends DemonSpriteComp

signal frame_changed_signal(animation_name: String, frame_index: int)

func receive_buff(_demonName: String) -> void:
	pass

func spawn_done() -> void:
	#print("Wyrm Queen Spawn Done Called ")
	if spawnAnimDone:
		pass
	else:
		speed_scale = default_anim_speed_scale
		play()
		spawnAnimDone = true
		demon.can_show_preview = true 
		#print("Wyrm Queen Can Show Pre")
		
		
