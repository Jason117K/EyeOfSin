extends Demon
#Maw.gd

# === Tentacle behavior configuration ===
enum State {IDLE, EXTENDING, ATTACHED, RETRACTING, DIGESTING}

const GRAB_DISTANCE_THRESHOLD := 10.0
const ATTACH_DURATION := 0.1
const MAX_EXTEND_TIME := 3.0           # Timeout for stuck tentacles
const DIGESTION_TIME := 4.5
const EXTEND_TIME_CONSTANT := 0.75     # Exponential homing rate while EXTENDING
const RETRACT_DURATION := 0.5          # Tween duration while RETRACTING
const ABORT_RETURN_DURATION := 0.4     # Tween duration when returning to idle
const INSTAKILL_DAMAGE := 9999
const WALNUT_HEAL_AMOUNT := 100

# IDLE state offsets for each tentacle (relative to maw center)
const IDLE_OFFSETS := [
	Vector2(307.0, 282),  # Tentacle 1: upper left
	Vector2(206, 293),    # Tentacle 2: straight up
	Vector2(202, 224)     # Tentacle 3: upper right (reserved for balance tuning)
]

const BLOOD_SCENE := preload("res://_Entities/Demons/Blood/Sun.tscn")
const WEB_BALL_SCENE := preload("res://_Entities/Demons/Projectile/WebBall.tscn")


# Per-tentacle state owned by the Maw's state machine.
class TentacleState:
	var arm: Arm
	var target: ArmTarget
	var state: State
	var enemy: Node2D
	var timer: float = 0.0
	var extend_timer: float = 0.0  # Timeout tracking
	var movement_tween: Tween      # Active retract/abort tween, if any

	func _init(p_arm: Arm, p_target: ArmTarget):
		arm = p_arm
		target = p_target
		state = State.IDLE
		enemy = null
		timer = 0.0
		extend_timer = 0.0
		movement_tween = null

	# Cancel any tween currently driving the target. Call before starting a
	# new state that wants control of target.global_position.
	func kill_tween() -> void:
		if movement_tween and movement_tween.is_valid():
			movement_tween.kill()
		movement_tween = null


# === Node references ===
@onready var arm1 = $Arm
@onready var arm2 = $Arm2
@onready var arm3 = $Arm3
@onready var arm_target1 = $ArmTarget
@onready var arm_target2 = $ArmTarget2
@onready var arm_target3 = $ArmTarget3

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
var PlantManager                # Plantmanager RefCounted
var tentacles = []              # Active TentacleState objects
var attacking_tentacles = {}    # Dictionary tentacle -> enemy
var charges = 3.0               # Essentially Maw ammo
var available_tentacles = []    # Tentacles ready for assignment
var enemies_to_eat = []         # Detected zombies waiting for a free tentacle

# Buff state
var willBelchWebs = false       # Peashooter buff
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


# Sets up and configures all the tentacles.
# arm3/arm_target3 nodes exist in the scene but are intentionally inactive
# for balance tuning. Add a third TentacleState here to enable.
func setup_tentacles():
	var t1 = TentacleState.new(arm1, arm_target1)
	var t2 = TentacleState.new(arm2, arm_target2)

	tentacles = [t1, t2]
	available_tentacles = tentacles.duplicate()

	for i in range(tentacles.size()):
		var tentacle = tentacles[i]
		tentacle.target.global_position = global_position + IDLE_OFFSETS[i]

	if debug_mode:
		print("[Maw] Setup complete: %d tentacles ready" % tentacles.size())


func _process(delta):
	update_tentacles(delta)

	# Advance digestion timers
	for tentacle in tentacles:
		if tentacle.state == State.DIGESTING:
			tentacle.timer += delta
			if tentacle.timer >= DIGESTION_TIME:
				complete_digestion(tentacle)


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

	var tentacle: TentacleState = available_tentacles.pop_front()
	tentacle.kill_tween()  # Cancel any in-flight abort/retract tween
	tentacle.state = State.EXTENDING
	tentacle.enemy = target
	tentacle.timer = 0.0
	tentacle.extend_timer = 0.0
	tentacle.target.global_position = target.global_position

	attacking_tentacles[tentacle] = target

	# Charge is consumed when retraction completes, not on assignment.
	if debug_mode:
		print("[Maw] Assigned tentacle to %s - Available: %d" % [target.name, available_tentacles.size()])


