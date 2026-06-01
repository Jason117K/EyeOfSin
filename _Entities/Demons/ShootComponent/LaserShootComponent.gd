extends Node2D
# ShootComponent.gd

# Handles Shooting the Wyrm Laser
#Red Color : b00000
#Magenta : b00075
# Configuration parameters
var laser_color: Color = Color(1.0, 0.0, 0.0, 1.0)
var extension_speed: float = 1000.0
var ogExtension_Speed: float

var max_length: float = 1000.0
var ogMax_Length: float

var laser_width: float = 4.0
var damage: float = 20
var og_damage : float 
var maw_damage: float = 60
var duration: float = 0.5
var auto_fire: bool = false

var cooldown: float = 3
var blood_buff_cooldown: float = 0.9
var og_cooldown : float 
var isOcculumBuffed := false

var demon: Demon

# Zigzag parameters
@export var zigzag_height: float = 50.0  # Height of the zigzag
@export var zigzag_position: float = 300.0  # Fixed screen position where zigzag occurs
@export var zigzag_width: float = 100.0  # Width of the zigzag section

# Node references
@onready var line2D := Line2D.new()
@onready var laser_area := Area2D.new()
@onready var collision_shape := CollisionShape2D.new()
@onready var blood_spit_fx := $"../../Worm2/BloodSpitFX"
#@onready var attack_ray := $"../../DMG_RayCast2D"
var attack_ray : Node

var cooldown_timer := Timer.new() 
# State variables 
var current_length := 99.0
var is_firing := false
var timer := Timer.new()
var hit_enemies: Dictionary = {}  # Dictionary to track hit enemies
var isBuffed := false
var done_firing := true 
#var canAttack := false
var isSlowingProjectile := false
@export var isDisabled := false

#@onready var projectile_shoot_component := $"../../ProjectileShootComponent"
var projectile_shoot_component : Node

func _find_demon_ancestor() -> Demon:
	var node := get_parent()
	while node != null:
		if node is Demon:
			return node
		node = node.get_parent()
	return null

func _ready() -> void:
	attack_ray =get_node_or_null("../../DMG_RayCast2D")
	projectile_shoot_component = get_node_or_null("../../ProjectileShootComponent")
	
	
	demon = _find_demon_ancestor()
	if demon:
		laser_color = demon.laser_color
		extension_speed = demon.extension_speed
		max_length = demon.max_length
		laser_width = demon.laser_width
		damage = demon.laser_damage
		maw_damage = demon.maw_damage
		duration = demon.duration
		auto_fire = demon.laser_auto_fire
		cooldown = demon.laser_cooldown
		blood_buff_cooldown = demon.blood_buff_cooldown

	ogExtension_Speed = extension_speed
	ogMax_Length = max_length

	if isDisabled:
		return
	og_cooldown = cooldown
	og_damage = damage
	self.visible = false
	# Set up Line2D
	add_child(line2D)
	#line2D.visible = false
	line2D.points = PackedVector2Array([Vector2.ZERO, Vector2(100, 0)])
	line2D.default_color = laser_color
	line2D.width = laser_width
	line2D.begin_cap_mode = Line2D.LINE_CAP_ROUND
	line2D.end_cap_mode = Line2D.LINE_CAP_ROUND
	line2D.z_index = 1
	
	# Set up Area2D and CollisionShape2D
	add_child(laser_area)
	laser_area.add_child(collision_shape)
	laser_area.collision_mask = 2
	var shape := RectangleShape2D.new()
	collision_shape.shape = shape
	
	
	# Set up debug marker
	#var debug_marker = ColorRect.new()
	#add_child(debug_marker)
	#debug_marker.size = Vector2(5, 5)
	#debug_marker.position = Vector2(-2.5, -2.5)
	#debug_marker.color = Color.YELLOW
	
	# Set up timer
	add_child(timer)
	timer.one_shot = true
	timer.connect("timeout", Callable(self, "_on_laser_timeout"))
	


func _process(delta: float) -> void: 
	if isDisabled:
		return
	if is_firing:
		self.visible = true
		if current_length < max_length:
			current_length += extension_speed * delta
			current_length = min(current_length, max_length)
			_update_laser()
			_update_collision_shape()
			

