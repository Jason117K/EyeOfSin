extends RichTextLabel

var original_position: Vector2
#var default_shake_intensity: float = 5.0
#var default_shake_duration: float = 0.5

func _ready():
	original_position = position

# Call this function to trigger a shake
func shake(shake_intensity: float = 5.0, shake_duration: float = 0.5):
	var tween = create_tween()
	var elapsed = 0.0
	var step = 0.05   # time between position changes

	while elapsed < shake_duration:
		var offset = Vector2(
			randf_range(-shake_intensity, shake_intensity),
			randf_range(-shake_intensity, shake_intensity)
			)
		tween.tween_property(self, "position", original_position + offset, step)
		elapsed += step
	# Reset position when done
	tween.tween_property(self, "position", original_position, 0.1)
			
			
			
			
			
