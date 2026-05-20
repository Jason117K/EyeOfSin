extends Demon
#Occulum.gd



@onready var madeTutorialBlood = false
@onready var bloodTimer = $BloodTimer
@onready var resetEatingTimer = $ResetEatingSpeed
@export var bloodWaitTime := 30.0
@export var wyrmBloodWaitTime :=  50.0
@export var hiveBloodWaitTime := 17.0
@export var crawlerBloodWaitTime := 23.0 
@export var heal_interval_wait_time := 2
@export var hive_burst_heal_amount := 50
@export var spinal_occulum_heal_over_time_amount := 5

@export var maw_health = 500

@onready var buffNodes = $BuffNodesComponent
@onready var healTimer : Timer
@onready var healInvisTimer = $HealInvisTimer
@onready var healing_zone_sprite = $HealingAnimSprite
@onready var healZone := $HealZone
@onready var webbing_aoe_sprite = $Webs
@onready var tentacle := $Tentacle1
@onready var eat_zombie_blood_fx = [$BloodHit,$BloodHit2]
@onready var blood_hit_1 := $BloodHit

var BloodScene = preload("res://_Entities/Demons/Blood/Blood.tscn") 
var DemonManager
var spawnAnimDone = false
var tween
var highlight_active = false
var highlight_material = null
var original_material = null
var demons_to_heal = []
var max_alpha = 0.2
var lerp_duration = 2.5
var can_eat_zombie = false 
var num_healing_zone_sprite_plays := 0
var max_num_healing_zone_sprite_plays := 5

var num_blood_plays := 0
var max_num_blood_plays := 3


func _ready():
	super()
	print("Made Tutorial Blood is ", madeTutorialBlood)
	bloodTimer.wait_time = bloodWaitTime
	DemonManager = get_parent().get_parent().get_node("DemonManager") 
	bloodTimer.start()  
	bloodTimer.connect("timeout", Callable(self, "_on_BloodTimer_timeout"))
	blood_hit_1.animation_looped.connect(zombie_gore_fx)
	#animSpriteComp.play("spawn")

	
func toggle_highlight():
	print("Highlight Toggled")
	highlight_active = !highlight_active
	
	if highlight_active:
		animSpriteComp.material = highlight_material
	else:
		animSpriteComp.material = original_material	

func _on_BloodTimer_timeout():
	generate_blood()
	bloodTimer.start()
	
#TODO Rip Out and Put in Component
func generate_blood() -> Node2D:
	
	print("MadeTutorial Blood when it counts is ",madeTutorialBlood )
	if "Level0-2" in get_parent().get_parent().get_true_name():
		if madeTutorialBlood == false:
			pass
			print("Just Setting Made Tut Blood to True ")
			madeTutorialBlood = true 
		elif Global.gameIsStarted == false:
			print("NOT ON LEVEL 2",madeTutorialBlood )
			return 
	elif Global.gameIsStarted == false:
		print("NOT Generating BLood, Parent is : ",get_parent().get_parent().get_true_name())
		return 
	print("Generating BLood")
	
	
	if mawBuff:
		can_eat_zombie = true

		
	var blood_instance = BloodScene.instantiate()  
	if wyrmBuff:
		blood_instance.wyrm_buff()
	if hiveBuff:
		blood_instance.hive_buff()
	if crawlerBuff:
		blood_instance.crawler_buff()
	if mawBuff:
		blood_instance.maw_buff()
	
	if self.is_in_group("Green"):
		blood_instance.add_to_group("Green")
	else:
		blood_instance.add_to_group("Purple")
	blood_instance.set_origin_occulum(self)
	get_parent().add_child(blood_instance) 
	#Set the blood pos to above the occulum
	blood_instance.global_position = self.global_position + Vector2(0,-40)
	return blood_instance

			
func receive_buff(newDemon):
	var demonName =  (newDemon.get_demon_true_name()) #truncate_string(newDemon.name)
	if !isBuffed :
		super(demonName)
		print("Occulum Buff Received from ", demonName)
		match demonName:
			"Occulum":
				pass
			"Crawler":
				#$Webs.visible = true 
				#webbing_aoe_sprite.visible = true 
				#$SlowField.monitoring = true 
				bloodTimer.wait_time = crawlerBloodWaitTime
				bloodTimer.start()
				pass
			"SpinalOcculum" :
				set_up_healing()
				#healZone.visible = true 
				#healTimer.start()
				#start_alpha_pulse()
				#tween.play()
			"Wyrm":
				bloodTimer.wait_time = wyrmBloodWaitTime
				bloodTimer.start()
			"Hive":
				bloodTimer.wait_time = hiveBloodWaitTime
				bloodTimer.start()
			"Maw":
				can_eat_zombie = true


func set_up_healing():
	healTimer = Timer.new()
	healTimer.wait_time = heal_interval_wait_time
	healTimer.timeout.connect(_on_heal_timer_timeout)
	add_child(healTimer)
	healTimer.start()
	healing_zone_sprite.show()
	healing_zone_sprite.play()

func truncate_string(input_string: String) -> String:
	for i in range(input_string.length()):
		var character = input_string[i]
		if character.is_valid_int():
			return input_string.substr(0, i)
	return input_string
	
	
func debuff():
	pass
	#bloodTimer.wait_time = bloodWaitTime
	#isBuffed = false
	pass


