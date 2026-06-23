extends Demon
#Wyrm.gd

# --- Exports: Health Buff Values ---
@export var spinalOcculumBuffed_health := 650
@export var mawBuffed_health := 350

# --- Exports: Projectile ---
@export var projectile_cooldown: float = 3
@export var projectile_auto_fire := true
@export var occulum_buff_cooldown: float = 0.9
@export var projectile_speed := 600
@export var projectile_damage := 20
@export var bleed_damage_increase := 2

# --- Exports: Laser ---
@export var laser_color: Color = Color(1.0, 0.0, 0.0, 1.0)
@export var extension_speed: float = 1000.0
@export var max_length: float = 1000.0
@export var laser_width: float = 4.0
@export var laser_damage: float = 20
@export var maw_damage: float = 60
@export var duration: float = 0.5
@export var laser_auto_fire: bool = false
@export var laser_cooldown: float = 3
@export var blood_buff_cooldown: float = 0.9

# --- Exports: Animation ---
@export var bob_speed := 2.0
@export var bob_height := 30.0
@export var squash_amount := 0.3
@export var stretch_amount := 0.3
@export var bounce_elasticity := 0.3
@export var animation_exaggeration := 1.0

# --- Exports: Sprite Path ---
@export var sprite_path: NodePath

# --- Component References ---
@onready var sprite :Node= get_node(sprite_path) if sprite_path else null
@onready var laserShootComp1 := $LaserShootComponent
@onready var laserShootComp2 := $LaserShootComponent2
@onready var projectile_shoot_component := $ProjectileShootComponent
@onready var attack_ray := $DMG_RayCast2D
@onready var shootTimer := $ShootTimer


@onready var range_line_indicator := $PreviewNodes/RangeIndicatorLine2D
@onready var og_target_position :Vector2 = attack_ray.target_position


# --- State ---
var isCrawlerBuffed := false
var isSpineBuffed := false
var isOcculumBuffed := false
var spawnAnimDone := false

# Animation state
var time := 0.0
var current_squash := 0.0
var current_stretch := 0.0
var target_squash := 0.0
var target_stretch := 0.0
var velocity := 0.0
var prev_y := 0.0
var initial_sprite_scale: Vector2
var initial_sprite_position: Vector2
var bufferName: String

signal wyrm_buff_unlocked(buff_to_unlock:String)

# --- Lifecycle ---

func _ready() -> void:
	super()
	wyrm_buff_unlocked.connect(Global.unlock_buff)
	set_process(true)  # Bob animation requires per-frame updates
	# --- Demon-specific collision ---
	_init_demon_collision()
	## --- Sprite setup ---
	#if sprite:
		#initial_sprite_scale = sprite.scale
		#initial_sprite_position = sprite.position
	#else:
		#push_warning("No sprite assigned to animate!")
		
	var scale_x :float= laserShootComp2.line2D.global_transform.x.length()   # world px per local px, along local X
	laserShootComp2.max_length =  attack_ray.target_position.x / scale_x
	laserShootComp1.max_length =  attack_ray.target_position.x / scale_x

	# --- Timer config ---
	shootTimer.wait_time = laser_cooldown
	
	hide_old_preview()

	all_synergies = Global.all_wyrm_synergies
	special_description_file = get_special_description_file(all_synergies,"Base")
	

func hide_old_preview()->void:
	$PreviewNodes/PreviewCard.visible = false 
	$PreviewNodes/PreviewCardSprite.visible = false 
	$PreviewNodes/PreviewCardShadow.visible = false 
	
func _init_demon_collision() -> void:
	if self.is_in_group("Green"):
		$DMG_RayCast2D.set_collision_mask_value(1, false)
		$DMG_RayCast2D.set_collision_mask_value(2, false)
		$DMG_RayCast2D.set_collision_mask_value(3, false)
		$DMG_RayCast2D.set_collision_mask_value(4, false)
		$DMG_RayCast2D.set_collision_mask_value(5, true)
	else:
		$DMG_RayCast2D.set_collision_mask_value(1, false)
		$DMG_RayCast2D.set_collision_mask_value(2, false)
		$DMG_RayCast2D.set_collision_mask_value(3, false)
		$DMG_RayCast2D.set_collision_mask_value(4, true)

func update_range_preview()->void:
	range_line_indicator.set_point_position(1, Vector2(attack_ray.target_position.x,range_line_indicator.get_point_position(1).y))
	
# --- Getters ---

func get_demon_true_name() -> String:
	return "Wyrm"

