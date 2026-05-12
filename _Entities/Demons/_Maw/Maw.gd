extends Demon
#Maw.gd

const BLOOD_SCENE := preload("res://_Entities/Demons/Blood/Sun.tscn")
const WEB_BALL_SCENE := preload("res://_Entities/Demons/Projectile/WebBall.tscn")
const INSTAKILL_DAMAGE := 9999
const WALNUT_HEAL_AMOUNT := 100

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
@onready var digestionTimer = $DigestionTimer
@onready var detection_area = $DetectionComponent
@onready var buffNodes = $BuffNodesComponent
@onready var ogDetectionRadius = detectionAreaShape.shape.radius

# === Exports ===
@export var cost = 200
@export var alt_target_color: Color
@export var alt_replace_color: Color
@export var debug_mode: bool = false
@export var bloodAmount = 10
@export var digestTime: float
@export var buffedDigestTime: float

@onready var ogDigestTime = digestTime

# === Runtime state ===
var PlantManager                              # PlantManager RefCounted
var tentacles: Array[Tentacle] = []           # Active Tentacles
var attacking_tentacles: Dictionary = {}      # tentacle -> enemy
var available_tentacles: Array[Tentacle] = [] # Tentacles ready for assignment
var enemies_to_eat: Array = []                # Detected zombies waiting for a free tentacle
var charges: float = 3.0                      # Essentially Maw ammo

# Buff state
var willBelchWebs := false                    # Peashooter buff
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
# Tentacle3 exists in the scene but is intentionally inactive for balance
# tuning. Append it to `tentacles` to enable.
func setup_tentacles():
	tentacles = [tentacle1, tentacle2]
	available_tentacles = tentacles.duplicate()

	for tentacle in tentacles:
		tentacle.retraction_center_provider = _get_retraction_center
		tentacle.grabbed_enemy.connect(_on_tentacle_grabbed.bind(tentacle))
		tentacle.retraction_finished.connect(_on_tentacle_retraction_finished.bind(tentacle))
		tentacle.ready_again.connect(_on_tentacle_ready_again.bind(tentacle))
		tentacle.aborted.connect(_on_tentacle_aborted.bind(tentacle))

	if debug_mode:
		print("[Maw] Setup complete: %d tentacles ready" % tentacles.size())


# Tentacles retract toward the Maw's animated sprite center, not the Maw root.
func _get_retraction_center() -> Vector2:
	return animSpriteComp.global_position


# Assign a target to a tentacle, or queue it if none are free.
func assign_tentacle_to_target(target):
	# Prevent double-assignment
	if target in attacking_tentacles.values():
		if debug_mode:
			print("[Maw] Target already being eaten, skipping")
		return

	if available_tentacles.is_empty() or charges <= 0:
		if not target in enemies_to_eat:
			enemies_to_eat.append(target)
		return

	var tentacle: Tentacle = available_tentacles.pop_front()
	attacking_tentacles[tentacle] = target
	tentacle.attack(target)

	# Charge is consumed on retraction completion, not on assignment.
	if debug_mode:
		print("[Maw] Assigned tentacle to %s - Available: %d" % [target.name, available_tentacles.size()])


# Drain the wait queue, attaching enemies to any newly-free tentacles.
func _process_queue():
	while not enemies_to_eat.is_empty() and not available_tentacles.is_empty():
		var enemy = enemies_to_eat.pop_front()
		if is_instance_valid(enemy):
			assign_tentacle_to_target(enemy)


# === Tentacle signal handlers ===

func _on_tentacle_grabbed(_enemy: Node2D, _tentacle: Tentacle) -> void:
	AudioManager.create_2d_audio_at_location(global_position, SoundEffect.SOUND_EFFECT_TYPE.MAW_GRAB)
	if debug_mode:
		print("[Maw] Tentacle grabbed enemy")


func _on_tentacle_retraction_finished(enemy: Node2D, tentacle: Tentacle) -> void:
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

	charges -= 1
	attacking_tentacles.erase(tentacle)

	if debug_mode:
		print("[Maw] Tentacle retraction finished (charges: %d)" % charges)


func _on_tentacle_ready_again(tentacle: Tentacle) -> void:
	if not tentacle in available_tentacles:
		available_tentacles.append(tentacle)

	charges += 1
	if charges > tentacles.size():
		charges = tentacles.size()

	if willBelchSun:
		generate_sun()

	if debug_mode:
		print("[Maw] Tentacle ready again - Available: %d, Charges: %d" % [available_tentacles.size(), charges])

	_process_queue()


func _on_tentacle_aborted(tentacle: Tentacle) -> void:
	if not tentacle in available_tentacles:
		available_tentacles.append(tentacle)
	attacking_tentacles.erase(tentacle)

	if debug_mode:
		print("[Maw] Tentacle aborted")

	_process_queue()


# Legacy DigestionTimer handler. The Timer node is never started in the
# current flow; retained until the cleanup pass deletes the node.
func _on_DigestionTimer_timeout():
	charges += 1
	if charges > tentacles.size():
		charges = tentacles.size()
	if willBelchSun:
		generate_sun()


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
	digestionTimer.wait_time = buffedDigestTime
	isEggWyrmBuffed = true

func _remove_eggworm_buff():
	digestionTimer.wait_time = ogDigestTime


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


func _on_mouse_entered() -> void:
	$PreviewNodes/AnimatedSprite2.visible = false
	$PreviewNodes.visible = true


func _on_mouse_exited() -> void:
	$PreviewNodes.visible = false


func finish_spawn():
	super()
	show_tentacles()
