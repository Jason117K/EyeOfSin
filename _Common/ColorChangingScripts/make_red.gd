extends AnimatedSprite2D

var thisMaterial

func _ready() -> void:
	pass
	thisMaterial = material.duplicate()
	material = thisMaterial
	# Set initial shader parameters
	if thisMaterial:
		#print("Made h")
		thisMaterial.set_shader_parameter("target_color", Color.WHITE)
		thisMaterial.set_shader_parameter("replace_color", Color.DARK_RED)
		thisMaterial.set_shader_parameter("tolerance", 0.1)
		pass
