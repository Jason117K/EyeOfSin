extends Node2D
# ShootComponent.gd

# Handles Shooting the Wyrm Laser
#Red Color : b00000
#Magenta : b00075
# Configuration parameters
var laser_color: Color = Color(1.0, 0.0, 0.0, 1.0)
var extension_speed: float = 1000.0
var ogExtension_Speed: float

var max_length: float = 250
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
#@export var zigzag_height: float = 50.0  # Height of the zigzag
#@export var zigzag_position: float = 300.0  # Fixed screen position where zigzag occurs
#@export var zigzag_width: float = 100.0  # Width of the zigzag section

@export_group("Beam Visual")
## Colors across the beam's width. Leave empty for laser_color → white → laser_color.
@export var beam_gradient: Gradient
@export_range(0.0, 1.0, 0.01) var glow_intensity := 0.35
## Pixels the glow extends past each side of the beam.
@export_range(0, 8, 1) var glow_width := 2
## Colors past a Shroomie, which already doubles the Wyrm's damage.
## Leave empty for laser_color → pink-red → laser_color.
@export var enflamed_beam_gradient: Gradient

const SYN_TORCH_GROUP := &"SynTorch"
const ENFLAMED_CORE_WHITENESS := 0.45

# The lines render inside a SubViewport so they're drawn at game-pixel resolution, like the tentacles.
const VIEWPORT_PADDING := 2
# Odd, so a texel sits exactly on the beam's center line.
const GRADIENT_TEXTURE_HEIGHT := 33

# Node references
@onready var pixel_viewport: SubViewportContainer = $PixelViewport
@onready var sub_viewport: SubViewport = $PixelViewport/SubViewport
@onready var glow_line: Line2D = $PixelViewport/SubViewport/GlowLine
@onready var line2D: Line2D = $PixelViewport/SubViewport/BeamLine
@onready var enflamed_line: Line2D = $PixelViewport/SubViewport/EnflamedBeamLine
var blood_spit_fx #:= $"../../Worm2/BloodSpitFX"
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
	blood_spit_fx =get_node_or_null("../../BloodSpitFX")
	attack_ray =get_node_or_null("../../DMG_RayCast2D")
	projectile_shoot_component = get_node_or_null("../../ProjectileShootComponent")
	
	
	demon = _find_demon_ancestor()
	if demon:
		laser_color = demon.laser_color
		extension_speed = demon.extension_speed
		max_length = demon.max_length
		laser_width = demon.laser_width
		damage = demon.projectile_damage
		maw_damage = demon.maw_damage
		duration = demon.duration
		auto_fire = demon.laser_auto_fire
		cooldown = demon.laser_cooldown
		blood_buff_cooldown = demon.blood_buff_cooldown

	ogExtension_Speed = extension_speed
	ogMax_Length = max_length

	if isDisabled:
		return
	_setup_laser()

## Turns on a laser that started disabled (Wyrm/Hive buffs). Use this rather
## than calling _ready() again, which re-runs the one-time setup.
func enable() -> void:
	isDisabled = false
	_setup_laser()

func _setup_laser() -> void:
	if timer.get_parent() != null:
		return # already set up
	og_cooldown = cooldown
	og_damage = damage
	#self.visible = false
	for line: Line2D in [glow_line, line2D, enflamed_line]:
		line.points = PackedVector2Array([Vector2.ZERO, Vector2(100, 0)])
		line.default_color = Color.WHITE
		line.texture_mode = Line2D.LINE_TEXTURE_STRETCH
		line.begin_cap_mode = Line2D.LINE_CAP_ROUND
		line.end_cap_mode = Line2D.LINE_CAP_ROUND
	enflamed_line.begin_cap_mode = Line2D.LINE_CAP_NONE
	_apply_beam_style()
	_fit_viewport()

	# Set up Area2D and CollisionShape2D
	#add_child(laser_area)
	#laser_area.add_child(collision_shape)
	#laser_area.collision_mask = 2
	#var shape := RectangleShape2D.new()
	#collision_shape.shape = shape
	
	#Set up debug marker
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
		#print("Is Firing, Current Length is ", current_length, " max length is ", max_length)
		if current_length < max_length:
			current_length += extension_speed * delta
			current_length = min(current_length, max_length)
			_update_laser()
			_update_collision_shape()
		_update_enflamed_segment()

# Shroomies can appear or expire mid-beam, so this runs every frame while firing.
func _update_enflamed_segment() -> void:
	var enflame_x := _find_enflame_x()
	if enflame_x >= current_length:
		enflamed_line.hide()
		return
	enflamed_line.points = PackedVector2Array([Vector2(enflame_x, 0), Vector2(current_length, 0)])
	enflamed_line.show()

# Local x where this beam first enters a same-dimension Shroomie, or INF if it never does.
func _find_enflame_x() -> float:
	var dimension := "Green" if demon != null and demon.is_in_group("Green") else "Purple"
	var nearest := INF
	for torch in get_tree().get_nodes_in_group(SYN_TORCH_GROUP):
		if not torch.is_in_group(dimension):
			continue
		var flame_rect: Rect2 = torch.get_global_flame_rect()
		if global_position.y < flame_rect.position.y or global_position.y > flame_rect.end.y:
			continue
		var right_x := to_local(Vector2(flame_rect.end.x, global_position.y)).x
		if right_x <= 0.0:
			continue
		var left_x := to_local(Vector2(flame_rect.position.x, global_position.y)).x
		nearest = minf(nearest, maxf(roundf(left_x), 0.0))
	return nearest