# Demon Cost Getter
func get_cost():
	#print("1CCost is ", cost)
	cost = cost + (5 * Global.getOcculumCount())
	#print("2CCost is ", cost)
	return cost
	#cost = cost + 5
	
		
				
		
func die():
	DemonManager.clear_space(self.global_position)
	buffNodes.clearBuffs()
	queue_free()	
		
func die_fromClearSpace():
	print("Should Clear the DDD Buffs")
	buffNodes.clearBuffs()
	queue_free()		
		

func highlight():
	print("Highlight Here")		
		

func adjust_position(new_form):
	match new_form:
		"Occulum":
			pass

		"Crawler":
			print("Self pos was ", self.global_position)
			self.global_position = self.global_position + Vector2(0,-2)
			print("Self pos IS ", self.global_position)
			
		"SpinalOcculum" :
			print("Self pos was ", self.global_position)
			self.global_position = self.global_position + Vector2(0,-2)
			print("Self pos IS ", self.global_position)
			
		"Wyrm":
			print("Self pos was ", self.global_position)
			self.global_position = self.global_position + Vector2(0,-2)
			print("Self pos IS ", self.global_position)
			
		"Wasp":
			print("Self pos was ", self.global_position)
			self.global_position = self.global_position + Vector2(0,-2)
			print("Self pos IS ", self.global_position)
			
		"Maw":
			print("Self pos was ", self.global_position)
			self.global_position = self.global_position + Vector2(0,-2)
			print("Self pos IS ", self.global_position)	


func _on_slow_field_area_entered(area: Area2D) -> void:
	#print(area , " just entered snow field")
	if area.is_in_group("Zombie"):
		#print("Zombie Entered Slow Field")
		#if area.get_parent().get_parent() != self.get_parent().get_parent():
			#return
		#TODO Balance
		area.slow()

func burst_heal():
	pass
	healing_zone_sprite.show()
	healing_zone_sprite.play()
	healing_zone_sprite.animation_finished.connect(finish_burst)
	for demon in demons_to_heal:
		if demon != null:
			demon.increase_health(hive_burst_heal_amount)
	
func finish_burst():
	healing_zone_sprite.hide()
	
	
	
func _on_slow_field_body_entered(body: Node2D) -> void:
	#print(body , " just entered snow field b ")
	if body.is_in_group("Zombie"):
		#print("Zombie Entered Slow Field")
		#if area.get_parent().get_parent() != self.get_parent().get_parent():
			#return
		#TODO Balance
		body.slow()


func _on_heal_zone_area_entered(area: Area2D) -> void:
	if area.is_in_group("Demons"):
		demons_to_heal.append(area)


func _on_heal_timer_timeout() -> void:
	num_healing_zone_sprite_plays += 1
	if num_healing_zone_sprite_plays == max_num_healing_zone_sprite_plays:
		healing_zone_sprite.play()
		num_healing_zone_sprite_plays = 0
	for demon in demons_to_heal:
		if demon != null:
			demon.increase_health(spinal_occulum_heal_over_time_amount)
func get_demon_true_name():
	return "Occulum"
func get_demon_name():
	return "OCCULUM"
	
func get_damage():
	return "NONE"
	
func start_alpha_pulse():
	# Cancel any existing tween
	
	# Start with alpha at 0
	$HealZone.modulate.a = 0.0
	
	# Create infinite loop tween
	tween = create_tween().set_loops()
	
	# Lerp from 0 to max_alpha
	tween.tween_property($HealZone, "modulate:a", max_alpha, lerp_duration).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_IN)
	
	# Lerp back from max_alpha to 0
	tween.tween_property($HealZone, "modulate:a", 0.0, lerp_duration).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)


func eat_zombie(zombie_to_eat):
	animSpriteComp.speed_scale = 4
	#var resetSpeedEatingTimer = Timer.new()
	resetEatingTimer.start()
	can_eat_zombie = false
	#tentacle.show()
	#tentacle.retraction_finished.connect(hide_tentacle)
	#assign_tentacle_to_target(zombie_to_eat)
	pass

func assign_tentacle_to_target(target):
	tentacle.attack(target, true)
	
func hide_tentacle():
	tentacle.hide()

		
func _on_reset_eating_speed_timeout() -> void:
	animSpriteComp.speed_scale = 1
	generate_blood_alt()
	for effect in eat_zombie_blood_fx:
		effect.show()
		effect.play()

func zombie_gore_fx():
	num_blood_plays += 1
	if num_blood_plays <= max_num_blood_plays:
		pass
	else:
		for effect in eat_zombie_blood_fx:
			effect.hide()



func generate_blood_alt() -> Node2D:
	var blood_instance = BloodScene.instantiate()  
	get_parent().add_child(blood_instance)  
	#Set the blood pos to above the occulum
	blood_instance.global_position = self.global_position + Vector2(0,-40)
	return blood_instance


func _on_mouse_entered() -> void:
	$PreviewNodes/AnimatedSprite2D.visible = false
	$PreviewNodes.visible = true 


func _on_mouse_exited() -> void:
	$PreviewNodes.visible = false 


func _on_healing_anim_sprite_animation_finished() -> void:
	pass # Replace with function body.
	
	
	
	
	
	
	
	
	
	
