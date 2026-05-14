extends Sprite2D

#TODO Get Rid of Preload 
var demon_glow = preload("res://_Common/Shaders/DemonGlow.gdshader")
@export var targetGlowColor : Color

@onready var shell = $"."
@onready var worm1 = $"../Worm1"
@onready var worm2 = $"../Worm2"
@onready var worm3 = $"../Worm3"


@onready var worm1Animator :=  $"../Worm1Animator"
@onready var worm2Animator :=  $"../Worm2Animator"

var shell_wyrm := preload("res://_Entities/Demons/_Wyrm/Wyrm_PNG/Wyrm_Base_Shell.png")
var shell_hive := preload("res://_Entities/Demons/_Wyrm/Wyrm_PNG/Wyrm_Hive_ShellNoBlood.png")
var shell_spinal_occulum := preload("res://_Entities/Demons/_Wyrm/Wyrm_PNG/Wyrm_SpinalOcculum_Shell.png")
var shell_crawler = preload("res://_Entities/Demons/_Wyrm/Wyrm_PNG/Wyrm_Spider_Shell.png")
var shell_occulum := preload("res://_Entities/Demons/_Wyrm/Wyrm_PNG/Wyrm_Occulum_Shell.png")
var shell_maw := preload("res://_Entities/Demons/_Wyrm/Wyrm_PNG/Wyrm_Maw_Shell.png")
var worm1_wyrm := preload("res://_Entities/Demons/_Wyrm/Wyrm_PNG/Wyrm_Base_Worm1.png")
var worm2_wyrm := preload("res://_Entities/Demons/_Wyrm/Wyrm_PNG/Wyrm_Base_Worm2.png")
var worm1_hive := preload("res://_Entities/Demons/_Wyrm/Wyrm_PNG/Wyrm_Hive_Worm1.png")
var worm2_hive := preload("res://_Entities/Demons/_Wyrm/Wyrm_PNG/Wyrm_Hive_Worm2.png")
var worm3_hive := preload("res://_Entities/Demons/_Wyrm/Wyrm_PNG/Wyrm_Hive_Worm3.png")
var worm1_crawler := preload("res://_Entities/Demons/_Wyrm/Wyrm_PNG/Wyrm_Spider_Worm1.png")
var worm2_crawler := preload("res://_Entities/Demons/_Wyrm/Wyrm_PNG/Wyrm_Spider_Worm2.png")
var worm1_maw := preload("res://_Entities/Demons/_Wyrm/Wyrm_PNG/Wyrm_Maw_Worm.png")
var worm1_occulum := preload("res://_Entities/Demons/_Wyrm/Wyrm_PNG/Wyrm_Occulum_Worm1.png")
var worm1_spinal_occulum := preload("res://_Entities/Demons/_Wyrm/Wyrm_PNG/Wyrm_SpinalOcculum_Worm1.png")
var worm2_spinal_occulum := preload("res://_Entities/Demons/_Wyrm/Wyrm_PNG/Wyrm_SpinalOcculum_Worm2.png")


func _ready() -> void:
	
	pass
func change_form(new_form):
	var parent = get_parent()
	
	if parent.has_method("adjust_position"):
		parent.adjust_position(new_form)
	
	match new_form:
		"Occulum":
			shell.texture = shell_occulum
			worm2.texture = worm1_occulum
			worm2.global_position = worm2.global_position + Vector2(7,-5)
			worm2Animator.initial_sprite_position = worm2Animator.initial_sprite_position  + Vector2(7,-5)
			#worm2.texture = shell_wyrm
			#worm3.texture = shell_wyrm
			worm1.visible = false 
			worm3.visible = false
		"Crawler":
			shell.texture = shell_crawler
			worm1.texture = worm1_crawler
			worm2.texture = worm2_crawler
			worm1Animator.adjustParams(new_form)
			worm2Animator.adjustParams(new_form)
			#worm3.texture = shell_wyrm
			worm3.visible = false
		"SpinalOcculum" :
			shell.texture = shell_spinal_occulum
			worm1.texture = worm1_spinal_occulum
			#worm1.global_position = worm1.global_position + Vector2(-8,3)
			worm1.global_position = worm1.global_position + Vector2(-10,3)
			worm1Animator.initial_sprite_position = worm1Animator.initial_sprite_position  + Vector2(-10,3)
			worm2.texture = worm2_spinal_occulum
		#	worm3.texture = shell_wyrm
			worm2.global_position = worm1.global_position + Vector2(14,-4)
			worm2Animator.initial_sprite_position = worm2Animator.initial_sprite_position  + Vector2(14,-4)
		
			worm3.visible = false
			
		"Wyrm":
			shell.texture = shell_wyrm
			worm1.texture = worm1_wyrm
			worm2.texture = worm2_wyrm
			#worm3.texture = shell_wyrm
			worm3.visible = false
		"Wasp":
			shell.texture = shell_hive
			worm1.texture = worm1_hive
			worm1.global_position = worm1.global_position + Vector2(-8,3)
			worm1Animator.initial_sprite_position = worm1Animator.initial_sprite_position  + Vector2(2,-3)
			worm2.texture = worm2_hive
			worm2.global_position = worm2.global_position + Vector2(-8,3)
			worm2Animator.initial_sprite_position = worm2Animator.initial_sprite_position  + Vector2(2,-3)
			#worm3.texture = worm3_hive
			worm3.visible = false
		"Maw":
			shell.texture = shell_maw
			worm1.texture = worm1_maw
			print("Maw worm global pos is ", worm1.global_position)
			worm1.global_position = worm1.global_position + Vector2(-15,0)
			worm1Animator.initial_sprite_position = worm1Animator.initial_sprite_position  + Vector2(-15,0)
			print("Maw worm global pos is NOW ", worm1.global_position)
			worm1Animator.adjustParams(new_form)
			#worm2.texture = shell_wyrm
			#worm3.texture = shell_wyrm
			worm2.visible = false 
			worm3.visible = false

func make_buff_glow():
	if material == null:
		material = ShaderMaterial.new()
		material.shader = demon_glow #preload("res://Scripts/Demons/Shaders/DemonHueShift.gdshader")
	
	# Update shader parameter
	if material is ShaderMaterial:
		#material.shader = demon_glow
		material.set_shader_parameter("glow_color", targetGlowColor)


func _on_timer_timeout() -> void:
	#make_buff_glow()
	pass
