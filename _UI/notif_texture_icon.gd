extends TextureRect


@export_range(-180, 180) var hue_shift: float = 0.0:
	set(value):
		hue_shift = clamp(value, -180.0, 180.0)
		_apply_hue_shift()

func _apply_hue_shift() -> void:
	# Update shader parameter
	if material is ShaderMaterial:
		material.set_shader_parameter("hue_shift_degrees", hue_shift)
