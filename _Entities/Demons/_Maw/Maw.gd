extends Demon
#Maw.gd

# --- Preloads ---
const BLOOD_SCENE := preload("res://_Entities/Demons/Blood/Blood.tscn")
const WEB_BALL_SCENE := preload("res://_Entities/Demons/Projectile/WebBall.tscn")
const DIGEST_SWORD_SCENE := preload("res://_Entities/Demons/_Maw/digest_sword_attack.tscn")
const TENTACLE_SCENE := preload("res://_Entities/Demons/Tentacles/Tentacle.tscn")

# --- Constants ---
const INSTAKILL_DAMAGE := 9999
const DEFAULT_CHARGE_COST := 1

# --- Exports ---
@export var alt_target_color: Color
@export var alt_replace_color: Color
@export var debug_mode: bool = false
@export var bloodAmount: int = 10
@export var digestTime: float = 15.0
# Gaze of Baal digestion-time multiplier (0.5 = twice as fast).
@export var baal_digestion_multiplier := 0.5
# Digestion time the synergies last asked for; Baal scales it on top.
var _base_digestion_time := -1.0
@export var wyrm_buffed_digestion_time : float = 5.0
@export var spinal_occulum_buffed_digestion_time : float = 9.0
@export var spinal_occulum_heal_amount := 300
@export var consume_zombie_group_wait_time := 5.0
@export var spinalOcculumHealth: float = 1500
@export var spinal_occulum_max_health: float = 1500
@export var web_belch_distance := Vector2(128, 0)

# --- Component References ---
@onready var tentacle1: Tentacle = $Tentacle1
@onready var tentacle2: Tentacle = $Tentacle2
@onready var tentacle3: Tentacle = $Tentacle3
# Rest point of the 4th tentacle the ultimate adds.
@onready var ultimate_arm_target_location: Node2D = $UltimateArmTargetLocation
@onready var detectionAreaShape: CollisionShape2D = $DetectionComponent/CollisionShape2D
@onready var detection_area: Area2D = $DetectionComponent
@onready var ogDetectionRadius: float = detectionAreaShape.shape.radius
@onready var ogDigestTime: float = digestTime

# --- State ---
var tentacles: Array[Tentacle] = []
var available_tentacles: Array[Tentacle] = []
var enemies_to_eat: Array = []
var eating_groups: Dictionary = {}
var consume_zombie_group_timer: Timer
var tentacle4: Tentacle

# Buff state
var willBelchWebs := false
var willBelchBlood := false
var will_spawn_swords := false
var bufferName: String
var consume_zombie_group : Node
var devour_done := true
var is_demo := false

signal maw_buff_unlocked(buff_to_unlock:String)
# --- Lifecycle ---

func _ready() -> void:
	super()
	current_demon_type = Global.DEMON_TYPE.MAW
	_init_collision_mask(self, false)
	#print("Og Detection Radius is ", ogDetectionRadius)
	maw_buff_unlocked.connect(Global.unlock_buff)
	# --- Tentacle setup ---
	setup_tentacles()
	# --- Demon-specific collision ---
	_init_demon_collision()
	detection_area.area_exited.connect(_on_detection_component_area_exited)
	##print("Tentacle Is Active Num ", GlobalTentacleManager.get_active_arm_count())
	
	all_synergies = Global.all_maw_synergies
	special_description_file = get_special_description_file(all_synergies,"Base")

func _init_demon_collision() -> void:
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

func get_cost() -> float:
	return cost

func get_demon_name() -> String:
	return "MAW"

func get_demon_true_name() -> String:
	return "Maw"

func get_damage() -> String:
	return "INSTAKILL"

# The root sits at place_demon's -256 visual offset (+16 to center on two
# cells); undo it to get the left grid cell that grid_map, revive points and
# blood clones key on.
func get_cell_global_position() -> Vector2:
	return global_position + Vector2(256 - 16, 256)


# --- Buff System ---
func baal_buff()->void:
	super()
	baal_halo.play("back")

func _apply_baal_buff()->void:
	_set_tentacle_digestion_time(_base_digestion_time if _base_digestion_time > 0.0 else digestTime)

func _undo_baal_buff()->void:
	_set_tentacle_digestion_time(_base_digestion_time if _base_digestion_time > 0.0 else digestTime)
	
	
