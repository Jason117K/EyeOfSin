class_name DemonSpriteComp extends AnimatedSprite2D


#TODO Get Rid of Preload 

var demon_glow: Shader = preload("res://_Common/Shaders/DemonGlow.gdshader")

@export var targetGlowColor: Color
@export var modulate_factor: Vector4 = Vector4(7,7,7,1)

@onready var lightning_spawn: AnimatedSprite2D = $"../LightningSpawn"   # $"../LightningSpawn"
#@onready var demon : Demon = get_parent()
var demon: Demon
var currentAnim := "idle"
var currentAttackAnim := "attack"
var spawnAnimDone := false
@onready var current_icon :Texture2D = sprite_frames.get_frame_texture(currentAnim, 0)
var anim_spawn_speed_mult := 1
var default_anim_speed_scale := 1

func _ready() -> void:
	#make_buff_glow()
	if get_parent().is_in_group("Wyrm"):
		pass
	else:
		speed_scale = speed_scale * anim_spawn_speed_mult
		animation = "spawn"
	self.animation_finished.connect(_on_animation_finished)
	#print(self, " PARENT Is " , get_parent())
	demon = get_parent()
	pass

func set_spawn_anim_speed(_new_spawn_anim_speed: float) -> void:
	sprite_frames.set_animation_speed("spawn", 20)


func spawn_done() -> void:
	#print(demon, " spawn done ")
	if spawnAnimDone:
		pass
	else:
		#print("Demon Setting Speed Mult Back to ", default_anim_speed_scale)
		speed_scale = default_anim_speed_scale
		play()
		spawnAnimDone = true
		demon.can_show_preview = true 


func _on_animation_finished() -> void:
	print(self,animation, " Anim Finshed, PARENT Is" , get_parent(), " spawn done is ", spawnAnimDone)
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
		
		
		
func receive_buff(new_form : String) -> void:
	var parent :Demon = get_parent()
	
	if parent.has_method("adjust_position"):
		parent.adjust_position(new_form)
	#print("APPLYING BUFF FROM ",new_form )
	match new_form:
		"Occulum":
			currentAnim = "idle_Occulum"
			currentAttackAnim = "attack_Occulum"
			#animation = "idle_Occulum"
			animation = "spawn"
			current_icon = sprite_frames.get_frame_texture(currentAnim, 0)
		"Crawler":
			currentAnim = "idle_Crawler"
			currentAttackAnim = "attack_Crawler"
			#Refactor
			#if "Occulum" in parent.get_name():
				#
				#$"../Webs".visible = true 
			animation = "spawn"
			current_icon = sprite_frames.get_frame_texture(currentAnim, 0)
		"SpinalOcculum" :
			currentAnim = "idle_SpinalOcculum"
			currentAttackAnim = "attack_SpinalOcculum"
			#animation = "idle_SpinalOcculum"
			animation = "spawn"
			current_icon = sprite_frames.get_frame_texture(currentAnim, 0)
		"Wyrm":
			currentAnim = "idle_Wyrm"
			currentAttackAnim = "attack_Wyrm"
			#animation = "idle_Wyrm"
			animation = "spawn"
			current_icon = sprite_frames.get_frame_texture(currentAnim, 0)
		"Hive":
			currentAnim = "idle_Hive"
			currentAttackAnim = "attack_Hive"
			#animation = "idle_Wasp"
			animation = "spawn"
			current_icon = sprite_frames.get_frame_texture(currentAnim, 0)
		"Maw":
			currentAnim = "idle_Maw"
			currentAttackAnim = "attack_Maw"
			#animation = "idle_Maw"
			animation = "spawn"
			current_icon = sprite_frames.get_frame_texture(currentAnim, 0)
			#if $"../Arm" != null:
				#$"../Arm".visible = true 
				#$"../Arm2".visible = true 


func make_buff_glow() -> void:
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

func make_drone_glow() -> void:
	pass


func debuff() -> void:
	print("Anim Sprite Debuff")
	speed_scale = 1
	currentAnim = "idle"
	currentAttackAnim = "attack"
	animation = currentAnim
	current_icon = sprite_frames.get_frame_texture(currentAnim, 0)
