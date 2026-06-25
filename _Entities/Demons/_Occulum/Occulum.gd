extends Demon
#Occulum.gd

# --- Exports ---
@onready var madeTutorialBlood := false
@export var bloodWaitTime := 30.0
@export var wyrmBloodWaitTime := 50.0
@export var hiveBloodWaitTime := 17.0
@export var crawlerBloodWaitTime := 23.0
@export var heal_interval_wait_time := 2
@export var hive_burst_heal_amount := 50
@export var spinal_occulum_heal_over_time_amount := 5
@export var maw_health := 500
@export var ultimate_blood_value := 200
@export var mana_add_on_generate_blood := 100 

# --- Preloads ---
var BloodScene := preload("res://_Entities/Demons/Blood/Blood.tscn")

# --- State ---
var spawnAnimDone := false
var tween : Tween
var highlight_active := false
var highlight_material :Material = null
var original_material :Material = null
var demons_to_heal: Array = []
var max_alpha := 0.2
var lerp_duration := 2.5
var can_eat_zombie := false
var num_healing_zone_sprite_plays := 4
var max_num_healing_zone_sprite_plays := 5
var is_demo := false
var is_demo_blood_spawn := false
var num_blood_plays := 0
var max_num_blood_plays := 3
var demo_fast_wait_time := 3.0
var cost_first_discount := 15 

# --- Component References ---
@onready var bloodTimer := $BloodTimer
@onready var resetEatingTimer := $ResetEatingSpeed
#@onready var healInvisTimer := $HealInvisTimer
@onready var healing_zone_sprite := $HealingAnimSprite
@onready var healZone := $HealZone
@onready var webbing_aoe_sprite := $Webs
#@onready var tentacle := $Tentacle1
@onready var eat_zombie_blood_fx := [$BloodHit, $BloodHit2]
@onready var blood_hit_1 := $BloodHit


@onready var num_cheap_occulum : int = Global.num_cheap_occulum

var healTimer: Timer

signal occulum_buff_unlocked(buff_to_unlock:String)

var ultimate_buffed := false 


# --- Lifecycle ---

func _ready() -> void:
	super()
	occulum_buff_unlocked.connect(Global.unlock_buff)
	num_cheap_occulum = 4
	_init_collision_mask(healZone,false)


	
	Global.register_occulum(self)
	# --- Timer setup ---
	bloodTimer.wait_time = bloodWaitTime
	bloodTimer.connect("timeout", Callable(self, "_on_BloodTimer_timeout"))
	blood_hit_1.animation_looped.connect(zombie_gore_fx)
	if Global.gameIsStarted:
		bloodTimer.start()
	
	hide_old_preview()

	all_synergies = Global.all_occulum_synergies
	special_description_file = get_special_description_file(all_synergies,"Base")

func hide_old_preview()->void:
	print("Occulum Hide Old Preview")
	$PreviewNodes/PreviewCard.visible = false 
	$PreviewNodes/PreviewCardSprite.visible = false 
	$PreviewNodes/PreviewCardShadow.visible = false 
	
func start_blood_timer()->void:
	bloodTimer.start()

# --- Getters ---

func get_demon_true_name() -> String:
	return "Occulum"

func get_demon_name() -> String:
	return "OCCULUM"

func get_damage() -> String:
	return "NONE"

func get_cost() -> float:
	#if Global.getOcculumCount() > 3:
		#cost_flat_modifier = 10
		
	#15,25
	
	if Global.getOcculumCount() <= 4:
		print("Cost in Occulum Was ", cost)
		cost = cost + (Global.getOcculumCount() * 15)
		print("Cost in Occulum Is Now ", cost)
	else:
		cost = cost + ( ((Global.getOcculumCount()-4) * 25) + (4 * 15) )
	print(Global.getOcculumCount() , " Cost in ",4 ,"Occulum is ", cost)
	return cost 


# --- Buff System ---

