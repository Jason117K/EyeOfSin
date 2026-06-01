extends SwapAbility


@onready var grasp_container := $AllGrasp
@export var grasp_speed := 225.0
@export var max_num_zombies_turned := 16
var is_sweeping := false
var start_x := -150.0
var end_x: float
var num_zombies_turned := 0 
var turned_zombies: Array = []
var _signals_connected := false

func get_icon()->Texture:
	return Global.lucretia_grasp_icon

func apply_swap_ability() -> void:
	num_zombies_turned = 0
	end_x = get_viewport().get_visible_rect().size.x + 150.0
	if !_signals_connected:
		for grasp: AnimatedSprite2D in grasp_container.get_children():
			
			grasp.get_node("Area2D").area_entered.connect(_on_grasp_hit.bind(grasp))
		_signals_connected = true
	set_collision()
	turned_zombies.clear()
	for grasp: AnimatedSprite2D in grasp_container.get_children():
		grasp.position.x = start_x
		grasp.show()
		grasp.play("move")
	is_sweeping = true


func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	if !is_sweeping:
		return
	var all_done := true
	for grasp: AnimatedSprite2D in grasp_container.get_children():
		if grasp.position.x < end_x:
			grasp.position.x += grasp_speed * delta
			all_done = false
		else:
			grasp.stop()
	if all_done:
		is_sweeping = false


func _on_grasp_hit(area: Area2D, grasp: AnimatedSprite2D) -> void:
	if !is_sweeping or !is_instance_valid(area):
		return
	if area.is_in_group("Zombie") and area not in turned_zombies:
		if num_zombies_turned < max_num_zombies_turned : 
			turned_zombies.append(area)
			area.switch_sides()
			grasp.play("grab")
			num_zombies_turned += 1 
		else:
			undo_swap_ability()


func set_collision() -> void:
	for grasp in grasp_container.get_children():
		var area: Area2D = grasp.get_node("Area2D")
		area.set_collision_mask_value(1, false)
		area.set_collision_mask_value(2, false)
		area.set_collision_mask_value(3, false)
		if Global.is_on_purple_dimension():
			area.set_collision_mask_value(4, false)
			area.set_collision_mask_value(5, true)
		else:
			area.set_collision_mask_value(4, true)
			area.set_collision_mask_value(5, false)


func undo_swap_ability() -> void:
	for grasp: AnimatedSprite2D in grasp_container.get_children():
		grasp.hide()
	is_sweeping = false
	stop()
