extends Demon
#Maw.gd

const BLOOD_SCENE := preload("res://_Entities/Demons/Blood/Blood.tscn")
const WEB_BALL_SCENE := preload("res://_Entities/Demons/Projectile/WebBall.tscn")
const DIGEST_SWORD_SCENE := preload("res://_Entities/Demons/_Maw/digest_sword_attack.tscn")
const INSTAKILL_DAMAGE := 9999
const DEFAULT_CHARGE_COST := 1   # Fallback when an enemy lacks get_charge_cost()

# === Node references ===
@onready var tentacle1: Tentacle = $Tentacle1
@onready var tentacle2: Tentacle = $Tentacle2
@onready var tentacle3: Tentacle = $Tentacle3

@onready var detectionAreaShape = $DetectionComponent/CollisionShape2D
@onready var detection_area = $DetectionComponent
@onready var buffNodes = $BuffNodesComponent
@onready var ogDetectionRadius = detectionAreaShape.shape.radius

# === Exports ===
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

@onready var ogDigestTime = digestTime

# === Runtime state ===
var DemonManager                                  # DemonManager RefCounted
var tentacles: Array[Tentacle] = []               # All Tentacles owned by this Maw
var available_tentacles: Array[Tentacle] = []     # Currently free for assignment
var enemies_to_eat: Array = []                    # Detected zombies waiting for room
var eating_groups: Dictionary = {}
var consume_zombie_group_timer : Timer 

# Buff state
var willBelchWebs := false                        
var willBelchBlood := false
var will_spawn_swords := false
var bufferName: String
var consume_zombie_group
var devour_done := true 




func _ready():
	super()
	collision_mask = 2
	DemonManager = get_parent().get_parent().get_node("DemonManager")
	setup_tentacles()
	print_scene_tree()
	
	if self.is_in_group("Green"):
		detection_area.set_collision_mask_value(1,false)
		detection_area.set_collision_mask_value(2,false)
		detection_area.set_collision_mask_value(3,false)
		detection_area.set_collision_mask_value(4,false)
		detection_area.set_collision_mask_value(5,true)
	else:
		detection_area.set_collision_mask_value(1,false)
		detection_area.set_collision_mask_value(2,false)
		detection_area.set_collision_mask_value(3,false)
		detection_area.set_collision_mask_value(4,true)


		
		
# Demon cost getter
func get_cost():
	return cost


# Build the active tentacle list and wire up signals.
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


# Tentacles retract toward the Maw's animated sprite center, not the Maw root.
func _get_retraction_center() -> Vector2:
	return animSpriteComp.global_position


# Apply a digestion duration to every active tentacle. Used by setup and
# by the Wyrm buff (which lengthens digestion).
func _set_tentacle_digestion_time(t: float) -> void:
	for tentacle in tentacles:
		tentacle.digestion_time = t


# Fetch the charge cost from an enemy. Falls back (with a warning) if the
# enemy script doesn't expose `get_charge_cost()`.
func _get_charge_cost(enemy) -> int:
	if enemy.has_method("get_charge_cost"):
		return enemy.get_charge_cost()
	push_warning("[Maw] Enemy %s missing get_charge_cost(); falling back to %d" % [enemy.name, DEFAULT_CHARGE_COST])
	return DEFAULT_CHARGE_COST


# True if `target` is currently being eaten by any active group.
func _is_being_eaten(target) -> bool:
	for group in eating_groups.values():
		if group.enemy == target:
			return true
	return false


# Assign a target to the right number of tentacles based on its charge
# cost, or queue it if not enough tentacles are currently available.
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

	# Reserve `cost` tentacles up front and form a shared eating group.
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


# Drain the wait queue. Picks the first queued enemy whose cost fits the
# current available pool, assigns it, and repeats until no progress.
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


# === Tentacle signal handlers ===

func _on_tentacle_grabbed(_enemy: Node2D, _tentacle: Tentacle) -> void:
	AudioManager.create_2d_audio_at_location(global_position, SoundEffect.SOUND_EFFECT_TYPE.MAW_GRAB)
	if debug_mode:
		print("[Maw] Tentacle grabbed enemy")


func _on_tentacle_retraction_finished(enemy: Node2D, tentacle: Tentacle) -> void:
	print("TENT RETRACT FINDEDDDDDDDD")
	var group = eating_groups.get(tentacle)
	if group == null:
		# Tentacle was aborted out from under us; nothing to coordinate.
		return

	# Apply the once-per-eat effects the first time we see this group
	# complete a retraction. Subsequent tentacles just decrement the
	# pending counter.
	if not group.damage_applied:
		group.damage_applied = true
		if is_instance_valid(enemy):
			enemy.visible = false
			enemy.take_damage(INSTAKILL_DAMAGE)			

	group.pending_retract -= 1
	if group.pending_retract == 0:
		# All members have retracted — start digestion in sync.
		for t in group.tentacles:
			t.begin_digestion()
		if debug_mode:
			print("[Maw] Group of %d entered DIGESTING" % group.tentacles.size())


func _on_tentacle_ready_again(tentacle: Tentacle) -> void:
	if not tentacle in available_tentacles:
		available_tentacles.append(tentacle)

	var group = eating_groups.get(tentacle)
	if group == null:
		# Defensive: tentacle wasn't in a tracked group (orphaned somehow).
		_process_queue()
		return

	group.pending_ready_again -= 1
	if group.pending_ready_again == 0:
		# Whole group has finished digesting. Fire once-per-eat blood belch,
		# then erase every entry that still points to this group (some
		# tentacles may already have been reassigned within this frame,
		# so we only erase entries that still match).
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
	
