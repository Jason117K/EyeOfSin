extends Demon
#Maw.gd

# --- Preloads ---
const BLOOD_SCENE := preload("res://_Entities/Demons/Blood/Blood.tscn")
const WEB_BALL_SCENE := preload("res://_Entities/Demons/Projectile/WebBall.tscn")
const DIGEST_SWORD_SCENE := preload("res://_Entities/Demons/_Maw/digest_sword_attack.tscn")

# --- Constants ---
const INSTAKILL_DAMAGE := 9999
const DEFAULT_CHARGE_COST := 1

# --- Exports ---
@export var alt_target_color: Color
@export var alt_replace_color: Color
@export var debug_mode: bool = false
@export var bloodAmount = 10
@export var digestTime: float = 15.0
@export var wyrm_buffed_digestion_time : float = 5.0
@export var spinal_occulum_buffed_digestion_time : float = 9.0
@export var spinal_occulum_heal_amount := 300
@export var consume_zombie_group_wait_time := 5.0
@export var spinalOcculumHealth = 1500
@export var spinal_occulum_max_health = 1500
@export var web_belch_distance := Vector2(128, 0)

# --- Component References ---
@onready var tentacle1: Tentacle = $Tentacle1
@onready var tentacle2: Tentacle = $Tentacle2
@onready var tentacle3: Tentacle = $Tentacle3
@onready var detectionAreaShape = $DetectionComponent/CollisionShape2D
@onready var detection_area = $DetectionComponent
@onready var ogDetectionRadius = detectionAreaShape.shape.radius
@onready var ogDigestTime = digestTime

# --- State ---
var tentacles: Array[Tentacle] = []
var available_tentacles: Array[Tentacle] = []
var enemies_to_eat: Array = []
var eating_groups: Dictionary = {}
var consume_zombie_group_timer : Timer

# Buff state
var willBelchWebs := false
var willBelchBlood := false
var will_spawn_swords := false
var bufferName: String
var consume_zombie_group
var devour_done := true
var is_demo := false


# --- Lifecycle ---

func _ready():
	super()
	collision_mask = 2
	# --- Tentacle setup ---
	setup_tentacles()
	# --- Demon-specific collision ---
	_init_demon_collision()

func _init_demon_collision():
	if self.is_in_group("Green"):
		detection_area.set_collision_mask_value(1, false)
		detection_area.set_collision_mask_value(2, false)
		detection_area.set_collision_mask_value(3, false)
		detection_area.set_collision_mask_value(4, false)
		detection_area.set_collision_mask_value(5, true)
	else:
		detection_area.set_collision_mask_value(1, false)
		detection_area.set_collision_mask_value(2, false)
		detection_area.set_collision_mask_value(3, false)
		detection_area.set_collision_mask_value(4, true)


# --- Getters ---

func get_cost():
	return cost

func get_demon_name():
	return "MAW"

func get_demon_true_name():
	return "Maw"

func get_damage():
	return "INSTAKILL"


# --- Buff System ---

func receive_buff(demon):
	var demonName = (demon.get_demon_true_name())
	if !isBuffed:
		super(demonName)
		match demonName:
			"Occulum":
				willBelchBlood = true
			"Crawler":
				willBelchWebs = true
			"SpinalOcculum":
				_set_tentacle_digestion_time(spinal_occulum_buffed_digestion_time)
			"Wyrm":
				_set_tentacle_digestion_time(wyrm_buffed_digestion_time)
				will_spawn_swords = true
			"Hive":
				detectionAreaShape.shape.radius *= 1.2
				consume_zombie_group_timer = Timer.new()
				consume_zombie_group_timer.autostart = false
				consume_zombie_group_timer.one_shot = false
				consume_zombie_group_timer.wait_time = consume_zombie_group_wait_time
				consume_zombie_group_timer.timeout.connect(devour_zombies)
				add_consume_zombie_group_component()
				add_child(consume_zombie_group_timer)
				consume_zombie_group_timer.start()
			"Maw":
				pass

func debuff():
	super()


# --- Death ---

func _cleanup_manager():
	# Maw occupies two grid spaces
	if DemonManager != null:
		DemonManager.clear_space(Vector2(self.global_position.x - 16, self.global_position.y))
		DemonManager.clear_space(Vector2(self.global_position.x + 16, self.global_position.y))

func _cleanup():
	# Free tentacles before base cleanup
	if tentacle1: tentacle1.queue_free()
	if tentacle2: tentacle2.queue_free()
	if tentacle3: tentacle3.queue_free()
	super()


# --- Tentacle System ---

func setup_tentacles():
	tentacles = [tentacle1, tentacle2, tentacle3]
	available_tentacles = tentacles.duplicate()

	for tentacle in tentacles:
		tentacle.retraction_center_provider = _get_retraction_center
		tentacle.grabbed_enemy.connect(_on_tentacle_grabbed.bind(tentacle))
		tentacle.retraction_finished.connect(_on_tentacle_retraction_finished.bind(tentacle))
		tentacle.ready_again.connect(_on_tentacle_ready_again.bind(tentacle))
		tentacle.aborted.connect(_on_tentacle_aborted.bind(tentacle))

	_set_tentacle_digestion_time(digestTime)

	if debug_mode:
		print("[Maw] Setup complete: %d tentacles ready" % tentacles.size())

