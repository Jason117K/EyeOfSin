extends AnimatedSprite2D
#DroneSpriteController.gd


@export_range(-180, 180) var hue_shift: float = -40.0:
	set(value):
		hue_shift = clamp(value, -180.0, 180.0)
		_apply_hue_shift()

var demon_hue_shift = preload("res://Scripts/Plants/Shaders/DemonHueShift.gdshader")

func _apply_hue_shift() -> void:
	# Create material if needed
	if material == null:
		material = ShaderMaterial.new()
		material.shader = demon_hue_shift #preload("res://Scripts/Plants/Shaders/DemonHueShift.gdshader")
	
	# Update shader parameter
	if material is ShaderMaterial:
		material.shader = demon_hue_shift
		material.set_shader_parameter("hue_shift_degrees", hue_shift)

func _ready() -> void:
	#_apply_hue_shift()
	# Ensure updates on animation changes
	#animation_changed.connect(_apply_hue_shift)
	#frame_changed.connect(_apply_hue_shift)
	pass

# Public API methods
func set_hue_shift(degrees: float) -> void:
	hue_shift = clamp(degrees, -180.0, 180.0)

func shift_hue(degrees: float) -> void:
	hue_shift = fmod(hue_shift + degrees, 360.0)
	if hue_shift > 180: hue_shift -= 360
	if hue_shift < -180: hue_shift += 360
		
		
# Returns the length of a given animation for a drone 
func get_animation_length(anim_name: String) -> float:

	if sprite_frames.has_animation(anim_name):
		var frame_count = sprite_frames.get_frame_count(anim_name)
		var frame_rate = sprite_frames.get_animation_speed(anim_name)
		# Don't forget to account for the speed scale if it's been modified
		var this_speed_scale = speed_scale
		return (frame_count / frame_rate) / this_speed_scale
	return 0.0

#Changes drone color to indicate buff 
func buff():
	self_modulate = Color("d91a1a")

func debuff():
	self_modulate = Color("ffffff")
	
