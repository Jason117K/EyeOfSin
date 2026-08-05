extends TextureButton
@onready var mat: ShaderMaterial = self.material

# How quickly the hover tilt eases toward its target. Higher = snappier.
const HOVER_SPEED: float = 10.0

# Where the hover effect is easing toward: 1.0 = hovering, 0.0 = not hovering.
var hover_target: float = 0.0

var tween_hover : Tween


func _ready() -> void:
	# Start at rest so the card isn't tilted before the first hover.
#	mat.set_shader_parameter("hovering", 0.0)
	pass

func dim()->void:
	##print("Dim ", self)
	self.self_modulate = Color("8a8a8a")
	
func brighten()->void:
	##print("Brighten ", self)
	self.self_modulate = Color(1,1,1,1)
	


func _on_mouse_entered() -> void: 
	hover_target = 1.0
	if tween_hover and tween_hover.is_running():
		tween_hover.kill()
		
	tween_hover = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)
	tween_hover.tween_property(self,"scale",Vector2(1.05,1.05),0.5)
	
	
func _on_mouse_exited() -> void:  
	hover_target = 0.0
	if tween_hover and tween_hover.is_running():
		tween_hover.kill()	
	tween_hover = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)
	tween_hover.tween_property(self,"scale",Vector2.ONE,0.55)	
	
	
	

func _process(delta: float) -> void:
	# Frame-rate independent ease toward the target. The exp() weight makes the
	# approach speed consistent regardless of frame rate, unlike a fixed lerp.
	var current: float = mat.get_shader_parameter("hovering")
	var weight: float = 1.0 - exp(-HOVER_SPEED * delta)
	mat.set_shader_parameter("hovering", lerp(current, hover_target, weight))

	RenderingServer.global_shader_parameter_set(
		"mouse_screen_pos", get_global_mouse_position()
	)
