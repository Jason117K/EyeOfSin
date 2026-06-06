extends Node2D


@onready var shadow := $PreviewCardShadow
var max_offset_shadow : float = 300.0 


func _process(delta: float) -> void:
	handle_shadow(delta)

func handle_shadow(delta : float)->void:
	var center : Vector2 = get_viewport_rect().size / 2.0
	var distance : float = global_position.x - center.x
	shadow.position.x = lerp(0.0,-sign(distance) * max_offset_shadow, abs(distance/(center.x)))
	