func receive_buff(demon) -> void:
	var demonName: String = (demon.get_demon_true_name())
	if !isBuffed:
		unlock_new_buff(demonName)
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

func debuff() -> void:
	super()
	if is_blood:
		return
	# Base debuff() only resets the shared flags; undo the Maw-only buff effects
	# too, or they outlive the buffing demon and stack on the next buff.
	willBelchBlood = false
	willBelchWebs = false
	will_spawn_swords = false
	_set_tentacle_digestion_time(digestTime)
	detectionAreaShape.shape.radius = ogDetectionRadius
	_remove_consume_zombie_group()


func unlock_new_buff(demonName:String)->void:
	if isBuffed == false:
		if Global.game_controller.current_scenes.size()>1:
			if demonName != get_demon_true_name():
				maw_buff_unlocked.emit(SynergyDefinition.make_id(demonName, get_demon_true_name()))
					
					
					
					
func shield(syn_shield:PackedScene,duration:float)->void:
	super(syn_shield,duration)
	new_syn_shield_instance.scale = Vector2(3.25,3.25)


# --- Death ---

func _cleanup_manager() -> void:
	# Maw occupies two grid spaces, keyed from the cell it was placed on
	if demon_manager != null:
		demon_manager.clear_space(grid_map_cell_pos)
		demon_manager.clear_space(grid_map_cell_pos + Vector2(32, 0))

func _cleanup() -> void:
	# Free tentacles before base cleanup
	if tentacle1: tentacle1.queue_free()
	if tentacle2: tentacle2.queue_free()
	if tentacle3: tentacle3.queue_free()
	if is_instance_valid(tentacle4): tentacle4.queue_free()
	super()


# --- Tentacle System ---

func setup_tentacles() -> void:
	tentacles = [tentacle1, tentacle2, tentacle3]
	available_tentacles = tentacles.duplicate()

	for tentacle in tentacles:
		_wire_tentacle(tentacle)

	_set_tentacle_digestion_time(digestTime)

	if debug_mode:
		pass
		#print("[Maw] Setup complete: %d tentacles ready" % tentacles.size())

func _wire_tentacle(tentacle: Tentacle) -> void:
	tentacle.retraction_center_provider = _get_retraction_center
	tentacle.grabbed_enemy.connect(_on_tentacle_grabbed.bind(tentacle))
	tentacle.retraction_finished.connect(_on_tentacle_retraction_finished.bind(tentacle))
	tentacle.ready_again.connect(_on_tentacle_ready_again.bind(tentacle))
	tentacle.aborted.connect(_on_tentacle_aborted.bind(tentacle))

func get_tentacles() -> Array[Tentacle]:
	return available_tentacles

func _get_retraction_center() -> Vector2:
	return animSpriteComp.global_position

# Every digestion change goes through here, so Baal combines with the Wyrm and
# Spinal digestion buffs (and debuff's restore) in any order. Tentacles read
# digestion_time live, so a digestion already under way speeds up too.
func _set_tentacle_digestion_time(t: float) -> void:
	_base_digestion_time = t
	var effective := t * (baal_digestion_multiplier if is_baal_buffed else 1.0)
	for tentacle in tentacles:
		tentacle.digestion_time = effective

func _get_charge_cost(enemy:Node) -> int:
	if enemy.has_method("get_charge_cost"):
		return enemy.get_charge_cost()
	push_warning("[Maw] Enemy %s missing get_charge_cost(); falling back to %d" % [enemy.name, DEFAULT_CHARGE_COST])
	return DEFAULT_CHARGE_COST

func _is_being_eaten(target:Node) -> bool:
	for group:Dictionary in eating_groups.values():
		if group.enemy == target:
			return true
	return false

# A zombie killed by something else stays valid through its death animation,
# and one being dragged under by the Hive-buff devour is already taken.
func _is_edible(target:Node) -> bool:
	if not is_instance_valid(target) or target.get("is_dead") == true:
		return false
	if consume_zombie_group != null and is_instance_valid(consume_zombie_group) \
			and consume_zombie_group.is_devouring(target):
		return false
	return true

