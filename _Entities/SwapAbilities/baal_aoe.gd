extends AnimatedSprite2D

@onready var baal_eye : AnimatedSprite2D = $"../BaalEye"

func _physics_process(delta: float) -> void:
	position = baal_eye.position + Vector2(0,50)
