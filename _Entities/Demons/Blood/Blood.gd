extends Area2D
#Blood.gd


@export var BloodValue = 50
@export var BloodDamage := 50 
@export var default_auto_pickup_wait_time := 6.0
@export var crawler_buff_auto_pickup_wait_time := 10.0
@onready var aoe : Area2D = $AOEZone
@onready var auto_pickup_timer :Timer = $AutoPickUpTimer
var crawlerBuff := false
var demons_to_heal = []
var nearby_zombies = []
var temp_zombie_container = []
var current_zombie_target :Zombie 
var dissappear_time := 0.75


func _ready() -> void:
	input_pickable = true
	aoe.set_collision_mask_value(self.collision_mask,true)
	#AudioManager.create_2d_audio_at_location(self.global_position, SoundEffect.SOUND_EFFECT_TYPE.ZOMBIE_TAKE_DAMAGE)
	self.mouse_entered.connect(_on_Blood_mouse_entered)
	
	if crawlerBuff:
		auto_pickup_timer.wait_time = crawler_buff_auto_pickup_wait_time
		
	auto_pickup_timer.start()
		
	if self.is_in_group("Green"):
		aoe.set_collision_mask_value(1,false)
		aoe.set_collision_mask_value(2,false)
		aoe.set_collision_mask_value(3,true)
	else:
		aoe.set_collision_mask_value(1,false)
		aoe.set_collision_mask_value(2,true)
		aoe.set_collision_mask_value(3,false)

	
#TODO Add SFX
func _on_Blood_mouse_entered():
	var demon_manager = get_parent().get_parent().get_node("DemonManager")
	if demon_manager:
		demon_manager.add_blood(BloodValue)  # Add 25 blood points (or whatever amount)
		demon_manager.play_blood_collect()
		heal_demons()
	if crawlerBuff:
		temp_zombie_container = aoe.get_overlapping_areas()
		for zombie in temp_zombie_container:
			if zombie.is_in_group("Zombie"):
				nearby_zombies.append(zombie)		
		if nearby_zombies.is_empty() == true:
			print("NO NEARBY ZOMBIES : ", nearby_zombies)
			queue_free()
		else:
			nearby_zombies = aoe.get_overlapping_areas()
			for zombie in nearby_zombies:
				if zombie.is_in_group("Zombie"):
					current_zombie_target = zombie 
			print("Nearby Zombies is ",nearby_zombies, " current zombie is " ,current_zombie_target )
			#TODO Sort By Health
			attack_zombie(current_zombie_target)
			return
	queue_free()

func free_blood():
	if current_zombie_target != null:
		current_zombie_target.getCompManager().take_damage(BloodDamage)
		current_zombie_target.getCompManager().slow()
	queue_free()

func attack_zombie(zombie_to_attack):
	var tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(self, "global_position", zombie_to_attack.global_position, dissappear_time)
	var disappear_timer = Timer.new()
	disappear_timer.timeout.connect(free_blood)
	disappear_timer.wait_time = dissappear_time
	add_child(disappear_timer)
	disappear_timer.start()


	
	
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
	AudioManager.create_2d_audio_at_location(self.global_position, SoundEffect.SOUND_EFFECT_TYPE.SUN_COLLECT)
	BloodValue = BloodValue / 2
	var demon_manager = get_parent().get_parent().get_node("DemonManager")
	if demon_manager:  # If the DemonManager or GameManager is set
		demon_manager.add_blood(BloodValue)  # Add 25 blood points (or whatever amount)
		demon_manager.play_blood_collect()
		heal_demons()
	queue_free()

func setWorth(bloodWorth):
	BloodValue = bloodWorth
	
func crawler_buff():
	crawlerBuff = true
	
func wyrm_buff():
	self.scale = Vector2(1.2,1.2)
	BloodValue = 150 
	
func hive_buff():
	pass
	


func _on_heal_zone_area_entered(area: Area2D) -> void:
	if area.is_in_group("Demons"):
		demons_to_heal.append(area)

func _on_aoe_zone_area_exited(area: Area2D) -> void:
	if area.is_in_group("Demons"):
		demons_to_heal.erase(area)
