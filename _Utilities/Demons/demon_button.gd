extends TextureButton
@onready var mat: ShaderMaterial = self.material

func _on_mouse_entered()->void: set_hover(1.0)
func _on_mouse_exited()->void:  set_hover(0.0)

func set_hover(target:float)->void:
	var current :float = mat.get_shader_parameter("hovering")
	mat.set_shader_parameter("hovering", lerp(current, target, 0.2))
	
	
	
func _process(_delta:float)->void:
	RenderingServer.global_shader_parameter_set(
		"mouse_screen_pos", get_global_mouse_position()
	)
