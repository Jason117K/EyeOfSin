extends Demon
#Occulum.gd

# --- Exports ---
@onready var madeTutorialBlood = false
@export var bloodWaitTime := 30.0
@export var wyrmBloodWaitTime := 50.0
@export var hiveBloodWaitTime := 17.0
@export var crawlerBloodWaitTime := 23.0
@export var heal_interval_wait_time := 2
@export var hive_burst_heal_amount := 50
@export var spinal_occulum_heal_over_time_amount := 5
@export var maw_health = 500

# --- Preloads ---
var BloodScene = preload("res://_Entities/Demons/Blood/Blood.tscn")

# --- State ---
var spawnAnimDone = false
var tween
var highlight_active = false
var highlight_material = null
var original_material = null
var demons_to_heal = []
var max_alpha = 0.2
var lerp_duration = 2.5
var can_eat_zombie = false
var num_healing_zone_sprite_plays := 4
var max_num_healing_zone_sprite_plays := 5
var is_demo := false
var is_demo_blood_spawn := false
var num_blood_plays := 0
var max_num_blood_plays := 3
var demo_fast_wait_time := 3.0

# --- Component References ---
@onready var bloodTimer = $BloodTimer
@onready var resetEatingTimer = $ResetEatingSpeed
@onready var healInvisTimer = $HealInvisTimer
@onready var healing_zone_sprite = $HealingAnimSprite
@onready var healZone := $HealZone
@onready var webbing_aoe_sprite = $Webs
@onready var tentacle := $Tentacle1
@onready var eat_zombie_blood_fx = [$BloodHit, $BloodHit2]
@onready var blood_hit_1 := $BloodHit

var healTimer : Timer


# --- Lifecycle ---

func _ready():
	super()
	# --- Timer setup ---
	bloodTimer.wait_time = bloodWaitTime
	bloodTimer.start()
	bloodTimer.connect("timeout", Callable(self, "_on_BloodTimer_timeout"))
	blood_hit_1.animation_looped.connect(zombie_gore_fx)


# --- Getters ---

func get_demon_true_name():
	return "Occulum"

func get_demon_name():
	return "OCCULUM"

func get_damage():
	return "NONE"

func get_cost():
	cost = cost + (5 * Global.getOcculumCount())
	return cost


# --- Buff System ---

func receive_buff(newDemon):
	var demonName = (newDemon.get_demon_true_name())
	if !isBuffed:
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

func debuff():
	super()


# --- Death ---

func _cleanup():
	# No extra cleanup beyond base buffNodes
	super()


# --- Highlight ---

func toggle_highlight():
	highlight_active = !highlight_active
	if highlight_active:
		animSpriteComp.material = highlight_material
	else:
		animSpriteComp.material = original_material

func highlight():
	print("Highlight Here")


# --- Blood Generation ---

func _on_BloodTimer_timeout():
	generate_blood()
	bloodTimer.start()

func generate_blood() -> Node2D:
	if get_parent().get_parent().has_method("get_true_name"):
		if "Level0-2" in get_parent().get_parent().get_true_name():
			if madeTutorialBlood == false:
				pass
				madeTutorialBlood = true
			elif Global.gameIsStarted == false:
				return
		elif Global.gameIsStarted == false:
			return

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
	if is_demo:
		blood_instance.set_demo_true()
	blood_instance.global_position = self.global_position + Vector2(0, -40)
	return blood_instance

func generate_blood_alt() -> Node2D:
	var blood_instance = BloodScene.instantiate()
	get_parent().add_child(blood_instance)
	blood_instance.global_position = self.global_position + Vector2(0, -40)
	return blood_instance


# --- Healing (SpinalOcculum Buff) ---

func set_up_healing():
	healTimer = Timer.new()
	healTimer.wait_time = heal_interval_wait_time
	healTimer.timeout.connect(_on_heal_timer_timeout)
	add_child(healTimer)
	healTimer.start()
	healing_zone_sprite.show()
	healing_zone_sprite.play()

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
			if demon != self:
				demon.increase_health(spinal_occulum_heal_over_time_amount)

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

func start_alpha_pulse():
	$HealZone.modulate.a = 0.0
	tween = create_tween().set_loops()
	tween.tween_property($HealZone, "modulate:a", max_alpha, lerp_duration).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_IN)
	tween.tween_property($HealZone, "modulate:a", 0.0, lerp_duration).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)

func _on_healing_anim_sprite_animation_finished() -> void:
	pass

func get_demon_icon()->CompressedTexture2D:
	return Global.occulum_icon
	
func get_special_description()->String:
	return Global.occulum_special_description
	
	
# --- Slow Field ---

func _on_slow_field_area_entered(area: Area2D) -> void:
	if area.is_in_group("Zombie"):
		area.slow()

func _on_slow_field_body_entered(body: Node2D) -> void:
	if body.is_in_group("Zombie"):
		body.slow()


# --- Eat Zombie (Maw Buff) ---

func eat_zombie(zombie_to_eat):
	animSpriteComp.speed_scale = 4
	resetEatingTimer.start()
	can_eat_zombie = false

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


# --- Preview ---

func _on_mouse_entered() -> void:
	$PreviewNodes/AnimatedSprite2D.visible = false
	$PreviewNodes.visible = true

func _on_mouse_exited() -> void:
	$PreviewNodes.visible = false


# --- Position Adjustment ---

func adjust_position(new_form):
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
		var character = input_string[i]
		if character.is_valid_int():
			return input_string.substr(0, i)
	return input_string


# --- Demo ---

func demo_blood_pickup():
	is_demo = true
	if isBuffed && mawBuff == false:
		is_demo_blood_spawn = true
		bloodTimer.wait_time = demo_fast_wait_time
		bloodTimer.start()