func get_demon_name() -> String:
	return "WYRM"

func get_damage() -> int:
	return projectile_shoot_component.projectile_damage

func get_cost() -> float:
	return cost


# --- Buff System ---

func receive_buff(demon) -> void:
	var demonName : String = (demon.get_demon_true_name())
	print("WYRM SHOULD RECEICVE BUFF FROM ", demonName)
	if !isBuffed:
		unlock_new_buff(demonName)
		super(demonName)
		
		match demonName:
			"Occulum":
				projectile_shoot_component.isOcculumBuffed = true
				laserShootComp2.occulumBuff()
				laserShootComp1.isDisabled = true 
				
			"Crawler":
				projectile_shoot_component.isCrawlerBuffed = true
			"SpinalOcculum":
				projectile_shoot_component.wyrm_bleed_buff()
			"Wyrm":
				pass
			"Hive":
				attack_ray.target_position = attack_ray.target_position + Vector2(100, 0)
				projectile_shoot_component.hiveSpawnDroneBuffed = true
			"Maw":
				laserShootComp1.isDisabled = false
				laserShootComp1._ready()
				#$ShellBack.visible = false
				laserShootComp1.mawBuff()
				#$Worm1.z_index = 2
				projectile_shoot_component.mawBuffed = true

func debuff() -> void:
	super()
	attack_ray.target_position = og_target_position
	projectile_shoot_component.debuff()
	laserShootComp1.debuff()
	laserShootComp2.debuff()

func unlock_new_buff(demonName:String)->void:
	if isBuffed == false:
		if Global.game_controller.current_scenes.size()>1:
			match demonName:
				"Occulum":
					wyrm_buff_unlocked.emit(Global.occulum_wyrm_synergy)
				"Crawler":
					wyrm_buff_unlocked.emit(Global.crawler_wyrm_synergy)
				"SpinalOcculum":
					wyrm_buff_unlocked.emit(Global.spinal_occulum_wyrm_synergy)
				"Wyrm":
					pass
				"Hive":
					wyrm_buff_unlocked.emit(Global.hive_wyrm_synergy)
				"Maw":
					wyrm_buff_unlocked.emit(Global.maw_wyrm_synergy)
					
					
# --- Death ---

func _cleanup() -> void:
	# No extra cleanup beyond base buffNodes
	super()


# --- Damage ---

func take_damage(damage: float) -> void:
	healthComp.take_damage(damage)


# --- Animation (_process) ---

func _process(delta: float) -> void:
	if not sprite:
		return

	time += delta * bob_speed

	# Calculate smooth up/down motion with slight ease-in/out
	var raw_bob := sin(time)
	var smoothed_bob : float = sign(raw_bob) * pow(abs(raw_bob), 0.7)
	var y_offset : float = smoothed_bob * bob_height * animation_exaggeration

	# Calculate velocity for squash/stretch
	var new_velocity := (y_offset - prev_y) / delta
	velocity = lerp(velocity, new_velocity, 0.5)
	prev_y = y_offset

	# Determine target squash/stretch based on motion
	var normalized_velocity : float = clamp(velocity / (bob_height * 2), -1, 1)

	if abs(normalized_velocity) > 0.1:
		target_stretch = normalized_velocity * stretch_amount * animation_exaggeration
		target_squash = -target_stretch * 0.5
	else:
		target_squash = abs(smoothed_bob) * squash_amount * animation_exaggeration
		target_stretch = -target_squash * 0.5

	# Apply bounce elasticity to squash/stretch
	current_squash = lerp(current_squash, target_squash, bounce_elasticity)
	current_stretch = lerp(current_stretch, target_stretch, bounce_elasticity)

	# Apply transformations to the sprite
	var scale_y:float = initial_sprite_scale.y * (1.0 + current_squash)
	var scale_x:float = initial_sprite_scale.x * (1.0 + current_stretch)

	# Update sprite's transform relative to its initial position
	sprite.position.x = initial_sprite_position.x
	sprite.position.y = initial_sprite_position.y + y_offset
	sprite.scale = Vector2(scale_x, scale_y)



	
func baal_buff()->void:
	super()
	baal_halo.play("top_glow")	

# --- Preview ---



func _on_mouse_exited() -> void:
	$PreviewNodes.visible = false


# --- Heart Buff ---

func receive_heart_buff()->void:
	print(self.name, " receive Heart Buff")
	buffNodes.get_child(0).visible = true
	self.health = self.health + 400

func adjust_position(_new_form:String)->void:
	pass
