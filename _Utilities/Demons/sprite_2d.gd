extends Sprite2D
@onready var mat: ShaderMaterial = self.material

func _on_mouse_entered(): set_hover(1.0)
func _on_mouse_exited():  set_hover(0.0)

func set_hover(target):
	var current = mat.get_shader_parameter("hovering")
	mat.set_shader_parameter("hovering", lerp(current, target, 0.2))
func _process(_delta):
	RenderingServer.global_shader_parameter_set(
		"mouse_screen_pos", get_global_mouse_position()
	)
