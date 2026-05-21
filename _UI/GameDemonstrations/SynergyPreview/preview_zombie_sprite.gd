extends AnimatedSprite2D


@export var targetGlowColor : Color = Color("df4242")
@export_range(-180, 180) var hue_shift: float = -86.0: #25.0
	set(value):
		hue_shift = clamp(value, -180.0, 180.0)
		#print(hue_shift,"Apply HUE Shift ", count)
		_apply_hue_shift()
var demon_hue_shift = preload("res://_Common/Shaders/DemonHueShift.gdshader")


func _ready() -> void:
	print(self, " is now readyyyyyyyyyyyyyyyyyyyyyyyyy")
	_apply_hue_shift()

func _apply_hue_shift() -> void:
	print("Apply Hue Shift ")
	
	# Create material if needed
	if material == null:
		material = ShaderMaterial.new()
		material.shader = demon_hue_shift #preload("res://Scripts/Demons/Shaders/DemonHueShift.gdshader")
	
	# Update shader parameter
	if material is ShaderMaterial:
		material.shader = demon_hue_shift
		material.set_shader_parameter("glow_color", targetGlowColor)
		material.set_shader_parameter("hue_shift_degrees", hue_shift)

		
		
		