func spawn_swords():
	var blood_sword_spell := DIGEST_SWORD_SCENE.instantiate()

	blood_sword_spell.global_position = self.global_position 
	blood_sword_spell.global_position = blood_sword_spell.global_position + Vector2(256,256)
	blood_sword_spell.global_position = blood_sword_spell.global_position + Vector2(32,0)
	if self.is_in_group("Green"):
		blood_sword_spell.add_to_group("Green")
	else:
		blood_sword_spell.add_to_group("Purple")
	
	get_parent().add_child(blood_sword_spell)
	blood_sword_spell.set_maw_parent()
	blood_sword_spell.setup_collision_and_damage_zombies()

func add_consume_zombie_group_component():
	consume_zombie_group = (Global.get_consume_zombie_group_scene()).instantiate()

	consume_zombie_group.global_position = self.global_position 
	consume_zombie_group.global_position = consume_zombie_group.global_position + Vector2(256,256)
	consume_zombie_group.global_position = consume_zombie_group.global_position + Vector2(144,0)
	if self.is_in_group("Green"):
		consume_zombie_group.add_to_group("Green")
	else:
		consume_zombie_group.add_to_group("Purple")
	demon_die.connect(consume_zombie_group.die)
	get_parent().add_child(consume_zombie_group)

	consume_zombie_group.set_all_areas()
	consume_zombie_group.done_eating.connect(devour_complete)
	print_scene_tree(consume_zombie_group)

	
	
func belch_webs():
	var web_ball = WEB_BALL_SCENE.instantiate()
	
	web_ball.global_position = self.global_position 
	web_ball.global_position = web_ball.global_position + Vector2(256,256)
	if self.is_in_group("Green"):
		web_ball.add_to_group("Green")
	else:
		web_ball.add_to_group("Purple")
	get_parent().add_child(web_ball)
	
	web_ball.target_position = web_ball.global_position + Vector2(128, 0)
	web_ball.travel_time = 2.0

# When one tentacle of a multi-tentacle group aborts, drag the whole
# group down with it: no charge was "earned", so all participants should
# ease back to idle as a unit.
func _on_tentacle_aborted(tentacle: Tentacle) -> void:
	if not tentacle in available_tentacles:
		available_tentacles.append(tentacle)

	var group = eating_groups.get(tentacle)
	if group != null and not group.aborted:
		group.aborted = true
		for sibling in group.tentacles:
			if sibling == tentacle:
				continue
			# Erase first so the sibling's incoming `aborted` signal
			# can't recursively cascade through this same group.
			if eating_groups.get(sibling) == group:
				eating_groups.erase(sibling)
				sibling.abort()
	# Always clear our own entry.
	eating_groups.erase(tentacle)

	if debug_mode:
		print("[Maw] Tentacle aborted")

	_process_queue()

func get_demon_name():
	return "MAW"
	
func get_damage():
	return "INSTAKILL"
	



func receive_buff(demon):
	
	var demonName = truncate_string(demon.name)
	if !isBuffed:
		super(demonName)

		match demonName:
			"Occulum":
				willBelchBlood = true

			"Crawler":
				willBelchWebs = true

			"SpinalOcculum" :
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

func devour_zombies():
	print("Devour Zombies Func Called, devour_done is ", devour_done)
	if devour_done:
		print("Should Devour ")
		devour_done = false
		consume_zombie_group.get_highest_zombie_concentration_and_eat()
	else:
		print("Cannot Devour")
	
func devour_complete():
	print("Should Set Devour Done to True")
	devour_done = true 
	

func debuff():
	pass




# Blood generation (occulum buff payout)
func generate_blood():
	var blood_instance = BLOOD_SCENE.instantiate()
	get_parent().add_child(blood_instance)
	blood_instance.setWorth(bloodAmount)
	#demon_instance.position = Vector2(demon_instance.position.x-256,demon_instance.position.y-256)
	blood_instance.global_position = self.global_position 
	blood_instance.global_position = blood_instance.global_position + Vector2(256,256)
	blood_instance.global_position = blood_instance.global_position + Vector2(0,-16)


func _on_detection_component_area_entered(area: Area2D) -> void:
	if not area.is_in_group("Zombie"):
		return
	# Dimension check
	if area.is_in_group("Green") and self.is_in_group("Purple"):
		return
	if area.is_in_group("Purple") and self.is_in_group("Green"):
		return
	if "Boss" in area.get_name():
		return
	assign_tentacle_to_target(area)


func die():
	super()
	if tentacle1: tentacle1.queue_free()
	if tentacle2: tentacle2.queue_free()
	if tentacle3: tentacle3.queue_free()

	DemonManager.clear_space(Vector2(self.global_position.x - 16, self.global_position.y))
	DemonManager.clear_space(Vector2(self.global_position.x + 16, self.global_position.y))
	buffNodes.clearBuffs()
	queue_free()

func die_fromClearSpace():
	super()
	if buffNodes != null:
		buffNodes.clearBuffs()
	queue_free()				
		



func show_tentacles():
	tentacle1.visible = true
	tentacle2.visible = true
	tentacle3.visible = true


func _on_mouse_entered() -> void:
	$PreviewNodes/AnimatedSprite2.visible = false
	$PreviewNodes.visible = true


func _on_mouse_exited() -> void:
	$PreviewNodes.visible = false


func finish_spawn():
	super()
	show_tentacles()
