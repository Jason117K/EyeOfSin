extends AnimatedSprite2D
#DroneSpriteController.gd
var thisMaterial
#Handles changes to the drone's sprite 
@export var isDisabled := false

func _ready() -> void:
	if !isDisabled:
		thisMaterial = material.duplicate()
		material = thisMaterial
		# Set initial shader parameters
		if thisMaterial:
			#print("Made h")
			thisMaterial.set_shader_parameter("target_color", Color("ab3131"))
			thisMaterial.set_shader_parameter("replace_color", Color.HOT_PINK)
			thisMaterial.set_shader_parameter("tolerance", 0.1)
			pass
		
		
# Returns the length of a given animation for a drone 
func get_animation_length(anim_name: String) -> float:

	if sprite_frames.has_animation(anim_name):
		var frame_count = sprite_frames.get_frame_count(anim_name)
		var frame_rate = sprite_frames.get_animation_speed(anim_name)
		# Don't forget to account for the speed scale if it's been modified
		var this_speed_scale = speed_scale
		return (frame_count / frame_rate) / this_speed_scale
	return 0.0

#Changes drone color to indicate buff 
func buff():
	self_modulate = Color("d91a1a")

func debuff():
	self_modulate = Color("ffffff")
	
