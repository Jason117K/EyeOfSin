extends Area2D
#Sun.gd

#Adjustable sun value 
@export var SunValue = 50

var demons_to_heal = []


func _ready() -> void:
	input_pickable = true
	#print("SSCollision Layer: ", collision_layer)
	#print("SSCollision Mask: ", collision_mask)
	#print("SSInput Pickable: ", input_pickable)
	AudioManager.create_2d_audio_at_location(self.global_position, SoundEffect.SOUND_EFFECT_TYPE.ZOMBIE_TAKE_DAMAGE)
	#process_mode = Node.PROCESS_MODE_ALWAYS
	
#Handle sun collection 
func _on_Sun_mouse_entered():
	#print("SS Mouse Entered")
	#$CollectAudioPlayer.play()
	#AudioManager.create_2d_audio_at_location(self.global_position, SoundEffect.SOUND_EFFECT_TYPE.SUN_COLLECT)

	var demon_manager = get_parent().get_parent().get_node("DemonManager")
	if demon_manager:  # If the DemonManager or GameManager is set
		#$CollectAudioPlayer.play()
		demon_manager.add_sun(SunValue)  # Add 25 sun points (or whatever amount)
		demon_manager.play_sun_collect()
		heal_demons()
	# Queue the sun for deletion (simulate absorption)
	queue_free()

func heal_demons():
	for demon in demons_to_heal:
		if demon == null:
			demons_to_heal.erase(demon)
		if demon != null:
			if demon.is_node_ready():
			#	print("Demon is ", demon )
				demon.increase_health(100)
			
		pass

func _on_auto_pick_up_timer_timeout() -> void:
	#$CollectAudioPlayer.play()
	AudioManager.create_2d_audio_at_location(self.global_position, SoundEffect.SOUND_EFFECT_TYPE.SUN_COLLECT)
	#print("SSun Auto Pickup")
	SunValue = SunValue / 2
	#var root = get_tree().current_scene
	#print("SS root is ", root )
	var demon_manager = get_parent().get_parent().get_node("DemonManager")
	#print("DemonManager SS : ", demon_manager)
	if demon_manager:  # If the DemonManager or GameManager is set
		#$CollectAudioPlayer.play()
		demon_manager.add_sun(SunValue)  # Add 25 sun points (or whatever amount)
		demon_manager.play_sun_collect()
		heal_demons()
	# Queue the sun for deletion (simulate absorption)
	queue_free()

func setWorth(bloodWorth):
	SunValue = bloodWorth
	
	
func wyrm_buff():
	self.scale = Vector2(1.2,1.2)
	SunValue = 150 
	
func hive_buff():
	pass
	
	
	
	


func _on_heal_zone_area_entered(area: Area2D) -> void:
	if area.is_in_group("Demons"):
		demons_to_heal.append(area)
