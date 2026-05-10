extends AnimatedSprite2D

@export var targetGlowColor : Color = Color("c9000d")
@export_range(-180, 180) var hue_shift: float = -86.0: #25.0
	set(value):
		hue_shift = clamp(value, -180.0, 180.0)
		
var demon_hue_shift = preload("res://_Common/Shaders/DemonHueShift.gdshader")
var original_hue_shift := -86

func _ready() -> void:
	_apply_hue_shift()
	pass
	
	
		
func _apply_hue_shift() -> void:
	# Create material if needed
	if material == null:
		material = ShaderMaterial.new()
		material.shader = demon_hue_shift
	
	# Update shader parameters
	if material is ShaderMaterial:
		material.shader = demon_hue_shift
		material.set_shader_parameter("glow_color", targetGlowColor)
		material.set_shader_parameter("hue_shift_degrees", hue_shift)
		original_hue_shift = hue_shift
	
	# Apply material to this TextureRect so the shader affects every frame
	self.material = material