# Drain the wait queue, attaching enemies to any newly-free tentacles.
# Called whenever a tentacle returns to the available pool.
func _process_queue():
	while not enemies_to_eat.is_empty() and not available_tentacles.is_empty():
		var enemy = enemies_to_eat.pop_front()
		if is_instance_valid(enemy):
			assign_tentacle_to_target(enemy)


func update_tentacles(delta: float) -> void:
	for tentacle in attacking_tentacles.keys():
		var enemy = tentacle.enemy

		if not is_instance_valid(enemy):
			if debug_mode:
				print("[Maw] Enemy became invalid, aborting")
			abort_tentacle(tentacle)
			continue

		match tentacle.state:
			State.EXTENDING:
				update_extending_state(tentacle, enemy, delta)
			State.ATTACHED:
				update_attached_state(tentacle, enemy, delta)
			State.RETRACTING:
				update_retracting_state(tentacle, enemy, delta)


# EXTENDING: tentacle chasing enemy. Framerate-independent exponential approach,
# so the target tracks moving enemies and the pacing doesn't change with FPS.
func update_extending_state(tentacle: TentacleState, enemy: Node2D, delta: float) -> void:
	var lerp_weight = 1.0 - exp(-delta / EXTEND_TIME_CONSTANT)
	tentacle.target.global_position = tentacle.target.global_position.lerp(enemy.global_position, lerp_weight)

	tentacle.extend_timer += delta
	if tentacle.extend_timer > MAX_EXTEND_TIME:
		if debug_mode:
			print("[Maw] Extension timeout, giving up on enemy")
		abort_tentacle(tentacle)
		return

	var arm_tip_global = tentacle.arm.to_global(tentacle.arm.get_segments()[-1])
	if arm_tip_global.distance_to(enemy.global_position) < GRAB_DISTANCE_THRESHOLD:
		tentacle.state = State.ATTACHED
		tentacle.timer = 0.0
		AudioManager.create_2d_audio_at_location(global_position, SoundEffect.SOUND_EFFECT_TYPE.MAW_GRAB)
		if debug_mode:
			print("[Maw] Grabbed enemy at distance: %.1fpx" % arm_tip_global.distance_to(enemy.global_position))


# ATTACHED: brief hold before retracting.
# Pin enemy to the arm tip without updating the target — locking the target
# eliminates the target -> arm tip -> enemy -> target drift loop.
func update_attached_state(tentacle: TentacleState, enemy: Node2D, delta: float) -> void:
	var arm_tip_global = tentacle.arm.to_global(tentacle.arm.get_segments()[-1])
	enemy.global_position = arm_tip_global

	tentacle.timer += delta
	if tentacle.timer >= ATTACH_DURATION:
		start_tentacle_retraction(tentacle)


# RETRACTING: the tween (set up in start_tentacle_retraction) drives the target.
# Each frame we just pin the enemy to the arm tip.
func update_retracting_state(tentacle: TentacleState, enemy: Node2D, _delta: float) -> void:
	if is_instance_valid(enemy):
		var arm_tip_global = tentacle.arm.to_global(tentacle.arm.get_segments()[-1])
		enemy.global_position = arm_tip_global


func start_tentacle_retraction(tentacle: TentacleState) -> void:
	tentacle.state = State.RETRACTING
	tentacle.kill_tween()

	var maw_center = animSpriteComp.global_position
	tentacle.movement_tween = create_tween()
	tentacle.movement_tween.tween_property(tentacle.target, "global_position", maw_center, RETRACT_DURATION)
	tentacle.movement_tween.tween_callback(finish_tentacle_retraction.bind(tentacle))

	if debug_mode:
		print("[Maw] Starting tentacle retraction")


# Damage enemy, hide arm, start digestion
func finish_tentacle_retraction(tentacle: TentacleState) -> void:
	var enemy = tentacle.enemy

	tentacle.arm.base_node.visible = false
	if tentacle.arm.shadow_node:
		tentacle.arm.shadow_node.visible = false

	if debug_mode:
		print("[Maw] finish_tentacle_retraction enemy=", enemy)

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

	tentacle.state = State.DIGESTING
	tentacle.timer = 0.0
	tentacle.movement_tween = null  # Tween finished naturally; drop the ref
	charges -= 1
	attacking_tentacles.erase(tentacle)

	if debug_mode:
		print("[Maw] Retraction complete, starting digestion (charges: %d)" % charges)


