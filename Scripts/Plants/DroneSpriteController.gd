extends AnimatedSprite2D
#DroneSpriteController.gd

#Handles changes to the drone's sprite 

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
