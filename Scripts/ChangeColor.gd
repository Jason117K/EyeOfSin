extends AnimatedSprite2D

@export var target_color : Color 
@export var replace_color : Color 
@export var tolerance := 0.1
var thisMaterial

func _ready() -> void:
	pass
	thisMaterial = material.duplicate()
	material = thisMaterial
	# Set initial shader parameters
	if thisMaterial:
		#print("Made h")
		thisMaterial.set_shader_parameter("target_color", target_color) #Color("#272727"))
		thisMaterial.set_shader_parameter("replace_color", replace_color)
		thisMaterial.set_shader_parameter("tolerance", 0.1)
		pass