# Abort current attack and ease tentacle back to idle position.
func abort_tentacle(tentacle: TentacleState) -> void:
	tentacle.state = State.IDLE
	tentacle.enemy = null
	tentacle.timer = 0.0
	tentacle.extend_timer = 0.0
	tentacle.kill_tween()

	if not tentacle in available_tentacles:
		available_tentacles.append(tentacle)
	attacking_tentacles.erase(tentacle)

	var tentacle_index = tentacles.find(tentacle)
	if tentacle_index >= 0:
		var idle_pos = global_position + IDLE_OFFSETS[tentacle_index]
		tentacle.movement_tween = create_tween()
		tentacle.movement_tween.tween_property(tentacle.target, "global_position", idle_pos, ABORT_RETURN_DURATION)

	_process_queue()


# Return tentacle to IDLE after digestion
func complete_digestion(tentacle: TentacleState) -> void:
	tentacle.state = State.IDLE
	tentacle.enemy = null
	tentacle.timer = 0.0

	tentacle.arm.base_node.visible = true
	if tentacle.arm.shadow_node:
		tentacle.arm.shadow_node.visible = true

	var tentacle_index = tentacles.find(tentacle)
	if tentacle_index >= 0:
		tentacle.target.global_position = global_position + IDLE_OFFSETS[tentacle_index]

	if not tentacle in available_tentacles:
		available_tentacles.append(tentacle)

	charges += 1
	if charges > tentacles.size():
		charges = tentacles.size()

	if willBelchSun:
		generate_sun()

	if debug_mode:
		print("[Maw] Digestion complete - Available: %d, Charges: %d" % [available_tentacles.size(), charges])

	_process_queue()


# Legacy DigestionTimer handler. The Timer node is never started in the
# current flow; retained until the cleanup pass deletes the node.
func _on_DigestionTimer_timeout():
	charges += 1
	if charges > tentacles.size():
		charges = tentacles.size()
	if willBelchSun:
		generate_sun()


# Handles receiving buffs from EggWorm, Peashooter, Hive, Sunflower, Walnut.
# First buff wins — subsequent buffs are ignored by design.
func receiveBuff(plant):
	animSpriteComp.receiveBuff(plant)
	if isBuffed:
		return

	super(plant)
	bufferName = plant.name

	if "EggWorm" in bufferName and not isEggWyrmBuffed:
		digestionTimer.wait_time = buffedDigestTime
		isEggWyrmBuffed = true
	elif "Peashooter" in bufferName and not isSpyderBuffed:
		willBelchWebs = true
		isSpyderBuffed = true
	elif "Hive" in bufferName and not isHiveBuffed:
		detectionAreaShape.shape.radius = detectionAreaShape.shape.radius * 1.2
		isHiveBuffed = true
	elif "Sunflower" in bufferName and not isSunflowerBuffed:
		willBelchSun = true
		isSunflowerBuffed = true
	elif "Walnut" in bufferName:
		isWalnutBuffed = true

	isBuffed = true


func debuff():
	if "EggWorm" in bufferName:
		digestionTimer.wait_time = ogDigestTime
	elif "Peashooter" in bufferName:
		willBelchWebs = false
	elif "Hive" in bufferName:
		if debug_mode:
			print("[Maw] Debuff: reverting detection radius from ", detectionAreaShape.shape.radius)
		detectionAreaShape.shape.radius = ogDetectionRadius
	elif "Sunflower" in bufferName:
		willBelchSun = false
	isBuffed = false


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
	if arm1: arm1.queue_free()
	if arm2: arm2.queue_free()
	if arm3: arm3.queue_free()

	PlantManager.clear_space(Vector2(self.global_position.x - 16, self.global_position.y))
	PlantManager.clear_space(Vector2(self.global_position.x + 16, self.global_position.y))
	buffNodes.clearBuffs()
	queue_free()


func die_fromClearSpace():
	buffNodes.clearBuffs()
	queue_free()


func show_tentacles():
	$Arm.visible = true
	$Arm2.visible = true


func _on_mouse_entered() -> void:
	$PreviewNodes/AnimatedSprite2.visible = false
	$PreviewNodes.visible = true


func _on_mouse_exited() -> void:
	$PreviewNodes.visible = false


func finish_spawn():
	super()
	show_tentacles()
