extends AnimatedSprite2D

var demon_glow = preload("res://_Common/Shaders/DemonGlow.gdshader")
@export var targetGlowColor : Color
@export var modulate_factor : Vector4 = Vector4(7,7,7,1)

func make_buff_glow():
	#return
	if material == null:
		print("PRE LOL")
		material = ShaderMaterial.new()
		material.shader = demon_glow #preload("res://Scripts/Plants/Shaders/DemonHueShift.gdshader")
	
	# Update shader parameter
	if material is ShaderMaterial:
		
		#material.shader = demon_glow
		print("LOL" , material)
		material.set_shader_parameter("glow_color", targetGlowColor)
		material.set_shader_parameter("modulate_factor", modulate_factor)
	else:
		#print("Not funn y LOL ", material)
		pass
