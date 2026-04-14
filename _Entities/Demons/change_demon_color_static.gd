extends Sprite2D

#TODO Get Rid of Preload 
var demon_glow = preload("res://Scripts/Plants/Shaders/DemonGlow.gdshader")
@export var targetGlowColor : Color

@onready var shell = $"."
@onready var worm1 = $"../Worm1"
@onready var worm2 = $"../Worm2"
@onready var worm3 = $"../Worm3"


@onready var worm1Animator :=  $"../Worm1Animator"
@onready var worm2Animator :=  $"../Worm2Animator"

var shell_wyrm := preload("res://Assets/Demons/Wyrm_PNG/Wyrm_Base_Shell.png")
var shell_hive := preload("res://Assets/Demons/Wyrm_PNG/Wyrm_Hive_ShellNoBlood.png")
var shell_walnut := preload("res://Assets/Demons/Wyrm_PNG/Wyrm_Walnut_Shell.png")
var shell_spider = preload("res://Assets/Demons/Wyrm_PNG/Wyrm_Spider_Shell.png")
var shell_sun := preload("res://Assets/Demons/Wyrm_PNG/Wyrm_Sun_Shell.png")
var shell_maw := preload("res://Assets/Demons/Wyrm_PNG/Wyrm_Maw_Shell.png")
var worm1_wyrm := preload("res://Assets/Demons/Wyrm_PNG/Wyrm_Base_Worm1.png")
var worm2_wyrm := preload("res://Assets/Demons/Wyrm_PNG/Wyrm_Base_Worm2.png")
var worm1_hive := preload("res://Assets/Demons/Wyrm_PNG/Wyrm_Hive_Worm1.png")
var worm2_hive := preload("res://Assets/Demons/Wyrm_PNG/Wyrm_Hive_Worm2.png")
var worm3_hive := preload("res://Assets/Demons/Wyrm_PNG/Wyrm_Hive_Worm3.png")
var worm1_spider := preload("res://Assets/Demons/Wyrm_PNG/Wyrm_Spider_Worm1.png")
var worm2_spider := preload("res://Assets/Demons/Wyrm_PNG/Wyrm_Spider_Worm2.png")
var worm1_maw := preload("res://Assets/Demons/Wyrm_PNG/Wyrm_Maw_Worm.png")
var worm1_sun := preload("res://Assets/Demons/Wyrm_PNG/Wyrm_Sun_Worm1.png")
var worm1_walnut := preload("res://Assets/Demons/Wyrm_PNG/Wyrm_Walnut_Worm1.png")
var worm2_walnut := preload("res://Assets/Demons/Wyrm_PNG/Wyrm_Walnut_Worm2.png")


func _ready() -> void:
	
	pass
func change_form(new_form):
	var parent = get_parent()
	
	if parent.has_method("adjust_position"):
		parent.adjust_position(new_form)
	
	match new_form:
		"Sunflower":
			shell.texture = shell_sun
			worm2.texture = worm1_sun
			worm2.global_position = worm2.global_position + Vector2(7,-5)
			worm2Animator.initial_sprite_position = worm2Animator.initial_sprite_position  + Vector2(7,-5)
			#worm2.texture = shell_wyrm
			#worm3.texture = shell_wyrm
			worm1.visible = false 
			worm3.visible = false
		"Peashooter":
			shell.texture = shell_spider
			worm1.texture = worm1_spider
			worm2.texture = worm2_spider
			worm1Animator.adjustParams(new_form)
			worm2Animator.adjustParams(new_form)
			#worm3.texture = shell_wyrm
			worm3.visible = false
		"Walnut" :
			shell.texture = shell_walnut
			worm1.texture = worm1_walnut
			#worm1.global_position = worm1.global_position + Vector2(-8,3)
			worm1.global_position = worm1.global_position + Vector2(-10,3)
			worm1Animator.initial_sprite_position = worm1Animator.initial_sprite_position  + Vector2(-10,3)
			worm2.texture = worm2_walnut
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
			print("global pos is ", worm1.global_position)
			worm1.global_position = worm1.global_position + Vector2(-15,0)
			worm1Animator.initial_sprite_position = worm1Animator.initial_sprite_position  + Vector2(-15,0)
			print("global pos is NOW ", worm1.global_position)
			worm1Animator.adjustParams(new_form)
			#worm2.texture = shell_wyrm
			#worm3.texture = shell_wyrm
			worm2.visible = false 
			worm3.visible = false

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
