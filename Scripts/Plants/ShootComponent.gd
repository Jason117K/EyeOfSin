extends Node2D
# ShootComponent.gd

# Handles Shooting the EggWorm Laser 
#Red Color : b00000
#Magenta : b00075
# Configuration parameters
@export var laser_color: Color = Color(1.0, 0.0, 0.0, 1.0)  # Default red laser
@export var extension_speed: float = 1000.0  # Pixels per second
@onready var ogExtension_Speed := extension_speed

@export var max_length: float = 1000.0
@onready var ogMax_Length := max_length

@export var laser_width: float = 4.0  # Increased for visibility
@export var damage: float = 20
var og_damage
@export var maw_damage: float = 60
@export var duration: float = 0.5
@export var auto_fire: bool = false


@export var cooldown: float = 3
@export var sun_buff_cooldown: float = 0.9
var og_cooldown 
var isSunBuffed := false 

# Zigzag parameters
@export var zigzag_height: float = 50.0  # Height of the zigzag
@export var zigzag_position: float = 300.0  # Fixed screen position where zigzag occurs
@export var zigzag_width: float = 100.0  # Width of the zigzag section

# Node references
@onready var line2D := Line2D.new()
@onready var laser_area := Area2D.new()
@onready var collision_shape := CollisionShape2D.new()
@onready var attack_ray = $"../../DMG_RayCast2D"
var projectile_scene = preload("res://Scenes/PlantScenes/EggProjectile.tscn")  # Load the projectile scene
var projectile_scene_slow = preload("res://Scripts/Plants/PeaProjectile.gd")
var cooldown_timer := Timer.new() 
# State variables 
var current_length := 0.0
var is_firing := false
var timer := Timer.new()
var hit_enemies = {}  # Dictionary to track hit enemies
var isBuffed := false
var canAttack := false
var isSlowingProjectile := false
@export var isDisabled := false

func _ready() -> void:
	if isDisabled:
		return
	og_cooldown = cooldown
	og_damage =damage
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
	var shape = RectangleShape2D.new()
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
	
	if auto_fire:
		print("AUTO FIRE TRUUUU")
		cooldown_timer = Timer.new()
		add_child(cooldown_timer)
		cooldown_timer.wait_time = cooldown
		cooldown_timer.connect("timeout", Callable(self, "fire"))
		#cooldown_timer.one_shot = true
		cooldown_timer.start()

	# Initialize a set to track currently overlapping areas
	#var currently_overlapping_areas = []

func _process(delta: float) -> void: 
	if isDisabled:
		return
	if attack_ray.is_colliding():
		var collider = attack_ray.get_collider()
		#print("ppp ray collider is" , collider)
		if collider:
			#print("Collider Name is ", collider.name)
			if collider.is_in_group("Zombie"):
				#if collider.get_parent().get_parent() != self.get_parent().get_parent().get_parent().get_parent():
					#return
				if collider.is_in_group("Green"):
					if self.is_in_group("Purple"):
						return
				elif collider.is_in_group("Purple"):
					if self.is_in_group("Green"):
						return
				#print("PPP can attack is true")
				canAttack = true 
				#line2D.visible = true
			else:
				canAttack = false
				#line2D.visible = false
	if is_firing:
		self.visible = true
		if current_length < max_length:
			current_length += extension_speed * delta
			current_length = min(current_length, max_length)
			_update_laser()
			_update_collision_shape()
## Handle updating the laser firing if we are firing 
#func _physics_process(delta: float) -> void:
	#if attack_ray.is_colliding():
		#var collider = attack_ray.get_collider()
		#if collider:
			##print("Collider Name is ", collider.name)
			#if collider.is_in_group("Zombie"):
				#canAttack = true 
			#else:
				#canAttack = false
	#if is_firing:
		#if current_length < max_length:
			#current_length += extension_speed * delta
			#current_length = min(current_length, max_length)
			#_update_laser()
			#_update_collision_shape()
			


func _on_area_exited(area: Area2D) -> void:
	if isDisabled:
		return
	# Allow re-hitting if zombie exits and re-enters
	hit_enemies.erase(area)

func _process_collision(area: Area2D) -> void:
	if isDisabled:
		return
	if "Zombie" in area.name and not hit_enemies.has(area):
		#print("Damaging via signal: ", area.name)
		hit_enemies[area] = true
		var compManager = area.getCompManager()
		
		
func shoot_projectile():
	if isDisabled:
		return
	#print("Shoot Projectile ZZ")
	var projectile
	if isSlowingProjectile:
		
		projectile = projectile_scene.instantiate()
		projectile.isSlow = true 
		
	else:
		projectile = projectile_scene.instantiate()
	projectile.set_damage(damage)
	projectile.global_position = self.global_position
	if isSunBuffed:
		projectile.canGenSun = true 
	#projectile.position = position + Vector2(32, 8)  # Adjust starting position
	get_parent().get_parent().get_parent().add_child(projectile)  # Add the projectile to the game layer
	
	
	
# Fire a new laser 
func fire() -> void:
	if isDisabled:
		return
	#print("FIRE CALLED")
	if attack_ray.is_colliding():
		var collider = attack_ray.get_collider()
		if collider:
			#print("ppp Collider Name is ", collider.name)
			if collider.is_in_group("Zombie") : # &&  collider.get_parent().get_parent() == self.get_parent().get_parent().get_parent().get_parent(): #Dimension Check
				if collider.is_in_group("Green"):
					if self.is_in_group("Purple"):
						return
				elif collider.is_in_group("Purple"):
					if self.is_in_group("Green"):
						return
				if !is_firing:
					#print("ppp Shoot Proj")
					shoot_projectile()
					AudioManager.create_2d_audio_at_location(self.global_position, SoundEffect.SOUND_EFFECT_TYPE.WYRM_FIRE)
					is_firing = true
					current_length = 0.0
					hit_enemies.clear()  # Clear the hit enemies when firing a new laser
					timer.wait_time = duration
					timer.start()
				else:
					pass
					#print("ppp is_firing is ", is_firing)
					

# Update the laser points specifically, also taking into account buffs
func _update_laser() -> void:
	if isDisabled:
		return
	var points = PackedVector2Array()
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
	var rect_shape = collision_shape.shape as RectangleShape2D
	rect_shape.extents = Vector2(current_length / 2, laser_width ) #/2
	collision_shape.position = Vector2(current_length / 2, 0) 




# Stop firing the laser on a cooldown 
func _on_laser_timeout() -> void:
	if isDisabled:
		return
	is_firing = false
	current_length = 0.0
	hit_enemies.clear()  # Clear the hit enemies when the laser times out
	_update_laser()
	_update_collision_shape()
	cooldown_timer.start()


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

# Make the laser more powerful when EggWorm is buffed 
func buff(bufferLocation):
	if isDisabled:
		return
	isBuffed = true
	bufferLocation = to_local(bufferLocation)
	zigzag_position = self.position.x + (bufferLocation.x - 96)
	damage = damage * 2.0

func sunBuff():
	if isDisabled:
		return
	cooldown = sun_buff_cooldown
	cooldown_timer.wait_time = cooldown
	#cooldown = cooldown * 0.5

func unSunBuff():
	if isDisabled:
		return
	cooldown = og_cooldown
	#cooldown = cooldown/2

# getter for buffed status
func getIsBuffed():
	if isDisabled:
		return
	return isBuffed
	
func mawBuff():
	damage = maw_damage
	
	
	