func receive_buff(newDemon) -> void:
	var demonName :String= (newDemon.get_demon_true_name())
	if !isBuffed:
		unlock_new_buff(demonName)
		super(demonName)
		
		match demonName:
			"Occulum":
				pass
			"Crawler":

				
				bloodTimer.wait_time = crawlerBloodWaitTime
				bloodTimer.start()
			"SpinalOcculum":
				set_up_healing()
			"Wyrm":
				bloodTimer.wait_time = wyrmBloodWaitTime
				bloodTimer.start()
			"Hive":
				bloodTimer.wait_time = hiveBloodWaitTime
				bloodTimer.start()
			"Maw":
				can_eat_zombie = true
		if is_demo && !is_demo_blood_spawn:
			demo_blood_pickup()


func debuff() -> void:
	super()
	bloodTimer.wait_time = bloodWaitTime
	can_eat_zombie = false

func unlock_new_buff(demonName)->void:
	if isBuffed == false:
		if Global.game_controller.current_scenes.size()>1:
			match demonName:
				"Occulum":
					pass
				"Crawler":
					occulum_buff_unlocked.emit(Global.crawler_occulum_synergy)
				"SpinalOcculum":
					occulum_buff_unlocked.emit(Global.spinal_occulum_occulum_synergy)
				"Wyrm":
					occulum_buff_unlocked.emit(Global.wyrm_occulum_synergy)
				"Hive":
					occulum_buff_unlocked.emit(Global.hive_occulum_synergy)
				"Maw":
					occulum_buff_unlocked.emit(Global.maw_occulum_synergy)
					
					
					
# --- Death ---

func _cleanup() -> void:
	# No extra cleanup beyond base buffNodes
	super()


# --- Highlight ---

func toggle_highlight() -> void:
	highlight_active = !highlight_active
	if highlight_active:
		animSpriteComp.material = highlight_material
	else:
		animSpriteComp.material = original_material

func highlight() -> void:
	pass
	#print("Highlight Here")


# --- Blood Generation ---

func _on_BloodTimer_timeout() -> void:
	generate_blood()
	bloodTimer.start()
	
func force_generate_blood()->Node2D:
	#print("Force Blood Gen")
	var blood_instance := BloodScene.instantiate()
	if self.is_in_group("Green"):
		blood_instance.add_to_group("Green")
	else:
		blood_instance.add_to_group("Purple")
	blood_instance.set_origin_occulum(self)
	get_parent().add_child(blood_instance)
	blood_instance.global_position = self.global_position + Vector2(0, -40)
	return blood_instance
	
func generate_blood() -> Node2D:
	if Global.gameIsStarted == false:
		#print("Game Not Started Cannot Generate")
		return
	Global.add_mana(mana_add_on_generate_blood)
	if mawBuff:
		can_eat_zombie = true

	var blood_instance := BloodScene.instantiate()
	if wyrmBuff:
		blood_instance.wyrm_buff()
	if hiveBuff:
		blood_instance.hive_buff()
	if crawlerBuff:
		blood_instance.crawler_buff()
	if mawBuff:
		blood_instance.maw_buff()
	if ultimate_buffed:
		blood_instance.ultimate_buff(ultimate_blood_value)
		ultimate_buffed = false
		
	if self.is_in_group("Green"):
		blood_instance.add_to_group("Green")
	else:
		blood_instance.add_to_group("Purple")
	blood_instance.set_origin_occulum(self)
	get_parent().add_child(blood_instance)
	if is_demo:
		blood_instance.set_demo_true()
	blood_instance.global_position = self.global_position + Vector2(0, -40)
	return blood_instance

func generate_blood_alt() -> Node2D:
	var blood_instance := BloodScene.instantiate()
	get_parent().add_child(blood_instance)
	blood_instance.global_position = self.global_position + Vector2(0, -40)
	return blood_instance


# --- Healing (SpinalOcculum Buff) ---

func set_up_healing() -> void:
	healTimer = Timer.new()
	healTimer.wait_time = heal_interval_wait_time
	healTimer.timeout.connect(_on_heal_timer_timeout)
	add_child(healTimer)
	healTimer.start()
	healing_zone_sprite.show()
	healing_zone_sprite.play()

