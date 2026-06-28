extends Area2D
#Blood.gd


@export var BloodValue :float = 25
@export var BloodDamage :float = 50
@export var default_auto_pickup_wait_time := 6.0
@export var crawler_buff_auto_pickup_wait_time := 10.0
@export var wyrm_buff_auto_pickup_wait_time := 10.0
@export var fast_pick_up_time := 1.5
var demo_blood_pickup_time := 1.25

@onready var aoe: Area2D = $AOEZone
@onready var auto_pickup_timer: Timer = $AutoPickUpTimer
@onready var heal_anim := $HealingAnimSprite
@onready var demon_manager : Node = get_parent().get_parent().get_node("DemonManager")
@onready var animation_player : AnimationPlayer = $AnimationPlayer
@onready var anim_sprite : AnimatedSprite2D = $AnimatedSprite2D

var play_auto_blood_collect_sound_fx := true

var blood_spell := preload("res://_Entities/Demons/_Occulum/sword_blood_spell.tscn")
var crawlerBuff := false
var wyrmBuff := false
var hiveBuff := false
var demons_to_heal: Array[Demon]
var nearby_zombies: Array[Zombie]
var temp_zombie_container: Array = []
var current_zombie_target: Zombie
var dissappear_time := 0.75
var origin_occulum: Demon
var decrease_blood_val := true
var highest_health :float = -1
var current_target_health :float = 1
var counter :float = 0
var _spawn_tick_msec: int = 0

func _ready() -> void:
	_spawn_tick_msec = Time.get_ticks_msec()
	animation_player.animation_finished.connect(alt_free_blood)
	input_pickable = true
	aoe.set_collision_mask_value(self.collision_mask,true)
	#AudioManager.create_2d_audio_at_location(self.global_position, SoundEffect.SOUND_EFFECT_TYPE.ZOMBIE_TAKE_DAMAGE)
	self.mouse_entered.connect(_on_Blood_mouse_entered)
	
	if crawlerBuff:
		auto_pickup_timer.wait_time = crawler_buff_auto_pickup_wait_time
		anim_sprite.animation = "web_beat"
		self.modulate = Color(1.697, 1.2, 1.001)
	if wyrmBuff:
		auto_pickup_timer.wait_time = wyrm_buff_auto_pickup_wait_time
	print(self," time at start1 is ", counter, " has scale of ", self.scale)
	auto_pickup_timer.timeout.connect(_on_auto_pick_up_timer_timeout)
	auto_pickup_timer.start()
	print(self," time at start2 is ", counter, " has scale of ", self.scale)
	#Must Look For Zombies AND Demons
	if self.is_in_group("Green"):
		aoe.set_collision_mask_value(1,false)
		aoe.set_collision_mask_value(2,false)
		aoe.set_collision_mask_value(3,true)
		aoe.set_collision_mask_value(4,false)
		aoe.set_collision_mask_value(5,true)
	else:
		aoe.set_collision_mask_value(1,false)
		aoe.set_collision_mask_value(2,true)
		aoe.set_collision_mask_value(3,false)
		aoe.set_collision_mask_value(4,true)


	
#TODO Add SFX
func _on_Blood_mouse_entered() -> void:
	#var demon_manager = get_parent().get_parent().get_node("DemonManager")
	#print("Demon Manager is ", demon_manager)
	if self.is_in_group("Green"):
		if Global.game_controller.get_active_dimension() == Global.game_controller.get_green_dimension():
			pass
		else:
			return
	elif self.is_in_group("Purple"):
		if Global.game_controller.get_active_dimension() == Global.game_controller.get_purple_dimension():
			pass
		else:
			return
	
	
	auto_pickup_timer.stop()
	if demon_manager:
		demon_manager.add_blood(BloodValue)  # Add 25 blood points (or whatever amount)
		demon_manager.play_blood_collect()
		if hiveBuff:
			#print("About to Heal Demons")
			heal_demons()
			return
		
	if crawlerBuff:
		print("PickUp Crawler Blood Cos Mouse Entered")
		crawler_blood_pickup()
		return
			
	if wyrmBuff:
		summon_blood_swords()
	#if hiveBuff:
		#if origin_occulum != null:
			#origin_occulum.burst_heal()
	$CollisionShape2D.disabled = true 
	self.monitoring = false
	self.monitorable = false 
	self.input_pickable = false
	animation_player.play("pickup")
	#queue_free()

