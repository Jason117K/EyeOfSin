extends Demon
#Maw.gd

var spawnAnimDone = false

# Color export variables for tentacle 1
@export var tentacle1_start_color := Color(0.8, 0.2, 0.2, 1.0)  # Blood red / 8d0000 is red, 8c005e is other color
var tentacle1_end_color := Color(0.4, 0.0, 0.0, 1.0)    # Dark red  

# Color export variables for tentacle 2
@export var tentacle2_start_color := Color(0.7, 0.0, 1.0, 1.0)  # Bright purple  / 8d0000
var tentacle2_end_color := Color(0.35, 0.0, 0.5, 1.0)   # Dark purple

# Color export variables for tentacle 3
@export var tentacle3_start_color := Color(0.0, 1.0, 0.0, 1.0)  # Bright green  / 8d0000
var tentacle3_end_color := Color(1.0, 1.0, 0.0, 1.0)    # Yellow

# Tentacle state machine
enum State {IDLE, EXTENDING, ATTACHED, RETRACTING, DIGESTING}

# Tentacle behavior configuration
const GRAB_DISTANCE_THRESHOLD = 10.0
const RETRACT_DISTANCE_THRESHOLD = 5.0
const ATTACH_DURATION = 0.1
const MAX_EXTEND_TIME = 3.0  # Timeout for stuck tentacles
const DIGESTION_TIME = 4.5  # Match existing digestion_time variable

# Extension/Retraction animation speeds
const EXTEND_DURATION = 0.75  # Seconds to fully extend to enemy
const RETRACT_DURATION = 0.5  # Seconds to fully retract to maw center

# IDLE state offsets for each tentacle (relative to maw center)
const IDLE_OFFSETS = [
	Vector2(307.0, 282),  # Tentacle 1: upper left
	Vector2(206, 293),    # Tentacle 2: straight up
	Vector2(202, 224)    # Tentacle 3: upper right
]

# Tentacle state tracking
class TentacleState:
	var arm: Arm
	var target: ArmTarget
	var state: State
	var enemy: Node2D
	var timer: float = 0.0
	var extend_timer: float = 0.0  # Timeout tracking

	func _init(p_arm: Arm, p_target: ArmTarget):
		arm = p_arm
		target = p_target
		state = State.IDLE
		enemy = null
		timer = 0.0
		extend_timer = 0.0

# References to Arm tentacles (already in scene)
@onready var arm1 = $Arm
@onready var arm2 = $Arm2
@onready var arm3 = $Arm3
@onready var arm_target1 = $ArmTarget
@onready var arm_target2 = $ArmTarget2
@onready var arm_target3 = $ArmTarget3

@onready var detectionAreaShape = $DetectionComponent/CollisionShape2D
#Adjustable maw health & cost 
#@export var health = 100
#@export var walnutHealth = 600
#
#@onready var ogHealth = 100
@export var cost = 200

@export var alt_target_color : Color
@export var alt_replace_color : Color

# Debug mode for verbose console output
@export var debug_mode: bool = false

var PlantManager              # Plantmanager RefCounted 
var tentacles = []            # Array to track all tentacles (now TentacleState objects)
var attacking_tentacles = {}  # Dictionary to track which tentacles are attacking which enemies
var currentTentacle
var charges = 3.0             # Essentially Maw ammo 
var willBelchWebs = false     # Whether or not we have a peashooter buff 
var available_tentacles = []  # Track which tentacles are available
var enemies_to_eat = []       # Enemies in Detection zone that couldn't be eaten yet
var willBelchSun := false 
var isEggWyrmBuffed := false 
var isSpyderBuffed := false
var isHiveBuffed := false 
var isSunflowerBuffed:= false 	
var isWalnutBuffed := false


@export var bloodAmount = 10

#Essentially a reload timer for the maw
@onready var digestionTimer = $DigestionTimer
@export var digestTime : float
@export var buffedDigestTime : float
@onready var ogDigestTime = digestTime
# Detection radius for zombies
@onready var detection_area = $DetectionComponent
@onready var buffNodes = $BuffNodesComponent
@onready var ogDetectionRadius = detectionAreaShape.shape.radius

