class_name DemonSpriteComp extends AnimatedSprite2D


#TODO Get Rid of Preload 

var demon_glow = preload("res://_Common/Shaders/DemonGlow.gdshader")

@export var targetGlowColor : Color
@export var modulate_factor : Vector4 = Vector4(7,7,7,1)

@onready var lightning_spawn := $"../LightningSpawn"   # $"../LightningSpawn"
#@onready var demon : Demon = get_parent()
var demon : Demon

var currentAnim := "idle"
var currentAttackAnim := "attack"
var spawnAnimDone = false


func _ready() -> void:
	#make_buff_glow()
	self.animation_finished.connect(_on_animation_finished)
	print(self, "PARENT Is" , get_parent())
	demon = get_parent()
	pass
	
func spawn_done():
	if spawnAnimDone:
		pass
	else:
		spawnAnimDone = true 
		
		
func _on_animation_finished():
	print(self, "PARENT Is" , get_parent())
	if animation == "spawn":
		if spawnAnimDone:
			lightning_spawn.animation = "change_form"
		lightning_spawn.show()
		lightning_spawn.play()
		visible = false
		spawn_done()
	else:
		animation = currentAnim
		play()
		
		
		
func change_form(new_form):
	var parent = get_parent()
	self.animation_finished.connect(parent._on_AnimatedSprite_animation_finished)
	if parent.has_method("adjust_position"):
		parent.adjust_position(new_form)

	match new_form:
		"Sunflower":
			currentAnim = "idle_Sunflower"
			currentAttackAnim = "attack_Sunflower"
			#animation = "idle_Sunflower"
			animation = "spawn"
		"Peashooter":
			currentAnim = "idle_Spider"
			currentAttackAnim = "attack_Spider"
			if "Sun" in parent.get_name():
				
				$"../Webs".visible = true 
			#animation = "idle_Spider"
			animation = "spawn"
		"Walnut" :
			currentAnim = "idle_Walnut"
			currentAttackAnim = "attack_Walnut"
			#animation = "idle_Walnut"
			animation = "spawn"
		"Wyrm":
			currentAnim = "idle_Wyrm"
			currentAttackAnim = "attack_Wyrm"
			#animation = "idle_Wyrm"
			animation = "spawn"
		"Wasp":
			currentAnim = "idle_Wasp"
			currentAttackAnim = "attack_Wasp"
			#animation = "idle_Wasp"
			animation = "spawn"
		"Maw":
			currentAnim = "idle_Maw"
			currentAttackAnim = "attack_Maw"
			#animation = "idle_Maw"
			animation = "spawn"
			if $"../Arm" != null:
				$"../Arm".visible = true 
				$"../Arm2".visible = true 


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


func _on_timer_timeout() -> void:
	#make_buff_glow()
	pass

func make_drone_glow():
	pass
