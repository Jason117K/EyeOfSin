extends AnimatedSprite2D

var thisMaterial

func _ready() -> void:
	pass
	thisMaterial = material.duplicate()
	material = thisMaterial
	# Set initial shader parameters
	if thisMaterial:
		#print("Made h")
		thisMaterial.set_shader_parameter("target_color", Color.WHITE) #Color("#272727"))
		thisMaterial.set_shader_parameter("replace_color", Color.CRIMSON)
		thisMaterial.set_shader_parameter("tolerance", 0.1)
		pass
