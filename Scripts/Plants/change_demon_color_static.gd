extends Sprite2D

#TODO Get Rid of Preload 
var demon_glow = preload("res://Scripts/Plants/Shaders/DemonGlow.gdshader")
@export var targetGlowColor : Color




func _ready() -> void:
	#make_buff_glow()
	pass



func make_buff_glow():
	if material == null:
		material = ShaderMaterial.new()
		material.shader = demon_glow #preload("res://Scripts/Plants/Shaders/DemonHueShift.gdshader")
	
	# Update shader parameter
	if material is ShaderMaterial:
		#material.shader = demon_glow
		material.set_shader_parameter("glow_color", targetGlowColor)


func _on_timer_timeout() -> void:
	#make_buff_glow()
	pass
