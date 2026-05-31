class_name Syn_Ability_Instance extends Area2D

@export var ability_duration :float= 20 
@export var ability_cooldown_duration : float = 20
@onready var death_timer :Timer #= $DeathTimer

var is_dual_connection := true 
var ability_primary_visual_instance : AnimatedSprite2D
var grid_pos :Vector2
var grid_size: int = 32 
var detect_demons := false
var detect_zombies := false 
var syn_controller : Node 

func _ready() -> void:
	grid_pos = mouse_pos_to_grid(global_position)
	death_timer = Timer.new()
	death_timer.timeout.connect(stop_ability)
	death_timer.wait_time = ability_duration
	death_timer.one_shot = true 
	death_timer.autostart = false
	add_child(death_timer)

	
	
	
	if detect_demons:
		set_detect_demons(self)
	if detect_zombies:
		set_detect_zombies(self)
		
	await get_tree().physics_frame
	await get_tree().physics_frame
	await get_tree().physics_frame	
	
	activate_ability()
	Global.register_syn_ability(self)
	death_timer.start()
	
func activate_ability()->void:
	pass
	

				
func stop_ability()->void:
	Global.deregister_syn_ability(self)
	syn_controller.deregister_ability_instance(self)
	queue_free()
	
func connect_abilities(_syn_ability_to_connect: Area2D) -> void:
	pass
	
	
func mouse_pos_to_grid(mouse_pos: Vector2) -> Vector2:
	return Vector2(floor(mouse_pos.x / grid_size), floor(mouse_pos.y / grid_size)) * grid_size

func set_detect_zombies(area_to_set:Area2D)->void:
	if self.is_in_group("Green"):
		area_to_set.set_collision_mask_value(1,false)
		area_to_set.set_collision_mask_value(2,false)
		area_to_set.set_collision_mask_value(3,false)
		area_to_set.set_collision_mask_value(4,false)
		area_to_set.set_collision_mask_value(5,true)
	else:
		area_to_set.set_collision_mask_value(1,false)
		area_to_set.set_collision_mask_value(2,false)
		area_to_set.set_collision_mask_value(3,false)
		area_to_set.set_collision_mask_value(4,true)

func set_detect_demons(area_to_set:Area2D)->void:
	if self.is_in_group("Green"):
		area_to_set.set_collision_mask_value(1,false)
		area_to_set.set_collision_mask_value(2,false)
		area_to_set.set_collision_mask_value(3,true)
		
	else:
		area_to_set.set_collision_mask_value(1,false)
		area_to_set.set_collision_mask_value(2,true)
		area_to_set.set_collision_mask_value(3,false)
	
	
	
func get_ability_cooldown_duration()->float:
	return ability_cooldown_duration
	
	
