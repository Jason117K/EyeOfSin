extends Sprite2D

var sway_shader: VisualShader = preload("res://_Common/Shaders/swayShader.tres")
var set_shader: bool = false
var shader_time := 0.0
var paused := false

func _ready() -> void:
	#print(name ," READY ")
	set_sprite_visual_shader(sway_shader)
	set_instance_shader_parameter("RandomStrength", randf_range(-3.0,3.0))
	pass

func make_green() -> void:
	self.self_modulate = Color("00ff08")

func set_sprite_visual_shader(new_shader: VisualShader) -> void:
	var newShaderMaterial := ShaderMaterial.new()
	material = newShaderMaterial
	if new_shader:
		newShaderMaterial.shader = new_shader
		#print(name, "Shader set successfully")
		set_shader = true
	else:
		push_warning("Attempted to set null shader")

func _physics_process(delta: float) -> void:
	if set_shader:
		shader_time += delta
		material.set_shader_parameter("shader_time", shader_time)
		return
	else:
		set_sprite_visual_shader(sway_shader)
		set_instance_shader_parameter("RandomStrength", randf_range(-9.0,9.0))