func _on_heal_zone_area_entered(this_area: Area2D) -> void:
	if this_area.is_in_group("Demons"):
		demons_to_heal.append(this_area)

func _on_heal_timer_timeout() -> void:
	if isBuffed:
		num_healing_zone_sprite_plays += 1
		if num_healing_zone_sprite_plays == max_num_healing_zone_sprite_plays:
			healing_zone_sprite.play()
			num_healing_zone_sprite_plays = 0
		for demon:Demon in demons_to_heal:
			if demon != null:
				if demon != self:
					demon.increase_health(spinal_occulum_heal_over_time_amount)

func burst_heal() -> void:
	pass
	healing_zone_sprite.show()
	healing_zone_sprite.play()
	healing_zone_sprite.animation_finished.connect(finish_burst)
	for demon : Demon in demons_to_heal:
		if demon != null:
			demon.increase_health(hive_burst_heal_amount)

func finish_burst() -> void:
	healing_zone_sprite.hide()

func start_alpha_pulse() -> void:
	$HealZone.modulate.a = 0.0
	tween = create_tween().set_loops()
	tween.tween_property($HealZone, "modulate:a", max_alpha, lerp_duration).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_IN)
	tween.tween_property($HealZone, "modulate:a", 0.0, lerp_duration).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)

func _on_healing_anim_sprite_animation_finished() -> void:
	pass





# --- Slow Field ---

func _on_slow_field_area_entered(this_area: Area2D) -> void:
	if this_area.is_in_group("Zombie"):
		this_area.slow()

func _on_slow_field_body_entered(body: Node2D) -> void:
	if body.is_in_group("Zombie"):
		body.slow()


# --- Eat Zombie (Maw Buff) ---

func eat_zombie(_zombie_to_eat: Area2D) -> void:
	animSpriteComp.speed_scale = 4
	resetEatingTimer.start()
	can_eat_zombie = false

#func assign_tentacle_to_target(target: Node2D) -> void:
	#tentacle.attack(target, true)
#
#func hide_tentacle() -> void:
	#tentacle.hide()

func _on_reset_eating_speed_timeout() -> void:
	animSpriteComp.speed_scale = 1
	generate_blood_alt()
	for effect:Node in eat_zombie_blood_fx:
		effect.show()
		effect.play()

func zombie_gore_fx() -> void:
	num_blood_plays += 1
	if num_blood_plays <= max_num_blood_plays:
		pass
	else:
		for effect:Node in eat_zombie_blood_fx:
			effect.hide()

func baal_buff()->void:
	super()
	baal_halo.play("back")

func undo_baal_buff()->void:
	super()

func _on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if Global.ultimate_is_ready:
		if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			if spawn_done:
				trigger_ultimate()
	else:
		super(_viewport,event,_shape_idx)


func trigger_ultimate()->void:
	print("Trigger Occulum Ult")
	Global.un_ready_ultimate()
	ultimate_buffed = true 
	generate_blood()
	
	
	
# --- Preview ---


func _on_mouse_exited() -> void:
	$PreviewNodes.visible = false



# --- Position Adjustment ---

func adjust_position(new_form: String) -> void:
	match new_form:
		"Occulum":
			pass
		"Crawler":
			self.global_position = self.global_position + Vector2(0, -2)
		"SpinalOcculum":
			self.global_position = self.global_position + Vector2(0, -2)
		"Wyrm":
			self.global_position = self.global_position + Vector2(0, -2)
		"Wasp":
			self.global_position = self.global_position + Vector2(0, -2)
		"Maw":
			self.global_position = self.global_position + Vector2(0, -2)


# --- Utilities ---

func truncate_string(input_string: String) -> String:
	for i in range(input_string.length()):
		var character := input_string[i]
		if character.is_valid_int():
			return input_string.substr(0, i)
	return input_string


# --- Demo ---

func demo_blood_pickup() -> void:
	is_demo = true
	if isBuffed && mawBuff == false:
		is_demo_blood_spawn = true
		bloodTimer.wait_time = demo_fast_wait_time
		bloodTimer.start()