func _on_area_exited(area: Area2D) -> void:
	if isDisabled:
		return
	# Allow re-hitting if zombie exits and re-enters
	hit_enemies.erase(area)

func _process_collision(area: Area2D) -> void:
	if isDisabled:
		return
	if "Zombie" in area.name and not hit_enemies.has(area):
		##print("Damaging via signal: ", area.name)
		hit_enemies[area] = true


	
# Fire a new laser 
func fire() -> void:
	if isDisabled:
		return
	else:
		pass
		##print("Not Disabled are we Firing?")
	if !is_firing:
		_fit_viewport()
		pixel_viewport.show()
	#	#print("Not Firing No Return Cos Diabled Do Sutff")
		AudioManager.create_2d_audio_at_location(self.global_position, SoundEffect.SOUND_EFFECT_TYPE.WYRM_FIRE)
		is_firing = true
		current_length = 0.0
		hit_enemies.clear()  # Clear the hit enemies when firing a new laser
		#timer.wait_time = duration
		done_firing = false
		timer.wait_time = (max_length / extension_speed) + duration
		timer.start()
		if blood_spit_fx != null:
			blood_spit_fx.play("blood_spit")
	else:
	#	#print("We are not firing")
		pass

# Update the laser points specifically, also taking into account buffs
func _update_laser() -> void:
	if isDisabled:
		return
	var points := PackedVector2Array()
	points.append(Vector2.ZERO)  # Starting point
		
	points.append(Vector2(current_length, 0))

	line2D.points = points
	glow_line.points = points

# Updates the laser's collision specifically 
func _update_collision_shape() -> void:
	if isDisabled:
		return
	# Update collision shape to follow the laser path
	#var rect_shape := collision_shape.shape as RectangleShape2D
	#rect_shape.extents = Vector2(current_length / 2, laser_width ) #/2
	#collision_shape.position = Vector2(current_length / 2, 0) 
#



# Stop firing the laser on a cooldown 
func _on_laser_timeout() -> void:
	if isDisabled:
		##print("We are diasabled return")
		return
	##print("No Return Make Length 0")
	is_firing = false
	current_length = 0.0
	hit_enemies.clear()  # Clear the hit enemies when the laser times out
	_update_laser()
	_update_collision_shape()
	pixel_viewport.hide()
	enflamed_line.hide()
	done_firing = true
	#cooldown_timer.start()


# Set the laser color 
func set_laser_color(color: Color) -> void:
	if isDisabled:
		return
	laser_color = color
	_apply_beam_style()

# Set the laser width
func set_laser_width(width: float) -> void:
	if isDisabled:
		return
	laser_width = width
	_apply_beam_style()
	_fit_viewport()

func _apply_beam_style() -> void:
	line2D.width = laser_width
	line2D.texture = _make_cross_section_texture(beam_gradient if beam_gradient else _default_beam_gradient())
	glow_line.width = laser_width + glow_width * 2
	glow_line.texture = _make_cross_section_texture(_glow_gradient())
	enflamed_line.width = laser_width
	enflamed_line.texture = _make_cross_section_texture(enflamed_beam_gradient if enflamed_beam_gradient else _default_enflamed_gradient())

func _default_beam_gradient() -> Gradient:
	return _edge_to_core_gradient(Color.WHITE)

func _default_enflamed_gradient() -> Gradient:
	return _edge_to_core_gradient(laser_color.lerp(Color.WHITE, ENFLAMED_CORE_WHITENESS))

# Edges stay laser_color out to a third of the width, so a 3px beam is edge / core / edge.
func _edge_to_core_gradient(core_color: Color) -> Gradient:
	var gradient := Gradient.new()
	gradient.offsets = PackedFloat32Array([0.0, 0.33, 0.5, 0.67, 1.0])
	gradient.colors = PackedColorArray([laser_color, laser_color, core_color, laser_color, laser_color])
	return gradient

func _glow_gradient() -> Gradient:
	var edge := Color(laser_color, 0.0)
	var gradient := Gradient.new()
	gradient.offsets = PackedFloat32Array([0.0, 0.5, 1.0])
	gradient.colors = PackedColorArray([edge, Color(laser_color, glow_intensity), edge])
	return gradient

# A Line2D maps its texture's vertical axis across the line's width.
func _make_cross_section_texture(gradient: Gradient) -> GradientTexture2D:
	var texture := GradientTexture2D.new()
	texture.gradient = gradient
	texture.width = 1
	texture.height = GRADIENT_TEXTURE_HEIGHT
	texture.fill_from = Vector2(0, 0)
	texture.fill_to = Vector2(0, 1)
	return texture

# Sizes the viewport to the beam plus its glow, keeping the beam's start on this node's origin.
# The lines are centered at height / 2.0 so odd widths fill whole pixel rows, and the viewport
# itself stays on whole pixels so beam pixels land on the game's pixel grid.
func _fit_viewport() -> void:
	var padding := VIEWPORT_PADDING + glow_width
	sub_viewport.size = Vector2i(ceili(max_length), ceili(laser_width)) + Vector2i.ONE * padding * 2
	var line_origin := Vector2(padding, sub_viewport.size.y / 2.0)
	line2D.position = line_origin
	glow_line.position = line_origin
	enflamed_line.position = line_origin
	pixel_viewport.size = sub_viewport.size
	pixel_viewport.position = -Vector2(padding, floorf(line_origin.y))

# Make the laser more powerful when Wyrm is buffed 
func buff(bufferLocation:Vector2) -> void:
	if isDisabled:
		return
	isBuffed = true
	bufferLocation = to_local(bufferLocation)
	
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
	
func debuff()->void:
	unOcculumBuff()
	damage = og_damage
	
