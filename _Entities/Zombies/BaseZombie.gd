extends Area2D
class_name Zombie

signal zombie_death

# --- Exports (Phase 2 will replace these with a single ZombieStats resource) ---
@export_category("Health")
@export var time_between_bleed := 1
@export var health := 76
@export var healthRegen = 0.0
@export var bleed_tick_damage := 0

@export_category("Speed")
@export var speed = 20

@export_category("Attack")
@export var attack_power = 33
@export var attack_speed := 1.0
@export_range(0.1, 1.0) var attack_damage_point := 0.667

@export_category("BloodWorth")
@export var bloodWorth := 1.0
@export_category("Misc")
@export var charge_cost := 1
@export var silence_field_position : Vector2

# --- Component references ---
@onready var healthComp : ZombieHealthComponent = $HealthComponent
@onready var speedComp = $SpeedComponent
@onready var attackComp : AttackComponent = $AttackComponent
@onready var animatedSprite : ZombieSpriteComp = $AnimatedSprite2D
@onready var attack_ray = $DMGRayCast2D
@onready var bloodHit := $BloodHit
@onready var damage_vfx_spawn_locations = [bloodHit]
@onready var debuff_degrade_timer : Timer = $DebuffDegrade
@onready var reset_color_timer : Timer = $ResetThisColor
@onready var just_spawned_timer : Timer = $JustNowSpawned

# --- Preloads ---
var slow_field_scene = preload("res://_Entities/Demons/WebTile/web_tile_slow.tscn")
const DroneScene = preload("res://_Entities/Demons/Minion_Drone.tscn")

# --- State ---
var column_explosion
var silence_field
var is_silenced := false
var isSlow = 0
var thisMaterial
var thisMaterial2
var should_spawn_slow_field := false
var should_spawn_drone_on_death := false
var should_column_explode := false
var reset_speed_timer : Timer

var is_demo := false 
var is_dead := false 
var respawn_timer : Timer 
var demo_original_speed : float 
@export var spawn_x := 180.0
@export var despawn_x := -20.0
@export var respawn_delay := 1.5

func _ready() -> void:
	#print("Zombie world2d: ", get_world_2d(), " rid: ", get_world_2d().get_rid())
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
	debuff_degrade_timer.timeout.connect(_on_DebuffDegrade_timeout)
	reset_color_timer.timeout.connect(_on_ResetThisColor_timeout)
	just_spawned_timer.timeout.connect(_on_JustNowSpawned_timeout)
	if is_demo:
		respawn_timer = Timer.new()
		process_mode = Node.PROCESS_MODE_ALWAYS
		demo_original_speed = speed
		respawn_timer.wait_time = respawn_delay
		respawn_timer.one_shot = true
		respawn_timer.timeout.connect(_on_respawn)
	else:
		Global.register_zombie(self)

			


func make_demo():
	
	is_demo = true 
	print("Should Make is_demo ", is_demo)

func _process(delta):
	if animatedSprite.isDead:
		return

	# --- State Update ---
	# 1. Health: regen is timer-driven, injured flag updated on damage/regen

	# 2. Speed & status: event/timer-driven, no per-frame work
	#    (reserved slot for future per-frame state updates)

	# --- Decision & Action ---
	# 3. Attack: assess targets, initiate or continue attacks
	attackComp.tick(delta)

	# 4. Movement: move only if not attacking
	if not attackComp.is_attacking:
		speedComp.tick(delta)

	# --- Visuals ---
	# 5. Animation: select correct animation for current state
	animatedSprite.tick(delta)


# --- Death ---
func _demo_die() -> void:
	_start_respawn()

func _start_respawn() -> void:
	is_dead = true
	animatedSprite.visible = false
	speed = demo_original_speed
	respawn_timer.start()

func _on_respawn() -> void:
	position.x = spawn_x
	is_dead = false
	animatedSprite.visible = true
	animatedSprite.play("Walk")
	
func die():
	if false:
		_demo_die()
	else:
		Global.deregister_zombie(self)
		print(self, " dying")
		if should_spawn_slow_field:
			spawn_slow_field_on_death()
		if should_spawn_drone_on_death:
			print("Should Spawn Drone")
			_do_spawn_drone_on_death()
		if should_column_explode:
			print(self, "Should MAKE AN EXPLOSION")
			column_explosion = Global.get_column_death_explosion().instantiate()
			if is_demo:
				get_parent().add_child(column_explosion)
				column_explosion.global_position = global_position
			else:
				column_explosion.global_position = global_position
				get_parent().add_child(column_explosion)
		zombie_death.emit()
		if $AnimatedSprite2D.sprite_frames.has_animation("death"):
			$AnimatedSprite2D.isDead = true
			$AnimatedSprite2D.play("death")
		queue_free()


func spawn_slow_field_on_death():
	var slow_field
	slow_field = slow_field_scene.instantiate()
	slow_field.global_position = self.global_position
	get_parent().add_child(slow_field)


func _do_spawn_drone_on_death():
	var drone = DroneScene.instantiate()
	drone.is_stationary = true
	get_parent().add_child(drone)
	if self.is_in_group("Green"):
		drone.add_to_group("Green")
	else:
		drone.add_to_group("Purple")
	drone.global_position = global_position


# --- Damage ---

