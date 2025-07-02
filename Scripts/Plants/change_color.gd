extends AnimatedSprite2D

var thisMaterial

@export var targetColorString := "ff0013"
@export var replaceColorString := "ff0013"
@export var target_color : Color 
@export var replace_color : Color 
@export var isDisabled := true

var isAlt := false

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
			thisMaterial.set_shader_parameter("tolerance", 0.2)
		if "Tree" in get_parent().name:
			print("GG Color Change AGaIn",targetColorString, " ", replaceColorString)
			thisMaterial.set_shader_parameter("target_color", target_color) #Color("#272727"))
			#thisMaterial.set_shader_parameter("replace_color", replaceColorString)
			thisMaterial.set_shader_parameter("replace_color", replace_color)
			thisMaterial.set_shader_parameter("tolerance", 0.1)			
		if "Maw" in get_parent().name:
			if isAlt:
				print("GG Maw Color Change")
				thisMaterial.set_shader_parameter("target_color", target_color)
				thisMaterial.set_shader_parameter("replace_color", replace_color)
				thisMaterial.set_shader_parameter("tolerance", 0.1)
			else:
				print("GG Maw Color Change")
				thisMaterial.set_shader_parameter("target_color", Color.WHITE)
				thisMaterial.set_shader_parameter("replace_color", Color.DARK_RED)
				thisMaterial.set_shader_parameter("tolerance", 0.1)
		else:
			pass
			#print("GG : ", get_parent().name)
	else:
		pass
		#print("GGG NOT DISABLED ")
		
func change_color():
	isDisabled = false
	thisMaterial = material.duplicate()
	material = thisMaterial
	if thisMaterial:
		print("Made COLOR CHANGGE")
		thisMaterial.set_shader_parameter("target_color", targetColorString) #Color("#272727"))
		thisMaterial.set_shader_parameter("replace_color", replaceColorString)
		thisMaterial.set_shader_parameter("tolerance", 0.1)
		
func change_color_specific(new_target_color, new_replace_color):
	target_color = new_target_color
	replace_color = new_replace_color
	isDisabled = false
	thisMaterial = material.duplicate()
	material = thisMaterial
	isAlt = true
	if thisMaterial:
		print("Made COLOR CHANGGE")
		thisMaterial.set_shader_parameter("target_color", targetColorString) #Color("#272727"))
		thisMaterial.set_shader_parameter("replace_color", replaceColorString)
		thisMaterial.set_shader_parameter("tolerance", 0.1)
		
		
		
		
		
		
		
		
		
		
		
		
		
		