var bloodScene = preload("res://_Entities/Demons/Blood/Sun.tscn")  
var bufferName : String 

func _ready():
	super()
	collision_mask = 2

	#print("Maw Area2D: ", name)
	#print("Maw Collision Layer: ", collision_layer)
	#print("Maw Collision Mask: ", collision_mask)
	#print("Maw Monitoring: ", monitoring)
	#print("Maw Monitorable: ", monitorable)
	
	PlantManager = get_parent().get_parent().get_node("PlantManager")
	setup_tentacles()

	
#Plant Cost Getter
func get_cost():
	return cost
		
#Sets Up and Configures all the tentacles
func setup_tentacles():
	# Initialize tentacle state objects
	var t1 = TentacleState.new(arm1, arm_target1)
	var t2 = TentacleState.new(arm2, arm_target2)
	var t3 = TentacleState.new(arm3, arm_target3)

	tentacles = [t1, t2]
	available_tentacles = tentacles.duplicate()

	# Set initial IDLE positions
	for i in range(tentacles.size()):
		var tentacle = tentacles[i]
		var maw_center = global_position
		tentacle.target.global_position = maw_center + IDLE_OFFSETS[i]

	if debug_mode:
		print("[Maw] Setup complete: %d tentacles ready" % tentacles.size())


func get_end_location():
	# Return the tip of the first arm (in global space)
	if arm1 and arm1.get_segments().size() > 0:
		var arm_tip_local = arm1.get_segments()[-1]
		return arm1.to_global(arm_tip_local)
	return global_position
	
#Constantly check for enemies in range and assign them for eating appropriately
func _process(delta):
	# Process enemy queue
	if enemies_to_eat.size() > 0:
		for enemy in enemies_to_eat.duplicate():  # Duplicate to avoid modification during iteration
			if enemy != null and is_instance_valid(enemy):
				assign_tentacle_to_target(enemy)

	# Update all active tentacles
	update_tentacles(delta)

	# Update digesting tentacles
	for tentacle in tentacles:
		if tentacle.state == State.DIGESTING:
			tentacle.timer += delta
			if tentacle.timer >= DIGESTION_TIME:
				complete_digestion(tentacle)
	#var overlapping_areas = detection_area.get_overlapping_areas()
	#print("Maw Overlapping Areas Is ", overlapping_areas)
	#for area in overlapping_areas:
		#print("AArea Is ", area)
		#if area.is_in_group("Zombie"):
			#print("BBAssigning Tentacle to  ", area)
		###	assign_tentacle_to_target(area)

#Assign a target to a tentacle
func assign_tentacle_to_target(target):
	# Remove from queue if it was waiting
	if target in enemies_to_eat:
		enemies_to_eat.erase(target)

	# Prevent double-assignment
	if target in attacking_tentacles.values():
		if debug_mode:
			print("[Maw] Target already being eaten, skipping")
		return

	# Check availability
	if available_tentacles.size() > 0 and charges > 0:
		var tentacle: TentacleState = available_tentacles.pop_front()

		# Setup tentacle state
		tentacle.state = State.EXTENDING
		tentacle.enemy = target
		tentacle.timer = 0.0
		tentacle.extend_timer = 0.0  # Reset timeout

		# Move ArmTarget to enemy position (Arm will follow)
		tentacle.target.global_position = target.global_position

		# Track assignment
		attacking_tentacles[tentacle] = target

		# Don't consume charge yet - wait until retraction completes
		# This matches old behavior where charge is consumed in retraction handler

		if debug_mode:
			print("[Maw] Assigned tentacle to %s - Available: %d" % [target.name, available_tentacles.size()])
	else:
		# Queue for later
		if not target in enemies_to_eat:
			enemies_to_eat.append(target)


func update_tentacles(delta: float) -> void:
	"""Main state machine update - called every frame"""

	# Iterate over attacking tentacles (currently active)
	for tentacle in attacking_tentacles.keys():
		var enemy = tentacle.enemy

		# CRITICAL: Validate enemy still exists
		if not is_instance_valid(enemy):
			if debug_mode:
				print("[Maw] Enemy became invalid, aborting")
			abort_tentacle(tentacle)
			continue

		# State machine
		match tentacle.state:
			State.EXTENDING:
				update_extending_state(tentacle, enemy, delta)
			State.ATTACHED:
				update_attached_state(tentacle, enemy, delta)
			State.RETRACTING:
				update_retracting_state(tentacle, enemy, delta)


