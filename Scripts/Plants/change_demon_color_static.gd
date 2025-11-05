extends Sprite2D

@export_range(-180, 180) var hue_shift: float = 0.0: #25.0
	set(value):
		hue_shift = clamp(value, -180.0, 180.0)
		_apply_hue_shift()
var demon_hue_shift = preload("res://Scripts/Plants/Shaders/DemonHueShift.gdshader")

func _apply_hue_shift() -> void:
	# Create material if needed
	if material == null:
		material = ShaderMaterial.new()
		material.shader = preload("res://Scripts/Plants/Shaders/DemonHueShift.gdshader")
		material.set_shader_parameter("hue_shift_degrees", hue_shift)
	
	# Update shader parameter
	if material is ShaderMaterial:
		material.shader = demon_hue_shift
		material.set_shader_parameter("hue_shift_degrees", hue_shift)

func _ready() -> void:
	_apply_hue_shift()
	# Ensure updates on animation changes


# Public API methods
func set_hue_shift(degrees: float) -> void:
	hue_shift = clamp(degrees, -180.0, 180.0)

func shift_hue(degrees: float) -> void:
	hue_shift = fmod(hue_shift + degrees, 360.0)
	if hue_shift > 180: hue_shift -= 360
	if hue_shift < -180: hue_shift += 360