func alt_free_blood(_anim_name := "")->void:
	print("Alt Free Blood Called")
	queue_free()


func free_blood() -> void:
	if current_zombie_target != null:
		current_zombie_target.take_damage(false,BloodDamage,false)
		current_zombie_target.slow()
	print("Regular Free Blood Called")
	queue_free()
	
func _on_zombie_died(dead_zombie:Zombie)->void:
	nearby_zombies.erase(dead_zombie)
	pass

func crawler_blood_pickup() -> void:
	print("Overlapping Areas Is ", aoe.get_overlapping_areas())
	temp_zombie_container = aoe.get_overlapping_areas()
	for zombie:Node in temp_zombie_container:
		if zombie.is_in_group("Zombie"):
			nearby_zombies.append(zombie)
			if not zombie.this_zombie_died.is_connected(_on_zombie_died):
				zombie.this_zombie_died.connect(_on_zombie_died)
	if nearby_zombies.is_empty() == true:
		print("NO NEARBY ZOMBIES : ", nearby_zombies)
		$CollisionShape2D.disabled = true 
		self.monitoring = false
		self.monitorable = false 
		self.input_pickable = false
		animation_player.play("pickup")
		#queue_free()
	else:
		#nearby_zombies = aoe.get_overlapping_areas()
		#TODO Make Sort By Health
		highest_health = -1
		for zombie in nearby_zombies:
			if zombie != null && is_instance_valid(zombie):
				if not zombie.has_method("get_health"):
					continue
				current_target_health = zombie.get_health()
				if current_target_health > highest_health && zombie != null:
					highest_health = current_target_health
					current_zombie_target = zombie
		print("Nearby Zombies is ",nearby_zombies, " current zombie is " ,current_zombie_target )
		#TODO Sort By Health
		if current_zombie_target != null && is_instance_valid(current_zombie_target):
			attack_zombie(current_zombie_target)
		else:
			queue_free()

func summon_blood_swords() -> void:
	if origin_occulum != null:
		print("Summon Blood Sword")
	else:
		print("Origin Occulum is now ", origin_occulum)
		queue_free()
	spawn_blood_sword(Vector2(49,-8))
	spawn_blood_sword(Vector2(113,-8))

	
func spawn_blood_sword(offset: Vector2) -> void:
	if origin_occulum != null:
		var blood_spell_instance := blood_spell.instantiate()
		if self.is_in_group("Green"):
			blood_spell_instance.set_collision_mask_value(1,false)
			blood_spell_instance.set_collision_mask_value(2,false)
			blood_spell_instance.set_collision_mask_value(3,false)
			blood_spell_instance.set_collision_mask_value(4,false)
			blood_spell_instance.set_collision_mask_value(5,true)
		else:
			blood_spell_instance.set_collision_mask_value(1,false)
			blood_spell_instance.set_collision_mask_value(2,false)
			blood_spell_instance.set_collision_mask_value(3,false)
			blood_spell_instance.set_collision_mask_value(4,true)
		
		#blood_spell_instance.global_position = origin_occulum.global_position # + offset
		origin_occulum.get_parent().add_child(blood_spell_instance)
		blood_spell_instance.global_position = origin_occulum.global_position + offset
		print("Blood Sword Damage Zombies SHOULD BE at position global : ", blood_spell_instance.global_position , " and position local ", blood_spell_instance.position )
	
	
	
func set_origin_occulum(parent_occulum : Demon) -> void:
	#print("Origin Occulum is ", parent_occulum)
	origin_occulum = parent_occulum
		
	