func assign_tentacle_to_target(target:Node) -> void:
	if not _is_edible(target):
		return
	if _is_being_eaten(target):
		if debug_mode:
			pass
			#print("[Maw] Target already being eaten, skipping")
		return

	# Local, not the inherited `cost` (the Maw's blood cost, used for refunds).
	var charge_cost := _get_charge_cost(target)
	if charge_cost > tentacles.size():
		push_warning("[Maw] Enemy %s charge_cost (%d) exceeds tentacle count (%d) — will never be eaten" % [target.name, charge_cost, tentacles.size()])
		return

	if available_tentacles.size() < charge_cost:
		if not target in enemies_to_eat:
			if debug_mode:
				pass

				#print("[Maw] Not enough tentacles for cost-%d %s; queueing" % [charge_cost, target.name])
			enemies_to_eat.append(target)
		return

	var group_tentacles: Array[Tentacle] = []
	for i in range(charge_cost):
		group_tentacles.append(available_tentacles.pop_front())
	var primary: Tentacle = group_tentacles[0]

	var group: Dictionary = {
		"enemy": target,
		"tentacles": group_tentacles,
		"primary": primary,
		"pending_retract": charge_cost,
		"pending_ready_again": charge_cost,
		"damage_applied": false,
		"aborted": false,
	}

	for t in group_tentacles:
		eating_groups[t] = group
		t.attack(target, t == primary)

	if debug_mode:
		pass
		#print("[Maw] Assigned %d tentacles to cost-%d %s — Available: %d" % [cost, cost, target.name, available_tentacles.size()])

func _process_queue() -> void:
	var made_progress := true
	while made_progress and not enemies_to_eat.is_empty():
		made_progress = false
		for i in range(enemies_to_eat.size()):
			var enemy = enemies_to_eat[i]
			if not _is_edible(enemy):
				enemies_to_eat.remove_at(i)
				made_progress = true
				break
			var enemy_cost :float= _get_charge_cost(enemy)
			if available_tentacles.size() >= enemy_cost:
				enemies_to_eat.remove_at(i)
				if debug_mode:
					pass
					#print("[Maw] Dequeueing %s (enemy_cost %d)" % [enemy.name, enemy_cost])
				assign_tentacle_to_target(enemy)
				made_progress = true
				break


# --- Tentacle Signal Handlers ---

func _on_tentacle_grabbed(_enemy: Node2D, _tentacle: Tentacle) -> void:
	AudioManager.create_2d_audio_at_location(global_position, SoundEffect.SOUND_EFFECT_TYPE.MAW_GRAB)
	if debug_mode:
		pass
		#print("[Maw] Tentacle grabbed enemy")

func _on_tentacle_retraction_finished(enemy: Node2D, tentacle: Tentacle) -> void:
	var group:Dictionary = eating_groups.get(tentacle)
	if group == null:
		return

	if not group.damage_applied:
		# Killed or devoured by something else mid-grab: nothing to eat, so
		# don't spend a digestion (or pay out its death a second time).
		if not _is_edible(enemy):
			tentacle.abort()
			return
		group.damage_applied = true
		enemy.visible = false
		enemy.take_damage(false,INSTAKILL_DAMAGE,false)

	group.pending_retract -= 1
	if group.pending_retract == 0:
		for t:Node in group.tentacles:
			t.begin_digestion()
		if debug_mode:
			pass
			#print("[Maw] Group of %d entered DIGESTING" % group.tentacles.size())

func _on_tentacle_ready_again(tentacle: Tentacle) -> void:
	if not tentacle in available_tentacles:
		available_tentacles.append(tentacle)

	var group:Dictionary = eating_groups.get(tentacle)
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

		for t:Node in group.tentacles:
			if eating_groups.get(t) == group:
				eating_groups.erase(t)
		if debug_mode:
			pass
			#print("[Maw] Group complete — Available: %d" % available_tentacles.size())
	_process_queue()

func _on_tentacle_aborted(tentacle: Tentacle) -> void:
	if not tentacle in available_tentacles:
		available_tentacles.append(tentacle)

	var group:Dictionary = eating_groups.get(tentacle)
	if group != null and not group.aborted:
		group.aborted = true
		for sibling:Node in group.tentacles:
			if sibling == tentacle:
				continue
			if eating_groups.get(sibling) == group:
				eating_groups.erase(sibling)
				sibling.abort()
	eating_groups.erase(tentacle)

	if debug_mode:
		pass
		#print("[Maw] Tentacle aborted")

	_process_queue()


