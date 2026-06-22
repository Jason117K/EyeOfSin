extends Sprite2D

var hue_shift_shader := preload("res://_Common/Shaders/DemonHueShift.gdshader")

@export_range(-180, 180) var hue_shift: float = 0.0:
	set(value):
		hue_shift = clamp(value, -180.0, 180.0)
		_apply_hue_shift()

func _apply_hue_shift() -> void:
	# Update shader parameter
	if material == null:
		material = ShaderMaterial.new()
		material.shader = hue_shift_shader 
	if material is ShaderMaterial:
		material.set_shader_parameter("hue_shift_degrees", hue_shift)

func set_hue_shift(degrees: float) -> void:
	hue_shift = clamp(degrees, -180.0, 180.0)
	_apply_hue_shift()
	