func take_damage(damage, piercing : bool = false):
	for blood_hit in damage_vfx_spawn_locations:
		blood_hit.visible = true
		blood_hit.rotation_degrees = randf_range(-60, 60)
		if self.is_in_group("Purple"):
			blood_hit.play("hit_purple")
		else:
			blood_hit.play("hit_green")
	healthComp.take_damage(damage, piercing)
	if thisMaterial:
		thisMaterial.set_shader_parameter("target_color", Color.BLACK)
		thisMaterial.set_shader_parameter("replace_color", Color.WHITE)
		thisMaterial.set_shader_parameter("tolerance", 1)
		if thisMaterial2:
			thisMaterial2.set_shader_parameter("target_color", Color.BLACK)
			thisMaterial2.set_shader_parameter("replace_color", Color.WHITE)
			thisMaterial2.set_shader_parameter("tolerance", 1)
		$ResetThisColor.start()


func bleed(bleed_damage):
	healthComp.bleed(bleed_damage)


func getHealthComponent():
	return healthComp


func increaseBloodWorth():
	healthComp.bloodWorth = healthComp.bloodWorth + 10.0


# --- Speed / Slow ---

func freeze():
	speedComp.freeze()


func reset_speed():
	speedComp.setSpeed(speedComp.getOriginalSpeed())


func blood_slow():
	speedComp.setSpeed(speedComp.getOriginalSpeed() / 3)
	set_hue_shift(0)


func undoBloodSlow():
	reset_speed()
	set_hue_shift(animatedSprite.original_hue_shift)


func slow():
	isSlow = isSlow + 100
	speedComp.slow()
	$DebuffDegrade.start()


func getSlow():
	return isSlow


# --- Knockback ---

func knockBack():
	global_position = global_position + Vector2(9, 0)


# --- Visual ---

func set_hue_shift(hue_shift_degrees):
	animatedSprite.set_hue_shift(hue_shift_degrees)


func make_glow():
	pass


func setMaterial(newAnimatedSprite):
	thisMaterial2 = newAnimatedSprite.material.duplicate()
	newAnimatedSprite.material = thisMaterial2
	if newAnimatedSprite:
		thisMaterial2.set_shader_parameter("target_color", Color.BLACK)
		thisMaterial2.set_shader_parameter("replace_color", Color.BLACK)
		thisMaterial2.set_shader_parameter("tolerance", 0.1)


# --- Blood Hit VFX ---

func append_blood_hit(new_blood_hit):
	damage_vfx_spawn_locations.append(new_blood_hit)


func erase_blood_hit(blood_hit_to_erase):
	damage_vfx_spawn_locations.erase(blood_hit_to_erase)


# --- Combat ---

func fightDroneExplode():
	healthComp.willExplodeFromDrone()


func special_move():
	var specialMoveComp = $SpecialMoveComp
	print("Pole Vault Special COMP Manager")
	specialMoveComp.executeMove()
	animatedSprite.setSpecialMoveTrue()


func special_move2():
	animatedSprite.setSpecialMoveTrue()


# --- Death Flags ---

func column_explode():
	should_column_explode = true


func spawn_drone_on_zombie_death():
	should_spawn_drone_on_death = true


func make_spawn_slow_on_death():
	should_spawn_slow_field = true


# --- Silence ---

func silence():
	if !is_silenced:
		print(self, " SILENCE ----------------------------------------------------------------------------------------")
		silence_field = (Global.get_silence_field()).instantiate()
		add_child(silence_field)
		silence_field.play()
		is_silenced = true
	else:
		return


# --- Dimension Change ---

func change_dimensions(new_position):
	self.reparent(Global.get_game_controller().get_alt_dimension().get_node("GameLayer"))
	if self.is_in_group("Green"):
		self.remove_from_group("Green")
		self.add_to_group("Purple")
		self.set_collision_layer_value(2, true)
		set_hue_shift(-86)
	else:
		self.remove_from_group("Purple")
		self.add_to_group("Green")
		self.set_collision_layer_value(3, true)
		set_hue_shift(125)
	self.global_position = new_position


# --- Getters ---

func get_blood_worth():
	return bloodWorth

func get_bleed_interval_time():
	return time_between_bleed

func get_health():
	return healthComp.health

func get_max_health():
	return healthComp.maxHealth

func get_speed():
	return speedComp.speed

func get_damage():
	return attackComp.attack_power

func get_attack_power():
	return attackComp.attack_power

func get_bleed_tick_damage():
	return bleed_tick_damage

func get_charge_cost():
	return charge_cost


# --- Input ---

func _on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		print(self, " was clicked ")
		Global.set_zombie_info_bar(self)
		pass


# --- Timer Handlers ---

func _on_JustNowSpawned_timeout():
	thisMaterial = animatedSprite.material.duplicate()
	animatedSprite.material = thisMaterial
	if thisMaterial:
		thisMaterial.set_shader_parameter("target_color", Color.BLACK)
		thisMaterial.set_shader_parameter("replace_color", Color.BLACK)
		thisMaterial.set_shader_parameter("tolerance", 0.1)
	add_to_group("Alive-Enemies")


func _on_ResetThisColor_timeout():
	thisMaterial.set_shader_parameter("target_color", Color.BLACK)
	thisMaterial.set_shader_parameter("replace_color", Color.BLACK)
	thisMaterial.set_shader_parameter("tolerance", 0.1)
	if thisMaterial2:
		thisMaterial2.set_shader_parameter("target_color", Color.BLACK)
		thisMaterial2.set_shader_parameter("replace_color", Color.BLACK)
		thisMaterial2.set_shader_parameter("tolerance", 0.1)


func _on_DebuffDegrade_timeout():
	if isSlow > 0:
		isSlow -= 10
		if isSlow <= 0:
			isSlow = 0
			$DebuffDegrade.stop()


func _on_blood_hit_animation_finished() -> void:
	bloodHit.visible = false
	bloodHit.rotation_degrees = 0
