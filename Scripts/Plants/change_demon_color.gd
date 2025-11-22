extends AnimatedSprite2D


#TODO Get Rid of Preload 

var demon_glow = preload("res://Scripts/Plants/Shaders/DemonGlow.gdshader")

@export var targetGlowColor : Color


var currentAnim := "idle"
var currentAttackAnim := "attack"


func _ready() -> void:
	#make_buff_glow()
	pass

func change_form(new_form):
	var parent = get_parent()
	self.animation_finished.connect(parent._on_AnimatedSprite_animation_finished)
	if parent.has_method("adjust_position"):
		parent.adjust_position(new_form)

	match new_form:
		"Sunflower":
			currentAnim = "idle_Sunflower"
			currentAttackAnim = "attack_Sunflower"
			animation = "idle_Sunflower"
		"Peashooter":
			currentAnim = "idle_Spider"
			currentAttackAnim = "attack_Spider"
			if "Sun" in parent.get_name():
				
				$"../Webs".visible = true 
			animation = "idle_Spider"
		"Walnut" :
			currentAnim = "idle_Walnut"
			currentAttackAnim = "attack_Walnut"
			animation = "idle_Walnut"
		"Wyrm":
			currentAnim = "idle_Wyrm"
			currentAttackAnim = "attack_Wyrm"
			animation = "idle_Wyrm"
		"Wasp":
			currentAnim = "idle_Wasp"
			currentAttackAnim = "attack_Wasp"
			animation = "idle_Wasp"
		"Maw":
			currentAnim = "idle_Maw"
			currentAttackAnim = "attack_Maw"
			animation = "idle_Maw"


func make_buff_glow():
	return
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