func update_extending_state(tentacle: TentacleState, enemy: Node2D, delta: float) -> void:
	"""Handle EXTENDING state: Tentacle chasing enemy"""

	# Smoothly move target toward enemy over EXTEND_DURATION
	var lerp_weight = delta / EXTEND_DURATION
	tentacle.target.global_position = tentacle.target.global_position.lerp(enemy.global_position, lerp_weight)

	# Track timeout
	tentacle.extend_timer += delta
	if tentacle.extend_timer > MAX_EXTEND_TIME:
		if debug_mode:
			print("[Maw] Extension timeout, giving up on enemy")
		abort_tentacle(tentacle)
		return

	# Check if arm tip reached enemy (DISTANCE-BASED DETECTION)
	var arm_tip_local = tentacle.arm.get_segments()[-1]  # Last segment in local space
	var arm_tip_global = tentacle.arm.to_global(arm_tip_local)  # Convert to global
	var distance_to_enemy = arm_tip_global.distance_to(enemy.global_position)

	if distance_to_enemy < GRAB_DISTANCE_THRESHOLD:
		# Transition to ATTACHED
		tentacle.state = State.ATTACHED
		tentacle.timer = 0.0

		# Audio feedback
		AudioManager.create_2d_audio_at_location(global_position, SoundEffect.SOUND_EFFECT_TYPE.MAW_GRAB)

		if debug_mode:
			print("[Maw] Grabbed enemy at distance: %.1fpx" % distance_to_enemy)


func update_attached_state(tentacle: TentacleState, enemy: Node2D, delta: float) -> void:
	"""Handle ATTACHED state: Brief hold before retracting"""

	# Keep target on enemy (Arm follows)
	tentacle.target.global_position = enemy.global_position

	# Pin enemy to arm tip
	var arm_tip_local = tentacle.arm.get_segments()[-1]
	var arm_tip_global = tentacle.arm.to_global(arm_tip_local)
	enemy.global_position = arm_tip_global

	# Update timer
	tentacle.timer += delta
	if tentacle.timer >= ATTACH_DURATION:
		start_tentacle_retraction(tentacle)


func update_retracting_state(tentacle: TentacleState, enemy: Node2D, delta: float) -> void:
	"""Handle RETRACTING state: Pulling enemy to maw center"""

	# Smoothly move target toward maw center over RETRACT_DURATION
	var maw_center = animSpriteComp.global_position
	var lerp_weight = delta / RETRACT_DURATION
	tentacle.target.global_position = tentacle.target.global_position.lerp(maw_center, lerp_weight)

	# Keep enemy attached if still valid
	if is_instance_valid(enemy):
		var arm_tip_local = tentacle.arm.get_segments()[-1]
		var arm_tip_global = tentacle.arm.to_global(arm_tip_local)
		enemy.global_position = arm_tip_global

	# Check if arm tip reached maw center (DISTANCE-BASED DETECTION)
	var arm_tip_local2 = tentacle.arm.get_segments()[-1]
	var arm_tip_global2 = tentacle.arm.to_global(arm_tip_local2)
	var distance_to_center = arm_tip_global2.distance_to(maw_center)

	if distance_to_center < RETRACT_DISTANCE_THRESHOLD:
		finish_tentacle_retraction(tentacle)
	else:
		#print(RETRACT_DISTANCE_THRESHOLD, "Dist to cent is ", distance_to_center)
		pass


func start_tentacle_retraction(tentacle: TentacleState) -> void:
	"""Begin retraction sequence"""
	tentacle.state = State.RETRACTING

	if debug_mode:
		print("[Maw] Starting tentacle retraction")


