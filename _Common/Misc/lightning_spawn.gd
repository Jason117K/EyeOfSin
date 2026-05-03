extends AnimatedSprite2D

#@onready var animatedSprite = $"../AnimatedSprite2D"

func _ready() -> void:
	animation = "default"

func _on_animation_finished() -> void:
	#animatedSprite.finish_spawn()
	self.visible = false




func _on_frame_changed() -> void:
	#print("Frame is ", frame)
	if frame == 2:
		#print("Frame is ", frame)
		get_parent().finish_spawn()