func attack_zombie(zombie_to_attack : Zombie) -> void:
	var tween := create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(self, "global_position", zombie_to_attack.global_position, dissappear_time)
	var disappear_timer := Timer.new()
	disappear_timer.timeout.connect(free_blood)
	disappear_timer.wait_time = dissappear_time
	add_child(disappear_timer)
	disappear_timer.start()


	
	
func heal_demons() -> void:
	#print("Overlapping Areas Is ", aoe.get_overlapping_areas())
	for entity in aoe.get_overlapping_areas():
		if entity.is_in_group("Demons"):
			demons_to_heal.append(entity)
	#print("Demons to heal is ", demons_to_heal)

	for demon in demons_to_heal:
		if demon == null:
			demons_to_heal.erase(demon)
		if demon != null:
			if demon.is_node_ready():
				print("Demon is ", demon )
				demon.increase_health(100)
			else:
				print("Demon is not ready ", demon)
	heal_anim.play()
	clear_heal_aoe()

func clear_heal_aoe() -> void:
	while demons_to_heal.size() > 0:
		demons_to_heal.pop_back()
	demons_to_heal.clear()

func _on_auto_pick_up_timer_timeout() -> void:
	print("Origin Occulum is ", origin_occulum)
	var elapsed_sec := (Time.get_ticks_msec() - _spawn_tick_msec) / 1000.0
	var dim := "Green" if is_in_group("Green") else "Purple"
	print("[BLOOD AUTOPICKUP] dim=", dim, " configured_wait=", auto_pickup_timer.wait_time, "s  actual_elapsed=", elapsed_sec, "s  value_before_halving=", BloodValue, " counter=", counter)
	if play_auto_blood_collect_sound_fx:
		AudioManager.create_2d_audio_at_location(self.global_position, SoundEffect.SOUND_EFFECT_TYPE.SUN_COLLECT)
	if decrease_blood_val:
		BloodValue = BloodValue / 2.0

	if demon_manager:  # If the DemonManager or GameManager is set
		demon_manager.add_blood(BloodValue)  # Add 25 blood points (or whatever amount)
		demon_manager.play_blood_collect()
		if hiveBuff:
			print("About to Heal Demons")
			heal_demons()
			return
		if crawlerBuff:
			print("PickUp Crawler Blood Cos Time Ran Out",get_parent().get_parent())
			print(self, " has scale of ", self.scale)
			crawler_blood_pickup()
			return
		if wyrmBuff:
			summon_blood_swords()
	queue_free()

func setWorth(bloodWorth: int) -> void:
	BloodValue = bloodWorth

func ultimate_buff(ultimate_blood_value : int)->void:
	self.scale = Vector2(1.75,1.75)
	BloodValue = ultimate_blood_value

func crawler_buff() -> void:
	crawlerBuff = true

func wyrm_buff() -> void:
	self.scale = Vector2(1.2,1.2)
	BloodValue = 75
	wyrmBuff = true

func hive_buff() -> void:
	hiveBuff = true

func maw_buff() -> void:
	BloodValue = 100

func set_fast_pickup_time() -> void:
	auto_pickup_timer.wait_time = fast_pick_up_time
	auto_pickup_timer.start()
	decrease_blood_val = false
	self.scale = Vector2(0.3,0.3)
	BloodValue = 2.0
	play_auto_blood_collect_sound_fx = false
	#BloodValue = 150 
	
	


#func _on_heal_zone_area_entered(area: Area2D) -> void:
	#if area.is_in_group("Demons"):
		#demons_to_heal.append(area)
#
#func _on_aoe_zone_area_exited(area: Area2D) -> void:
	#if area.is_in_group("Demons"):
		#demons_to_heal.erase(area)

func set_demo_true() -> void:
	auto_pickup_timer.wait_time = demo_blood_pickup_time
	auto_pickup_timer.start()
	


func _on_healing_anim_sprite_animation_finished() -> void:
	queue_free()


func _physics_process(delta: float) -> void:
	if counter != null:
		counter += delta
