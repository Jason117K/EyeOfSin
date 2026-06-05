extends Sprite2D

var set_shader: bool = false
var shader_time := 0.0
var paused := false
var sway_shader

func _ready() -> void:
	print(name ," READY ")
	sway_shader = Global.sway_shader
	set_sprite_visual_shader(sway_shader)
	set_instance_shader_parameter("RandomStrength", randf_range(-3.0,3.0))
	set_physics_process(true)
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
		print(name, " set Shader rr")
	else:
		push_warning("Attempted to set null shader")

func _physics_process(delta: float) -> void:
	if set_shader:
		shader_time += delta
		#print(name, " shader_time=", shader_time)
		material.set_shader_parameter("shader_time", shader_time)
		return
	else:
		print(name, " set Shader pp")
		set_sprite_visual_shader(sway_shader)
		set_instance_shader_parameter("RandomStrength", randf_range(-9.0,9.0))
