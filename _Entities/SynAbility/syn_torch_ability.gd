extends Area2D

@export var enflame_damage_mult := 2.0 

@onready var torch_anim_sprite := $AnimatedSprite2D

var grid_pos :Vector2
var grid_size: int = 32 

func _ready() -> void:
	if self.is_in_group("Green"):
		self.set_collision_mask_value(1,false)
		self.set_collision_mask_value(2,false)
		self.set_collision_mask_value(3,true)
		torch_anim_sprite.play("green")

	else:
		self.set_collision_mask_value(1,false)
		self.set_collision_mask_value(2,true)
		self.set_collision_mask_value(3,false)
		torch_anim_sprite.play("purple")
		
	grid_pos = mouse_pos_to_grid(global_position)
	self.global_position = grid_pos
		
	self.area_entered.connect(enflame_projectile)
	
	
func enflame_projectile(projectile_to_enflame : Area2D)->void:
	if projectile_to_enflame.is_in_group("DemonProjectile"):
		projectile_to_enflame.enflame(enflame_damage_mult)
	
func mouse_pos_to_grid(mouse_pos: Vector2) -> Vector2:
	return Vector2(floor(mouse_pos.x / grid_size), floor(mouse_pos.y / grid_size)) * grid_size