func finish_tentacle_retraction(tentacle: TentacleState) -> void:
	"""Complete retraction - damage enemy, hide arm, start digestion"""
	var enemy = tentacle.enemy

	# Make arm invisible
	tentacle.arm.base_node.visible = false
	if tentacle.arm.shadow_node:
		tentacle.arm.shadow_node.visible = false

	# Damage enemy if still valid
	print("Enemy is ", enemy)
	if is_instance_valid(enemy):
		print("Enemy Is Valid")
		enemy.visible = false
		var enemyCompManager = enemy.getCompManager()
		enemyCompManager.take_damage(9999)

		# Audio feedback
		#AudioManager.create_2d_audio_at_location(global_position, SoundEffect.SOUND_EFFECT_TYPE.MAW_CHOMP)

		# Handle buffs (walnut health gain)
		if isWalnutBuffed:
			healthComp.health += 100

		# Check for web belch (spyder buff + slowed enemy)
		var slow = enemyCompManager.getSlow()
		if slow > 0 and willBelchWebs:
			var web_ball = preload("res://_Entities/Demons/Projectile/WebBall.tscn").instantiate()
			add_child(web_ball)
			web_ball.target_position = Vector2(100, 0)
			web_ball.travel_time = 1.5

	# Start digestion
	tentacle.state = State.DIGESTING
	tentacle.timer = 0.0

	# Consume charge (matches old system timing)
	charges -= 1

	# Remove from attacking dictionary
	attacking_tentacles.erase(tentacle)

	if debug_mode:
		print("[Maw] Retraction complete, starting digestion (charges: %d)" % charges)


func abort_tentacle(tentacle: TentacleState) -> void:
	"""Abort current attack and return tentacle to idle"""
	tentacle.state = State.IDLE
	tentacle.enemy = null
	tentacle.timer = 0.0
	tentacle.extend_timer = 0.0

	# Return to available pool
	if not tentacle in available_tentacles:
		available_tentacles.append(tentacle)

	# Remove from attacking dictionary
	attacking_tentacles.erase(tentacle)

	# Reset target to idle position
	var tentacle_index = tentacles.find(tentacle)
	if tentacle_index >= 0:
		var maw_center = global_position
		tentacle.target.global_position = maw_center + IDLE_OFFSETS[tentacle_index]


func complete_digestion(tentacle: TentacleState) -> void:
	"""Return tentacle to IDLE after digestion"""
	# Return to IDLE state
	tentacle.state = State.IDLE
	tentacle.enemy = null
	tentacle.timer = 0.0

	# Make arm visible again
	tentacle.arm.base_node.visible = true
	if tentacle.arm.shadow_node:
		tentacle.arm.shadow_node.visible = true

	# Reset ArmTarget to IDLE offset
	var tentacle_index = tentacles.find(tentacle)
	if tentacle_index >= 0:
		var maw_center = global_position
		tentacle.target.global_position = maw_center + IDLE_OFFSETS[tentacle_index]

	# Return to available pool
	if not tentacle in available_tentacles:
		available_tentacles.append(tentacle)

	# Regenerate charge
	charges += 1
	if charges > tentacles.size():
		charges = tentacles.size()

	# Belch sun if buffed
	if willBelchSun:
		generate_sun()

	if debug_mode:
		print("[Maw] Digestion complete - Available: %d, Charges: %d" % [available_tentacles.size(), charges])



#When the time is up, free up a tentacle by adding a charge
func _on_DigestionTimer_timeout():
	charges += 1
	if charges > tentacles.size():
		charges = tentacles.size()
		
	# Make a tentacle available if we have charges
	for tentacle in tentacles:
		if not tentacle in available_tentacles and not tentacle in attacking_tentacles:
			available_tentacles.append(tentacle)
			tentacle.visible = true
			break
	if willBelchSun:
		generate_sun()

