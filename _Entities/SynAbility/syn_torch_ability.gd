extends Area2D

@onready var torch_anim_sprite := $AnimatedSprite2D

var grid_pos :Vector2
var grid_size: int = 32 

func _ready() -> void:
	grid_pos = mouse_pos_to_grid(global_position)
	self.global_position = grid_pos
	if self.is_in_group("Green"):
		torch_anim_sprite.play("green")

	else:
		torch_anim_sprite.play("purple")
	
func mouse_pos_to_grid(mouse_pos: Vector2) -> Vector2:
	return Vector2(floor(mouse_pos.x / grid_size), floor(mouse_pos.y / grid_size)) * grid_size
