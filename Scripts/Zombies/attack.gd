extends UnitState

var target: Node2D
@onready var healthComp := $"../../HealthComp"
@onready var attackTimer := $"../../AttackCooldown"
@export var attackTimerWaitTime := 1

var count = 1

var cooldown_timer := Timer.new()

var frame_counter := 0

var direction_to_player 
var target_rotation 
var can_attack = false 
@export var can_move = true
var weapon_webbed := false

@export var rotation_speed: float = 5.0
@onready var speed_comp = $"../../SpeedComp"
@export var can_rotate := false 
@onready var enemy_root := $"../.."


func _ready() -> void:
	super()
	
func set_target(new_target):
	target = new_target
func get_target():
	return target
	pass

func enter(_previous_state: String, _data := {}) -> void:
	if enemy_root.has_method("enable_attack_hitbox"):
		enemy_root.enable_attack_hitbox()
	attack()
					
					
func attack():
	count+=1
		
	if parent.has_method("attack"):
		parent.attack()
		can_move = false
	parent.animation_player.play("attack_anim")
	# play attack animation, emit signal on end of animation
	parent.animation_player.connect("animation_finished",
			func(anim_name: StringName) -> void:
				if anim_name == "attack_anim" ||  anim_name == "attack_alternate":
					parent.animation_player.play("RESET")
					end_attack(),
					CONNECT_ONE_SHOT)


func end_attack():
	finished.emit(CHASE)

func physics_update(_delta: float) -> void:
	
	if parent != null && target != null : 
		
		if !can_move:
			parent.handle_knockback(_delta)
	else :
		print("MISSSING CALC -----------------------------------------")

	if can_rotate:
		direction_to_player = target.global_position - parent.global_position
		target_rotation = direction_to_player.angle()
		rotation_speed = speed_comp.calc_rot_speed(true)
		parent.rotation = lerp_angle(parent.rotation, target_rotation, rotation_speed * _delta)