func _on_area_exited(area: Area2D) -> void:
	if isDisabled:
		return
	# Allow re-hitting if zombie exits and re-enters
	hit_enemies.erase(area)

func _process_collision(area: Area2D) -> void:
	if isDisabled:
		return
	if "Zombie" in area.name and not hit_enemies.has(area):
		print("Damaging via signal: ", area.name)
		hit_enemies[area] = true


	
# Fire a new laser 
func fire() -> void:
	if isDisabled:
		return
	if !is_firing:
		#print("Not Firing No Return Cos Diabled Do Sutff")
		AudioManager.create_2d_audio_at_location(self.global_position, SoundEffect.SOUND_EFFECT_TYPE.WYRM_FIRE)
		is_firing = true
		current_length = 0.0
		hit_enemies.clear()  # Clear the hit enemies when firing a new laser
		#timer.wait_time = duration
		done_firing = false
		timer.wait_time = (max_length / extension_speed) + duration
		timer.start()
		blood_spit_fx.play("blood_spit")
	else:
		pass

# Update the laser points specifically, also taking into account buffs
func _update_laser() -> void:
	if isDisabled:
		return
	var points := PackedVector2Array()
	points.append(Vector2.ZERO)  # Starting point
		
	if isBuffed:
		
		if current_length <= zigzag_position:
			# Before zigzag point, just draw straight line
			points.append(Vector2(current_length, 0))
		else:
			# Add straight line up to zigzag
			points.append(Vector2(zigzag_position, 0))
		
			#Add ZigZag
			points.append(Vector2(zigzag_position + zigzag_width/4, zigzag_height))
			points.append(Vector2(zigzag_position + ((zigzag_width/4)*2), 0))
			points.append(Vector2(zigzag_position + ((zigzag_width/4)*3), zigzag_height))
			points.append(Vector2(zigzag_position + zigzag_width, 0))
		
		
		# If laser extends beyond zigzag, add final straight section
		if current_length > zigzag_position + zigzag_width:
			points.append(Vector2(current_length, 0))
	else:
		# Before zigzag point, just draw straight line
		points.append(Vector2(current_length, 0))
		
	line2D.points = points

# Updates the laser's collision specifically 
func _update_collision_shape() -> void:
	if isDisabled:
		return
	# Update collision shape to follow the laser path
	var rect_shape := collision_shape.shape as RectangleShape2D
	rect_shape.extents = Vector2(current_length / 2, laser_width ) #/2
	collision_shape.position = Vector2(current_length / 2, 0) 




# Stop firing the laser on a cooldown 
func _on_laser_timeout() -> void:
	if isDisabled:
		#print("We are diasabled return")
		return
	#print("No Return Make Length 0")
	is_firing = false
	current_length = 0.0
	hit_enemies.clear()  # Clear the hit enemies when the laser times out
	_update_laser()
	_update_collision_shape()
	done_firing = true 
	#cooldown_timer.start()


# Set the laser color 
func set_laser_color(color: Color) -> void:
	if isDisabled:
		return
	laser_color = color
	line2D.default_color = color

# Set the laser width 
func set_laser_width(width: float) -> void:
	if isDisabled:
		return
	laser_width = width
	line2D.width = width

# Make the laser more powerful when Wyrm is buffed 
func buff(bufferLocation:Vector2) -> void:
	if isDisabled:
		return
	isBuffed = true
	bufferLocation = to_local(bufferLocation)
	zigzag_position = self.position.x + (bufferLocation.x - 96)
	damage = damage * 2.0

func occulumBuff() -> void:
	if isDisabled:
		return
	cooldown = blood_buff_cooldown
	cooldown_timer.wait_time = cooldown
	#cooldown = cooldown * 0.5

func unOcculumBuff() -> void:
	if isDisabled:
		return
	cooldown = og_cooldown
	#cooldown = cooldown/2

# getter for buffed status
func getIsBuffed()->bool:
	#if isDisabled:
		#false
	return isBuffed

func mawBuff() -> void:
	damage = maw_damage
	
	
	
