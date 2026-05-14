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
signal frame_changed_signal(animation_name: String, frame_index: int)


func _ready() -> void:
	#make_buff_glow()
	if get_parent().is_in_group("Wyrm"):
		pass
	else:
		animation = "spawn"
	self.animation_finished.connect(_on_animation_finished)
	#print(self, " PARENT Is " , get_parent())
	demon = get_parent()
	pass
	
func spawn_done():
	if spawnAnimDone:
		pass
	else:
		spawnAnimDone = true 
		
		
func _on_animation_finished():
	#print(self, "PARENT Is" , get_parent())
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
	
	if parent.has_method("adjust_position"):
		parent.adjust_position(new_form)

	match new_form:
		"Occulum":
			currentAnim = "idle_Occulum"
			currentAttackAnim = "attack_Occulum"
			#animation = "idle_Occulum"
			animation = "spawn"
		"Crawler":
			currentAnim = "idle_Crawler"
			currentAttackAnim = "attack_Crawler"
			#Refactor
			#if "Occulum" in parent.get_name():
				#
				#$"../Webs".visible = true 
			animation = "spawn"
		"SpinalOcculum" :
			currentAnim = "idle_SpinalOcculum"
			currentAttackAnim = "attack_SpinalOcculum"
			#animation = "idle_SpinalOcculum"
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
		material.shader = demon_glow #preload("res://Scripts/Demons/Shaders/DemonHueShift.gdshader")
	
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
	
	
func debuff():
	speed_scale = 1