#Handles Receiving Buffs From EggWorm, Peashooter, and Hive, setting color accordingly 
func receiveBuff(plant):
	#print("Maw7",bufferName)
	animSpriteComp.receiveBuff(plant)
	if !isBuffed:
		super(plant)
		bufferName = plant.name
		if("EggWorm" in bufferName) && !isEggWyrmBuffed:
			#print("Maw7 Buffer Was Eggworm")
				#tentacle1.set_colors(Color.YELLOW, Color.YELLOW)
				#tentacle2.set_colors(Color.BLUE, Color.BLUE)
				#TODO Re Implement Color Changes
				#$AnimatedSprite2D.change_color()
			digestionTimer.wait_time = buffedDigestTime
			isEggWyrmBuffed = true 
			#animSpriteComp.speed_scale = animSpriteComp.speed_scale * 1.5
		elif("Peashooter" in bufferName) && !isSpyderBuffed:
				#tentacle1.set_colors(Color.PURPLE, Color.PURPLE)
				#tentacle2.set_colors(Color.DARK_MAGENTA, Color.DARK_MAGENTA)
			willBelchWebs = true
			isSpyderBuffed = true 
			#print("Maw7 Buffer Was Peashooter")

		elif("Hive" in bufferName) && !isHiveBuffed:
				#tentacle1.set_colors(Color.WHITE, Color.WHITE)
				#tentacle2.set_colors(Color.BLACK, Color.BLACK)
			#print("Maw7 DD Area Shape Radius is : ", detectionAreaShape.shape.radius)
			detectionAreaShape.shape.radius = detectionAreaShape.shape.radius * 1.2
			#health = 200
			#print("Maw7 Buffer Was HHIve")
			#TODO Re Implement Color Changes
				#$AnimatedSprite2D.change_color_specific(alt_target_color,alt_replace_color)
			isHiveBuffed = true 
		elif("Sunflower" in bufferName) && !isSunflowerBuffed:
			willBelchSun = true 
			isSunflowerBuffed = true 
			#print("Maw7 Buffer Was Sunflower")
		elif "Walnut" in bufferName:
			#health = walnutHealth
			isWalnutBuffed = true
			#print("Maw7 Buffer Was Walnut")
		isBuffed = true 
	
func debuff():
	if("EggWorm" in bufferName):
		#tentacle1.set_colors(Color.YELLOW, Color.YELLOW)
		#tentacle2.set_colors(Color.BLUE, Color.BLUE)
		digestionTimer.wait_time = ogDigestTime
	elif("Peashooter" in bufferName):
	#	tentacle1.set_colors(Color.PURPLE, Color.PURPLE)
	#	tentacle2.set_colors(Color.DARK_MAGENTA, Color.DARK_MAGENTA)
		willBelchWebs = false
	elif("Hive" in bufferName):
	#	tentacle1.set_colors(Color.WHITE, Color.WHITE)
	#	tentacle2.set_colors(Color.BLACK, Color.BLACK)
		print("DD Area Shape Radius is : ", detectionAreaShape.shape.radius)
		detectionAreaShape.shape.radius = ogDetectionRadius
		#health = ogHealth
		print("Buffer Was HHIve")
	elif("Sunflower" in bufferName):
		willBelchSun = false 
	isBuffed = false 		


func spawn_done():
	if spawnAnimDone:
		pass
	else:
		spawnAnimDone = true 
		
		

# Function to handle sun generation
func generate_sun():
	var sun_instance = bloodScene.instantiate()  # Create a new instance of the sun
	add_child(sun_instance)  # Add the sun to the scene
	sun_instance.setWorth(bloodAmount)
	#Set the sun pos to above the sunflower
	sun_instance.global_position = self.global_position + Vector2(0,-40)	
		


func _on_detection_component_area_entered(area: Area2D) -> void:
	if area.is_in_group("Zombie"):
	#	print("Maw Assigning Tentacle to  ", area)
		#if area.get_parent().get_parent() == self.get_parent().get_parent(): #Dimension Check
		if area.is_in_group("Green"):
			if self.is_in_group("Purple"):
				return
		elif area.is_in_group("Purple"):
			if self.is_in_group("Green"):
				return
		if("Boss" in area.get_name()):

			return

		assign_tentacle_to_target(area)
		
func die():
	#print(" QQ MAW IS DYING 1111111111111111")

	# FREE ALL ARM TENTACLES
	if arm1: arm1.queue_free()
	if arm2: arm2.queue_free()
	if arm3: arm3.queue_free()

	#PlantManager.clear_space(self.global_position)
	PlantManager.clear_space(Vector2(self.global_position.x-16,self.global_position.y))
	PlantManager.clear_space(Vector2(self.global_position.x+16,self.global_position.y))
	buffNodes.clearBuffs()
	queue_free()	


func die_fromClearSpace():
	#print("QQ MAW IS DYING 222222222222222")
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

	
