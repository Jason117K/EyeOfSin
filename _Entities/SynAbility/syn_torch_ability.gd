extends Syn_Ability_Instance

@export var enflame_damage_mult := 2.0 

@onready var torch_anim_sprite := $AnimatedSprite2D



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
	# Base lifecycle: registers for pairing and starts the death timer. Without it
	# the Shroomie never expired and its dimension's Syn charge stayed ACTIVE.
	super()


# True while the other dimension's Shroomie is up (the pair stands).
var is_paired := false
var linked_zombies : Array = []

func enflame_projectile(projectile_to_enflame : Area2D)->void:
	if projectile_to_enflame.is_in_group("DemonProjectile"):
		projectile_to_enflame.enflame(enflame_damage_mult, self)

func connect_ability(_other_shroom : Area2D)->void:
	is_paired = true

func register_linked_zombie(zombie : Area2D)->void:
	if not zombie in linked_zombies:
		linked_zombies.append(zombie)

# The pair ended (partner expired): links made through it end too.
func disconnect_ability(_departed_partner : Area2D)->void:
	_end_links()

func stop_ability()->void:
	_end_links()
	super()

# A zombie still Syn-marked keeps its fire: the mark's own expiry clears it.
func _end_links()->void:
	is_paired = false
	for zombie in linked_zombies:
		if is_instance_valid(zombie) and not zombie.is_dead and zombie.is_flame_dmg_linked and not zombie.is_syn_marked:
			zombie.set_off_fire()
	linked_zombies.clear()
	
func mouse_pos_to_grid(mouse_pos: Vector2) -> Vector2:
	return Vector2(floor(mouse_pos.x / grid_size), floor(mouse_pos.y / grid_size)) * grid_size

func get_icon()->Texture:
	return Global.shroomie_button_icon
	
	
	
	
