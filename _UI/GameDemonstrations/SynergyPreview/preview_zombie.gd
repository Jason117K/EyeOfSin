extends Area2D

@export var walk_speed := 15.0
@export var spawn_x := 180.0
@export var despawn_x := -20.0
@export var respawn_delay := 1.5
@export var health := 100 
@export var damage := 15 

@onready var sprite : AnimatedSprite2D = $AnimatedSprite2D
@onready var respawn_timer : Timer = $RespawnTimer

var is_dead := false
var original_speed : float

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	original_speed = walk_speed
	respawn_timer.wait_time = respawn_delay
	respawn_timer.one_shot = true
	respawn_timer.timeout.connect(_on_respawn)
	sprite.play("Walk")
	if self.is_in_group("Green"):
		self.set_collision_layer_value(1, false)
		self.set_collision_layer_value(2, false)
		self.set_collision_layer_value(3, false)
		self.set_collision_layer_value(5, true)
	else:
		self.set_collision_layer_value(1, false)
		self.set_collision_layer_value(2, false)
		self.set_collision_layer_value(3, false)
		self.set_collision_layer_value(4, true)
	print("Area is in world space ", get_world_2d().direct_space_state)
		
		
func _process(delta: float) -> void:
	if is_dead:
		return
	position.x -= walk_speed * delta
	if position.x < despawn_x:
		_start_respawn()

func take_damage(_damage, _piercing: bool = false) -> void:
	health = health - damage
	if health < 0 : 
		die()
	if is_dead:
		return
	sprite.modulate = Color.WHITE * 3.0
	var tw = create_tween()
	tw.tween_property(sprite, "modulate", Color.WHITE, 0.15)

func slow() -> void:
	walk_speed = original_speed * 0.4

func reset_speed() -> void:
	walk_speed = original_speed

func bleed(_damage) -> void:
	take_damage(_damage)

func knockBack() -> void:
	position.x += 6

func get_health() -> int:
	return 100

func get_max_health() -> int:
	return 100

func get_blood_worth() -> float:
	return 1.0

func get_bleed_interval_time() -> int:
	return 1

func getHealthComponent():
	return null

func die() -> void:
	_start_respawn()

func _start_respawn() -> void:
	is_dead = true
	sprite.visible = false
	walk_speed = original_speed
	respawn_timer.start()

func _on_respawn() -> void:
	position.x = spawn_x
	is_dead = false
	sprite.visible = true
	sprite.play("Walk")