# --- Digest Effects ---

func spawn_swords() -> void:
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

func generate_blood() -> void:
	var blood_instance: Node = BLOOD_SCENE.instantiate()
	get_parent().add_child(blood_instance)
	blood_instance.setWorth(bloodAmount)
	blood_instance.global_position = animSpriteComp.global_position
	blood_instance.global_position = blood_instance.global_position + Vector2(0, -16)

func belch_webs() -> void:
	var web_ball: Node = WEB_BALL_SCENE.instantiate()
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

func add_consume_zombie_group_component() -> void:
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
		#print_scene_tree(consume_zombie_group)

func _remove_consume_zombie_group() -> void:
	if consume_zombie_group_timer != null:
		consume_zombie_group_timer.queue_free()
		consume_zombie_group_timer = null
	if consume_zombie_group != null and is_instance_valid(consume_zombie_group):
		if demon_die.is_connected(consume_zombie_group.die):
			demon_die.disconnect(consume_zombie_group.die)
		consume_zombie_group.die()
	consume_zombie_group = null
	devour_done = true

func devour_zombies() -> void:
	if devour_done:
		devour_done = false
		consume_zombie_group.get_highest_zombie_concentration_and_eat(_is_being_eaten)

func devour_complete() -> void:
	devour_done = true


# --- Detection ---

func _on_detection_component_area_entered(this_area: Area2D) -> void:
	if not this_area.is_in_group("Zombie"):
		return
	if this_area.is_in_group("Green") and self.is_in_group("Purple"):
		return
	if this_area.is_in_group("Purple") and self.is_in_group("Green"):
		return
	if "Boss" in this_area.get_name():
		return
	assign_tentacle_to_target(this_area)

func _on_detection_component_area_exited(this_area: Area2D) -> void:
	# A queued zombie that walks out of range is no longer a target.
	enemies_to_eat.erase(this_area)


# --- Demo ---

func set_demo_digest() -> void:
	digestTime = 3.0
	_set_tentacle_digestion_time(digestTime)
	is_demo = true
	consume_zombie_group_wait_time = 4.0


# --- Spawn ---

func finish_spawn() -> void:
	super()
	show_tentacles()

func show_tentacles() -> void:
	tentacle1.visible = true
	tentacle2.visible = true
	tentacle3.visible = true

func get_out_of_place_nodes() -> Array:
	return [$DetectionComponent, $CollisionShape2D, $PreviewNodes]


	

# --- Preview ---


func _on_mouse_exited() -> void:
	$PreviewNodes.visible = false


# --- Ultimate ---

# Once per Maw: an already-ulted Maw takes a normal click and the armed charge
# isn't spent.
func _on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if Global.ultimate_is_ready and can_ult and spawn_done:
		if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			trigger_ultimate()
	else:
		super(_viewport, event, _shape_idx)

func trigger_ultimate() -> void:
	can_ult = false
	Global.un_ready_ultimate()
	_add_ultimate_tentacle()

# Spawned on demand so un-ulted Maws don't pay for a 4th tentacle. The tentacle
# rests at (and returns to) global_position + idle_offset, so idle_offset is what
# puts its ArmTarget on UltimateArmTargetLocation.
func _add_ultimate_tentacle() -> void:
	tentacle4 = TENTACLE_SCENE.instantiate()
	tentacle4.name = "Tentacle4"
	tentacle4.position = tentacle1.position
	tentacle4.idle_offset = ultimate_arm_target_location.position - tentacle1.position
	tentacle3.add_sibling(tentacle4)
	_wire_tentacle(tentacle4)
	tentacles.append(tentacle4)
	available_tentacles.append(tentacle4)
	_set_tentacle_digestion_time(_base_digestion_time if _base_digestion_time > 0.0 else digestTime)
	# Grab zombies already in range: queued ones, and any whose cost was above
	# the old tentacle count (those were never queued).
	for this_area in detection_area.get_overlapping_areas():
		_on_detection_component_area_entered(this_area)
	_process_queue()
