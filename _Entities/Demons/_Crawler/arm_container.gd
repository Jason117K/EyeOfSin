extends Node2D
#Controls Arm Movement With Animation 

@onready var anim_sprite_comp : AnimatedSprite2D = $"../AnimatedSpriteComponent"

func _on_animated_sprite_component_frame_changed() -> void:
	if anim_sprite_comp != null:
		var current_frame : int 
		if anim_sprite_comp.animation.contains("Maw"):
			current_frame = anim_sprite_comp.frame
			match current_frame:
				0:
					self.position = Vector2(0,0)
				1:
					self.position = Vector2(1,1)
				2:
					self.position = Vector2(0,1)
				3:
					self.position = Vector2(-1,1)
					
		else:
			return 