func get_tentacles():
	return available_tentacles

func _get_retraction_center() -> Vector2:
	return animSpriteComp.global_position

func _set_tentacle_digestion_time(t: float) -> void:
	for tentacle in tentacles:
		tentacle.digestion_time = t

func _get_charge_cost(enemy) -> int:
	if enemy.has_method("get_charge_cost"):
		return enemy.get_charge_cost()
	push_warning("[Maw] Enemy %s missing get_charge_cost(); falling back to %d" % [enemy.name, DEFAULT_CHARGE_COST])
	return DEFAULT_CHARGE_COST

func _is_being_eaten(target) -> bool:
	for group in eating_groups.values():
		if group.enemy == target:
			return true
	return false

func assign_tentacle_to_target(target):
	if _is_being_eaten(target):
		if debug_mode:
			print("[Maw] Target already being eaten, skipping")
		return

	var cost: int = _get_charge_cost(target)
	if cost > tentacles.size():
		push_warning("[Maw] Enemy %s charge_cost (%d) exceeds tentacle count (%d) — will never be eaten" % [target.name, cost, tentacles.size()])
		return

	if available_tentacles.size() < cost:
		if not target in enemies_to_eat:
			if debug_mode:
				print("[Maw] Not enough tentacles for cost-%d %s; queueing" % [cost, target.name])
			enemies_to_eat.append(target)
		return

	var group_tentacles: Array[Tentacle] = []
	for i in range(cost):
		group_tentacles.append(available_tentacles.pop_front())
	var primary: Tentacle = group_tentacles[0]

	var group: Dictionary = {
		"enemy": target,
		"tentacles": group_tentacles,
		"primary": primary,
		"pending_retract": cost,
		"pending_ready_again": cost,
		"damage_applied": false,
		"aborted": false,
	}

	for t in group_tentacles:
		eating_groups[t] = group
		t.attack(target, t == primary)

	if debug_mode:
		print("[Maw] Assigned %d tentacles to cost-%d %s — Available: %d" % [cost, cost, target.name, available_tentacles.size()])

func _process_queue():
	var made_progress := true
	while made_progress and not enemies_to_eat.is_empty():
		made_progress = false
		for i in range(enemies_to_eat.size()):
			var enemy = enemies_to_eat[i]
			if not is_instance_valid(enemy):
				enemies_to_eat.remove_at(i)
				made_progress = true
				break
			var cost = _get_charge_cost(enemy)
			if available_tentacles.size() >= cost:
				enemies_to_eat.remove_at(i)
				if debug_mode:
					print("[Maw] Dequeueing %s (cost %d)" % [enemy.name, cost])
				assign_tentacle_to_target(enemy)
				made_progress = true
				break


# --- Tentacle Signal Handlers ---

func _on_tentacle_grabbed(_enemy: Node2D, _tentacle: Tentacle) -> void:
	AudioManager.create_2d_audio_at_location(global_position, SoundEffect.SOUND_EFFECT_TYPE.MAW_GRAB)
	if debug_mode:
		print("[Maw] Tentacle grabbed enemy")

func _on_tentacle_retraction_finished(enemy: Node2D, tentacle: Tentacle) -> void:
	var group = eating_groups.get(tentacle)
	if group == null:
		return

	if not group.damage_applied:
		group.damage_applied = true
		if is_instance_valid(enemy):
			enemy.visible = false
			enemy.take_damage(INSTAKILL_DAMAGE)

	group.pending_retract -= 1
	if group.pending_retract == 0:
		for t in group.tentacles:
			t.begin_digestion()
		if debug_mode:
			print("[Maw] Group of %d entered DIGESTING" % group.tentacles.size())

func _on_tentacle_ready_again(tentacle: Tentacle) -> void:
	if not tentacle in available_tentacles:
		available_tentacles.append(tentacle)

	var group = eating_groups.get(tentacle)
	if group == null:
		_process_queue()
		return

	group.pending_ready_again -= 1
	if group.pending_ready_again == 0:
		if willBelchBlood:
			generate_blood()
		if willBelchWebs:
			belch_webs()
		if will_spawn_swords:
			spawn_swords()

		if spinalOcculumBuff:
			healthComp.increase_health(spinal_occulum_heal_amount)

		for t in group.tentacles:
			if eating_groups.get(t) == group:
				eating_groups.erase(t)
		if debug_mode:
			print("[Maw] Group complete — Available: %d" % available_tentacles.size())
	_process_queue()

func _on_tentacle_aborted(tentacle: Tentacle) -> void:
	if not tentacle in available_tentacles:
		available_tentacles.append(tentacle)

	var group = eating_groups.get(tentacle)
	if group != null and not group.aborted:
		group.aborted = true
		for sibling in group.tentacles:
			if sibling == tentacle:
				continue
			if eating_groups.get(sibling) == group:
				eating_groups.erase(sibling)
				sibling.abort()
	eating_groups.erase(tentacle)

	if debug_mode:
		print("[Maw] Tentacle aborted")

	_process_queue()


