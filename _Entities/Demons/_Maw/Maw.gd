extends Demon
#Maw.gd

const BLOOD_SCENE := preload("res://_Entities/Demons/Blood/Sun.tscn")
const WEB_BALL_SCENE := preload("res://_Entities/Demons/Projectile/WebBall.tscn")
const INSTAKILL_DAMAGE := 9999
const WALNUT_HEAL_AMOUNT := 100
const DEFAULT_CHARGE_COST := 1   # Fallback when an enemy lacks get_charge_cost()

# Buff dispatch table. Iterated in order in receiveBuff/debuff — the first
# `key` found inside `bufferName` wins. Walnut's remove is a deliberate
# no-op (buff is permanent).
const _BUFF_HANDLERS := [
	{"key": "EggWorm",    "apply": "_apply_eggworm_buff",    "remove": "_remove_eggworm_buff"},
	{"key": "Peashooter", "apply": "_apply_peashooter_buff", "remove": "_remove_peashooter_buff"},
	{"key": "Hive",       "apply": "_apply_hive_buff",       "remove": "_remove_hive_buff"},
	{"key": "Sunflower",  "apply": "_apply_sunflower_buff",  "remove": "_remove_sunflower_buff"},
	{"key": "Walnut",     "apply": "_apply_walnut_buff",     "remove": "_remove_walnut_buff"},
]

# === Node references ===
@onready var tentacle1: Tentacle = $Tentacle1
@onready var tentacle2: Tentacle = $Tentacle2
@onready var tentacle3: Tentacle = $Tentacle3

@onready var detectionAreaShape = $DetectionComponent/CollisionShape2D
@onready var detection_area = $DetectionComponent
@onready var buffNodes = $BuffNodesComponent
@onready var ogDetectionRadius = detectionAreaShape.shape.radius

# === Exports ===
@export var cost = 200                       # Plant cost (sun cost to place)
@export var alt_target_color: Color
@export var alt_replace_color: Color
@export var debug_mode: bool = false
@export var bloodAmount = 10
@export var digestTime: float
@export var buffedDigestTime: float

@onready var ogDigestTime = digestTime

# === Runtime state ===
var PlantManager                                  # PlantManager RefCounted
var tentacles: Array[Tentacle] = []               # All Tentacles owned by this Maw
var available_tentacles: Array[Tentacle] = []     # Currently free for assignment
var enemies_to_eat: Array = []                    # Detected zombies waiting for room

# Multi-tentacle eat coordination. Each entry maps a tentacle to the
# *shared* group dictionary that represents one in-progress eat.
# Group dict shape:
# {
#   "enemy":               Node2D,
#   "tentacles":           Array[Tentacle],
#   "primary":             Tentacle,
#   "pending_retract":     int,   # decremented each retraction_finished
#   "pending_ready_again": int,   # decremented each ready_again
#   "damage_applied":      bool,  # gate for damage / walnut / web ball
#   "aborted":             bool,  # gate for cascade-abort
# }
var eating_groups: Dictionary = {}

# Buff state
var willBelchWebs := false                        # Peashooter buff
var willBelchSun := false
var isEggWyrmBuffed := false
var isSpyderBuffed := false
var isHiveBuffed := false
var isSunflowerBuffed := false
var isWalnutBuffed := false
var bufferName: String


func _ready():
	super()
	collision_mask = 2
	PlantManager = get_parent().get_parent().get_node("PlantManager")
	setup_tentacles()


# Plant cost getter
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
# by the EggWorm buff (which lengthens digestion).
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
			var enemyCompManager = enemy.getCompManager()
			enemyCompManager.take_damage(INSTAKILL_DAMAGE)

			if isWalnutBuffed:
				healthComp.health += WALNUT_HEAL_AMOUNT

			# Web belch (spyder buff + slowed enemy)
			var slow = enemyCompManager.getSlow()
			if slow > 0 and willBelchWebs:
				var web_ball = WEB_BALL_SCENE.instantiate()
				add_child(web_ball)
				web_ball.target_position = Vector2(100, 0)
				web_ball.travel_time = 1.5

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
		# Whole group has finished digesting. Fire once-per-eat sun belch,
		# then erase every entry that still points to this group (some
		# tentacles may already have been reassigned within this frame,
		# so we only erase entries that still match).
		if willBelchSun:
			generate_sun()
		for t in group.tentacles:
			if eating_groups.get(t) == group:
				eating_groups.erase(t)
		if debug_mode:
			print("[Maw] Group complete — Available: %d" % available_tentacles.size())

	_process_queue()


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

#region Rewrite LMAO

# Receive a buff from a neighbor plant. First buff wins —
# subsequent buffs are ignored by design.
func receiveBuff(plant):
	animSpriteComp.receiveBuff(plant)
	if isBuffed:
		return

	super(plant)
	bufferName = plant.name

	var entry := _find_buff_handler()
	if not entry.is_empty():
		call(entry.apply)

	isBuffed = true


func debuff():
	var entry := _find_buff_handler()
	if not entry.is_empty():
		call(entry.remove)
	isBuffed = false


# Locate the dispatch entry whose key appears in `bufferName`.
# Returns an empty dictionary if no entry matches.
func _find_buff_handler() -> Dictionary:
	for entry in _BUFF_HANDLERS:
		if entry.key in bufferName:
			return entry
	return {}


# === Per-buff apply / remove handlers ===

func _apply_eggworm_buff():
	if isEggWyrmBuffed: return
	_set_tentacle_digestion_time(buffedDigestTime)
	isEggWyrmBuffed = true

func _remove_eggworm_buff():
	_set_tentacle_digestion_time(ogDigestTime)


func _apply_peashooter_buff():
	if isSpyderBuffed: return
	willBelchWebs = true
	isSpyderBuffed = true

func _remove_peashooter_buff():
	willBelchWebs = false


func _apply_hive_buff():
	if isHiveBuffed: return
	detectionAreaShape.shape.radius *= 1.2
	isHiveBuffed = true

func _remove_hive_buff():
	if debug_mode:
		print("[Maw] Debuff: reverting detection radius from ", detectionAreaShape.shape.radius)
	detectionAreaShape.shape.radius = ogDetectionRadius


func _apply_sunflower_buff():
	if isSunflowerBuffed: return
	willBelchSun = true
	isSunflowerBuffed = true

func _remove_sunflower_buff():
	willBelchSun = false


func _apply_walnut_buff():
	isWalnutBuffed = true

func _remove_walnut_buff():
	pass  # Walnut buff is permanent by design

#endregion

# Sun generation (sunflower buff payout)
func generate_sun():
	var sun_instance = BLOOD_SCENE.instantiate()
	add_child(sun_instance)
	sun_instance.setWorth(bloodAmount)
	sun_instance.global_position = self.global_position + Vector2(0, -40)


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
	if tentacle1: tentacle1.queue_free()
	if tentacle2: tentacle2.queue_free()
	if tentacle3: tentacle3.queue_free()

	PlantManager.clear_space(Vector2(self.global_position.x - 16, self.global_position.y))
	PlantManager.clear_space(Vector2(self.global_position.x + 16, self.global_position.y))
	buffNodes.clearBuffs()
	queue_free()


func die_fromClearSpace():
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
