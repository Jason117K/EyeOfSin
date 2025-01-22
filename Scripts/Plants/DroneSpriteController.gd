extends AnimatedSprite


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func get_animation_length(anim_name: String) -> float:
	
	if frames.has_animation(anim_name):
		var frame_count = frames.get_frame_count(anim_name)
		var frame_rate = frames.get_animation_speed(anim_name)
		# Don't forget to account for the speed scale if it's been modified
		var speed_scale = speed_scale
		return (frame_count / frame_rate) / speed_scale
	return 0.0

func buff():
	self_modulate = Color("d91a1a")