# --- Digest Effects ---

func spawn_swords():
	var blood_sword_spell := DIGEST_SWORD_SCENE.instantiate()
	if is_demo:
		get_parent().add_child(blood_sword_spell)
		blood_sword_spell.global_position = animSpriteComp.global_position + Vector2(32, 0)
		if self.is_in_group("Green"):
			blood_sword_spell.add_to_group("Green")
		else:
			blood_sword_spell.add_to_group("Purple")
		blood_sword_spell.set_maw_parent()
		blood_sword_spell.setup_collision_and_damage_zombies()
	else:
		blood_sword_spell.global_position = self.global_position
		blood_sword_spell.global_position = blood_sword_spell.global_position + Vector2(256, 256)
		blood_sword_spell.global_position = blood_sword_spell.global_position + Vector2(32, 0)
		if self.is_in_group("Green"):
			blood_sword_spell.add_to_group("Green")
		else:
			blood_sword_spell.add_to_group("Purple")
		get_parent().add_child(blood_sword_spell)
		blood_sword_spell.set_maw_parent()
		blood_sword_spell.setup_collision_and_damage_zombies()

func generate_blood():
	var blood_instance = BLOOD_SCENE.instantiate()
	get_parent().add_child(blood_instance)
	blood_instance.setWorth(bloodAmount)
	blood_instance.global_position = animSpriteComp.global_position
	blood_instance.global_position = blood_instance.global_position + Vector2(0, -16)

func belch_webs():
	var web_ball = WEB_BALL_SCENE.instantiate()
	if is_demo:
		get_parent().add_child(web_ball)
		web_ball.global_position = animSpriteComp.global_position + Vector2(256, 256)
		if self.is_in_group("Green"):
			web_ball.add_to_group("Green")
		else:
			web_ball.add_to_group("Purple")
		web_ball.target_position = web_ball.start_position + Vector2(96, 0)
		web_ball.travel_time = 2.0
	else:
		web_ball.global_position = self.global_position + Vector2(256, 256)
		if self.is_in_group("Green"):
			web_ball.add_to_group("Green")
		else:
			web_ball.add_to_group("Purple")
		get_parent().add_child(web_ball)
		web_ball.target_position = web_ball.global_position + web_belch_distance
		web_ball.travel_time = 2.0


# --- Consume Zombie Group (Hive Buff) ---

func add_consume_zombie_group_component():
	consume_zombie_group = (Global.get_consume_zombie_group_scene()).instantiate()

	if is_demo:
		get_parent().add_child(consume_zombie_group)
		consume_zombie_group.global_position = animSpriteComp.global_position + Vector2(96, 0)
		if self.is_in_group("Green"):
			consume_zombie_group.add_to_group("Green")
		else:
			consume_zombie_group.add_to_group("Purple")
		consume_zombie_group.set_all_areas()
		consume_zombie_group.done_eating.connect(devour_complete)
	else:
		consume_zombie_group.global_position = self.global_position
		consume_zombie_group.global_position = consume_zombie_group.global_position + Vector2(256, 256)
		consume_zombie_group.global_position = consume_zombie_group.global_position + Vector2(144, 0)
		if self.is_in_group("Green"):
			consume_zombie_group.add_to_group("Green")
		else:
			consume_zombie_group.add_to_group("Purple")
		demon_die.connect(consume_zombie_group.die)
		get_parent().add_child(consume_zombie_group)
		consume_zombie_group.set_all_areas()
		consume_zombie_group.done_eating.connect(devour_complete)
		print_scene_tree(consume_zombie_group)

func devour_zombies():
	if devour_done:
		devour_done = false
		consume_zombie_group.get_highest_zombie_concentration_and_eat()

func devour_complete():
	devour_done = true


# --- Detection ---

func _on_detection_component_area_entered(area: Area2D) -> void:
	if not area.is_in_group("Zombie"):
		return
	if area.is_in_group("Green") and self.is_in_group("Purple"):
		return
	if area.is_in_group("Purple") and self.is_in_group("Green"):
		return
	if "Boss" in area.get_name():
		return
	assign_tentacle_to_target(area)


# --- Demo ---

func set_demo_digest():
	digestTime = 3.0
	_set_tentacle_digestion_time(digestTime)
	is_demo = true
	consume_zombie_group_wait_time = 4.0


# --- Spawn ---

func finish_spawn():
	super()
	show_tentacles()

func show_tentacles():
	tentacle1.visible = true
	tentacle2.visible = true
	tentacle3.visible = true

func get_out_of_place_nodes():
	return [$DetectionComponent, $CollisionShape2D, $PreviewNodes]


# --- Preview ---

func _on_mouse_entered() -> void:
	$PreviewNodes/AnimatedSprite2.visible = false
	$PreviewNodes.visible = true

func _on_mouse_exited() -> void:
	$PreviewNodes.visible = false
