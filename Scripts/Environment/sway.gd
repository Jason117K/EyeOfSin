extends Sprite2D

var sway_shader : VisualShader = preload("res://Scripts/Shaders/swayShader.tres")
var set_shader :bool = false 

func _ready() -> void:
	print(name ," READY ")
	set_sprite_visual_shader(sway_shader)
	set_instance_shader_parameter("RandomStrength", randf_range(-3.0,3.0))
	pass

func make_green():
	self.self_modulate = Color("00ff08")

func set_sprite_visual_shader(new_shader: VisualShader) -> void:
	var newShaderMaterial = ShaderMaterial.new()
	material = newShaderMaterial
	if new_shader:
		newShaderMaterial.shader = new_shader
		print(name, "Shader set successfully")
		set_shader = true
	else:
		push_warning("Attempted to set null shader")

func _physics_process(delta: float) -> void:
	if set_shader:
		return 
	else:
		set_sprite_visual_shader(sway_shader)
		set_instance_shader_parameter("RandomStrength", randf_range(-9.0,9.0))
