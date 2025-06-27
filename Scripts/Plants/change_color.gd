extends AnimatedSprite2D

var thisMaterial

@export var targetColorString := "ff0013"
@export var isDisabled := true

func _ready() -> void:
	if !isDisabled:
		self.connect("animation_changed",_on_animation_changed)
		thisMaterial = material.duplicate()
		material = thisMaterial
		# Set initial shader parameters
		if thisMaterial:
			#print("Made h")
			thisMaterial.set_shader_parameter("target_color", Color("ff0013"))
			thisMaterial.set_shader_parameter("replace_color", Color.HOT_PINK)
			thisMaterial.set_shader_parameter("tolerance", 0.1)
			pass
#ff0013


func _on_animation_changed() -> void:
	if thisMaterial:
		print("Made PPInk")
		thisMaterial.set_shader_parameter("target_color", Color(targetColorString))
		thisMaterial.set_shader_parameter("replace_color", Color.DEEP_PINK)
		thisMaterial.set_shader_parameter("tolerance", 0.35)
		
	if "Hive" in get_parent().name:
		thisMaterial.set_shader_parameter("target_color", Color("371616"))
		thisMaterial.set_shader_parameter("replace_color", Color.DEEP_PINK)
		thisMaterial.set_shader_parameter("tolerance", 0.5)
		
		thisMaterial.set_shader_parameter("target_color", Color("2a1212"))
		thisMaterial.set_shader_parameter("replace_color", Color.DEEP_PINK)
		thisMaterial.set_shader_parameter("tolerance", 0.99)		
		
		thisMaterial.set_shader_parameter("target_color", Color(targetColorString))
		thisMaterial.set_shader_parameter("replace_color", Color.DEEP_PINK)
		thisMaterial.set_shader_parameter("tolerance", 0.35)


func _on_frame_changed() -> void:
	if !isDisabled:
		if "Hive" in get_parent().name:
			thisMaterial.set_shader_parameter("target_color", Color("371616"))
			thisMaterial.set_shader_parameter("replace_color", Color.DEEP_PINK)
			thisMaterial.set_shader_parameter("tolerance", 0.00)
			
			thisMaterial.set_shader_parameter("target_color", Color("2a1212"))
			thisMaterial.set_shader_parameter("replace_color", Color.DEEP_PINK)
			thisMaterial.set_shader_parameter("tolerance", 0.00)		
			
			thisMaterial.set_shader_parameter("target_color", Color(targetColorString))
			thisMaterial.set_shader_parameter("replace_color", Color.DEEP_PINK)
			thisMaterial.set_shader_parameter("tolerance", 0.5)
