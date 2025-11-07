extends AnimatedSprite2D



#TODO Get Rid of Preload 
var demon_glow = preload("res://Scripts/Plants/Shaders/DemonGlow.gdshader")
@export var targetGlowColor : Color




func _ready() -> void:
	#make_buff_glow()
	pass



func make_buff_glow():
	if material == null:
		#print("PRE LOL")
		material = ShaderMaterial.new()
		material.shader = demon_glow #preload("res://Scripts/Plants/Shaders/DemonHueShift.gdshader")
	
	# Update shader parameter
	if material is ShaderMaterial:
		
		#material.shader = demon_glow
		#print("LOL" , material)
		material.set_shader_parameter("glow_color", targetGlowColor)
	else:
		#print("Not funn y LOL ", material)
		pass


func _on_timer_timeout() -> void:
	#make_buff_glow()
	pass

func make_drone_glow():
	pass
