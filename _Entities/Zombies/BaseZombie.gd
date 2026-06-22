extends Area2D
class_name Zombie

signal zombie_death
@warning_ignore("untyped_declaration")
signal this_zombie_died(deadZombie)

# --- Exports (Phase 2 will replace these with a single ZombieStats resource) ---
@export_category("Health")
@export var time_between_bleed := 1
@export var health := 76
@export var healthRegen := 0.0
@export var bleed_tick_damage := 0
@export var hit_flash_duration := 0.3
@export var should_health_regen := false 
@export var time_between_health_regen := 5
@export var is_syn_marked := false 
@export var has_armor := false 

@export_category("Speed")
@export var speed : float = 16

@export_category("Attack")
@export var attack_power := 33
@export var attack_speed := 1.0
@export_range(0.1, 1.0) var attack_damage_point := 0.667

@export_category("BloodWorth")
@export var bloodWorth := 0.0
@export_category("Misc")
@export var charge_cost := 1
@export var silence_field_position : Vector2
@export var fire_fix_position := Vector2(2,-11)
@export var syn_mark_position := Vector2(-1,-12)

# --- Component references ---
#@onready var healthComp : ZombieHealthComponent = $HealthComponent
var healthComp : ZombieHealthRefCountedComponent
#@onready var speedComp := $SpeedComponent
var speedComp : ZombieSpeedRefCountedComponent
#@onready var attackComp : AttackComponent = $AttackComponent
var attackComp : ZombieAttackRefCountedComponent
@onready var animatedSprite : ZombieSpriteComp = $AnimatedSprite2D
@onready var attack_ray := $DMGRayCast2D
@onready var bloodHit := $BloodHit
@onready var fire_fx := $FireFX
@onready var syn_mark_sprite := $SynMark
@onready var death_blood : AnimatedSprite2D = $DeathBlood
#@onready var attack_timer := $AttackTimer
@onready var damage_vfx_spawn_locations := [bloodHit]
@onready var highlight_circle := $HighlightCircle
@onready var buff_halo := $BuffHalo

var is_buffed := false 
#@onready var debuff_degrade_timer : Timer = $DebuffDegrade
#@onready var reset_color_timer : Timer = $ResetThisColor
#@onready var just_spawned_timer : Timer = $JustNowSpawned

var syn_timer : Timer

# --- Preloads ---
var slow_field_scene := preload("res://_Entities/Demons/WebTile/web_tile_slow.tscn")

static var reborn_special_description: String
static var severed_special_description: String
static var unhallower_special_description: String
static var reanimator_special_description: String
static var wretch_special_description: String
static var erupter_special_description: String
static var amalgam_special_description: String
static var flesheater_special_description: String
static var sundered_special_description: String
static var _descriptions_loaded := false

static func _load_descriptions() -> void:
	if _descriptions_loaded:
		return
	reborn_special_description = FileAccess.open("res://_Assets/Text/TextFiles/ZombieSpecialDescriptions/reborn_special_description.txt", FileAccess.READ).get_as_text()
	severed_special_description = FileAccess.open("res://_Assets/Text/TextFiles/ZombieSpecialDescriptions/severed_special_description.txt", FileAccess.READ).get_as_text()
	unhallower_special_description = FileAccess.open("res://_Assets/Text/TextFiles/ZombieSpecialDescriptions/unhallower_special_description.txt", FileAccess.READ).get_as_text()
	reanimator_special_description = FileAccess.open("res://_Assets/Text/TextFiles/ZombieSpecialDescriptions/reanimator_special_description.txt", FileAccess.READ).get_as_text()
	wretch_special_description = FileAccess.open("res://_Assets/Text/TextFiles/ZombieSpecialDescriptions/wretch_special_description.txt", FileAccess.READ).get_as_text()
	erupter_special_description = FileAccess.open("res://_Assets/Text/TextFiles/ZombieSpecialDescriptions/erupter_special_description.txt", FileAccess.READ).get_as_text()
	amalgam_special_description = FileAccess.open("res://_Assets/Text/TextFiles/ZombieSpecialDescriptions/amalgam_special_description.txt", FileAccess.READ).get_as_text()
	flesheater_special_description = FileAccess.open("res://_Assets/Text/TextFiles/ZombieSpecialDescriptions/flesheater_special_description.txt", FileAccess.READ).get_as_text()
	sundered_special_description = FileAccess.open("res://_Assets/Text/TextFiles/ZombieSpecialDescriptions/sundered_special_description.txt", FileAccess.READ).get_as_text()
	_descriptions_loaded = true

const DroneScene = preload("res://_Entities/Demons/Minion_Drone.tscn")

# --- State ---
var column_explosion : Node 
var silence_field : Node
var is_silenced := false
var is_debuffed := false 
var time_since_debuff_applied : float = 0 
@export var debuff_duration := 1.0
var slow_amount := 0
var _secondary_flash_sprite : Node = null
var should_spawn_slow_field := false
var should_spawn_drone_on_death := false
var should_column_explode := false
var reset_speed_timer: Timer
var hit_flash_active : bool = false 
var time_since_hit : float = 0.0 

var is_demo := false
var is_dead := false
var respawn_timer: Timer
var demo_original_speed: float
@export var spawn_x := 180.0
@export var despawn_x := -20.0
@export var respawn_delay := 1.5
var time_since_spawn : float = 0
var _spawn_setup_done := false
var is_flame_dmg_linked := false 


@onready var hide_highlight_timer : Timer = Timer.new()

func _ready() -> void:
	highlight_circle.hide()
	
	speedComp = ZombieSpeedRefCountedComponent.new(self)
	healthComp = ZombieHealthRefCountedComponent.new(self)
	attackComp = ZombieAttackRefCountedComponent.new(self)
	
	death_blood.animation_finished.connect(free_zombie)

	animatedSprite.attackComp = attackComp
	
	fire_fx.position = fire_fix_position
	fire_fx.hide()
	
	syn_mark_sprite.position = syn_mark_position
	syn_mark_sprite.hide()
	
	buff_halo.hide()
	buff_halo.set_hue_shift(animatedSprite.hue_shift)
	
	Zombie._load_descriptions()
	if self.is_in_group("Green"):
		self.set_collision_layer_value(1, false)
		self.set_collision_layer_value(2, false)
		self.set_collision_layer_value(3, false)
		self.set_collision_layer_value(5, true)
		fire_fx.animation = "green_fire"
	else:
		self.set_collision_layer_value(1, false)
		self.set_collision_layer_value(2, false)
		self.set_collision_layer_value(3, false)
		self.set_collision_layer_value(4, true)
		fire_fx.animation = "purple_fire"
	#debuff_degrade_timer.timeout.connect(_on_DebuffDegrade_timeout)
	#reset_color_timer.timeout.connect(_on_ResetThisColor_timeout)
	#just_spawned_timer.timeout.connect(_on_JustNowSpawned_timeout)
	if is_demo:
		respawn_timer = Timer.new()
		process_mode = Node.PROCESS_MODE_ALWAYS
		demo_original_speed = speed
		respawn_timer.wait_time = respawn_delay
		respawn_timer.one_shot = true
		respawn_timer.timeout.connect(_on_respawn)
	else:
		set_process(false)
		Global.register_zombie(self)
		
	hide_highlight_timer.one_shot = true 
	hide_highlight_timer.autostart = false
	hide_highlight_timer.wait_time = 6.0
	hide_highlight_timer.timeout.connect(hide_highlight)
	add_child(hide_highlight_timer)
	
	highlight_circle.visibility_changed.connect(_on_highlight_circle_visibility_changed)
	Global.notification_bar.show_new_zombie_notification.connect(hide_highlight)



func _on_highlight_circle_visibility_changed() -> void:
	if highlight_circle != null:
		if highlight_circle.visible == true:
			hide_highlight_timer.start()

func hide_highlight(new_zombie_to_highlight : Zombie = null)->void:
	if new_zombie_to_highlight != self:
		highlight_circle.hide()
					
			
func get_attack_comp()->ZombieAttackRefCountedComponent:
	return attackComp

func make_demo() -> void:
	is_demo = true
	#print("Should Make is_demo ", is_demo)

func get_special_description() -> String:
	return "Zombie"

func get_zombie_icon() -> CompressedTexture2D:
	return Global.reborn_icon

func _process(delta: float) -> void:
	tick(delta)

func tick(delta: float) -> void:
	if animatedSprite.isDead:
		return

	if not _spawn_setup_done:
		time_since_spawn += delta
		if time_since_spawn > 0.1:
			_on_JustNowSpawned_timeout()
			_spawn_setup_done = true
	if hit_flash_active:
		time_since_hit += delta
		if time_since_hit >= hit_flash_duration:
			hit_flash_active = false
			time_since_hit = 0
			_on_ResetThisColor_timeout()
	if is_debuffed:
		time_since_debuff_applied += delta
		if time_since_debuff_applied >= debuff_duration:
			time_since_debuff_applied = 0
			_on_DebuffDegrade_timeout()

	healthComp.tick(delta)
	attackComp.tick(delta)

	if not attackComp.is_attacking:
		speedComp.tick(delta)

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
	
func die() -> void:
	set_process(false)
	if false:
		_demo_die()
	else:
		Global.deregister_zombie(self)
		#print(self, " dying")
		if should_spawn_slow_field:
			spawn_slow_field_on_death()
		if should_spawn_drone_on_death:
			_do_spawn_drone_on_death()
		if should_column_explode:
			column_explosion = Global.get_column_death_explosion().instantiate()
			if is_demo:
				get_parent().add_child(column_explosion)
				column_explosion.global_position = global_position
			else:
				column_explosion.global_position = global_position
				get_parent().add_child(column_explosion)
		zombie_death.emit()
		this_zombie_died.emit(self)
		if animatedSprite.sprite_frames.has_animation("death"):
			if not animatedSprite.animation_finished.is_connected(hide_on_death):
				animatedSprite.animation_finished.connect(hide_on_death)
			animatedSprite.isDead = true
			animatedSprite.play("death")
		else:
			pass
			#freeze_on_death()
		death_blood.show()
		death_blood.play()
		#queue_free()

func freeze_on_death()->void:
	animatedSprite.stop()

func hide_on_death()->void:
	animatedSprite.hide()

func free_zombie()->void:
	queue_free()


func setSpeed(newSpeed:float)->void:
	speedComp.setSpeed(newSpeed)
	
func spawn_slow_field_on_death() -> void:
	var slow_field := slow_field_scene.instantiate()
	slow_field.global_position = self.global_position
	get_parent().add_child(slow_field)


func _do_spawn_drone_on_death() -> void:
	var drone: Area2D = DroneScene.instantiate()
	drone.is_stationary = true
	#get_parent().add_child(drone)
	get_parent().call_deferred("add_child", drone)
	if self.is_in_group("Green"):
		drone.add_to_group("Green")
	else:
		drone.add_to_group("Purple")
	drone.global_position = global_position


# --- Damage ---

func take_damage(is_link_damage : bool = false, damage: float = 1.0, piercing: bool = false) -> void:
	#print(self, " is taking damage ",damage )
	_on_hit_dmg_effect()
	healthComp.take_damage(is_link_damage,damage, piercing)
#	if !is_link_damage:
	animatedSprite.set_instance_shader_parameter("hit_flash", 1.0)
	if _secondary_flash_sprite:
		_secondary_flash_sprite.set_instance_shader_parameter("hit_flash", 1.0)
	hit_flash_active = true

func _on_hit_dmg_effect()->void:
	for blood_hit:Node in damage_vfx_spawn_locations:
		blood_hit.visible = true
		blood_hit.rotation_degrees = randf_range(-60, 60)
		if self.is_in_group("Purple"):
			blood_hit.play("hit_purple")
		else:
			blood_hit.play("hit_green")

func set_on_fire()->void:
	is_flame_dmg_linked = true 
	healthComp.is_flame_dmg_linked = is_flame_dmg_linked
	if self.is_in_group("Purple"):
		fire_fx.play("purple_fire")
	else:
		fire_fx.play("green_fire")
	fire_fx.visible = true

func set_off_fire()->void:
	is_flame_dmg_linked = false 
	healthComp.is_flame_dmg_linked = is_flame_dmg_linked
	fire_fx.visible = false

func bleed(bleed_damage: float) -> void:
	healthComp.bleed(bleed_damage)


	

func getHealthComponent() -> ZombieHealthRefCountedComponent:
	return healthComp


func increaseBloodWorth() -> void:
	healthComp.bloodWorth = healthComp.bloodWorth + 10.0


# --- Speed / Slow ---

func freeze() -> void:
	speedComp.freeze()


func reset_speed() -> void:
	speedComp.setSpeed(speedComp.getOriginalSpeed())

func switch_sides()->void:
	pass
	#set_hue_shift(0)
	animatedSprite.lucretia_hue_shift()
	animatedSprite.flip_h = !animatedSprite.flip_h 
	speedComp.setSpeed(-speed)
	#Collision Mask,Layer, Group, 
	self.remove_from_group("Zombie")
	self.add_to_group("Demons")
	attackComp.switch_sides()
	if self.is_in_group("Green"):
		print(self, " this green zombie switched sides")
		set_collision_mask_value(1,false)
		set_collision_mask_value(2,false)
		set_collision_mask_value(3,false)
		set_collision_mask_value(4,false)
		set_collision_mask_value(5,true)
		
		set_collision_layer_value(1,false)
		set_collision_layer_value(2,false)
		set_collision_layer_value(3,true)
	else:
		print(self, " this purple zombie switched sides")
		set_collision_mask_value(1,false)
		set_collision_mask_value(2,false)
		set_collision_mask_value(3,false)
		set_collision_mask_value(4,true)
		
		set_collision_layer_value(1,false)
		set_collision_layer_value(2,true)
		set_collision_layer_value(3,false)
	

func syn_mark(duration:float)->void:
	print("Syn Mark Called on ", self)
	animatedSprite.lucretia_hue_shift()
	is_syn_marked = true 
	syn_mark_sprite.show()
	healthComp.set_syn_mark(is_syn_marked)
	syn_timer = Timer.new()
	syn_timer.autostart = false
	syn_timer.one_shot = true 
	syn_timer.wait_time = duration
	syn_timer.timeout.connect(remove_syn_mark)
	add_child(syn_timer)
	syn_timer.start()
	pass
	
func remove_syn_mark()->void:
	animatedSprite.undo_lucretia_hue_shift()
	is_syn_marked = false 
	healthComp.set_syn_mark(is_syn_marked)
	syn_mark_sprite.hide()
	syn_timer.queue_free()
	if is_flame_dmg_linked:
		set_off_fire()
	
	
#TODO Change to Make Webs Red Instead 
func blood_slow(blood_slow_percent:float=0.33) -> void:
	#speedComp.setSpeed(speedComp.getOriginalSpeed() / 3)
	slow_amount = slow_amount + 9999
	speedComp.slow(blood_slow_percent,true)
	animatedSprite.blood_slow()
	#set_hue_shift(0)


func undoBloodSlow() -> void:
	#reset_speed()
	#set_hue_shift(animatedSprite.original_hue_shift)
	@warning_ignore("narrowing_conversion")
	slow_amount = clampf(slow_amount - 9999,0,99999)
	animatedSprite.undo_blood_slow()
	speedComp.undo_blood_slow()
	_on_DebuffDegrade_timeout()


func slow(added_slow_amount : float = 100) -> void:
	@warning_ignore("narrowing_conversion")
	slow_amount = slow_amount + added_slow_amount
	speedComp.slow()
	animatedSprite.slow()
	is_debuffed = true 
	time_since_debuff_applied = 0



func getSlow() -> int:
	return slow_amount


# --- Knockback ---

func knockBack() -> void:
	global_position = global_position + Vector2(32, 0)


# --- Visual ---

func set_hue_shift(hue_shift_degrees: float) -> void:
	animatedSprite.set_hue_shift(hue_shift_degrees)
	death_blood.set_hue_shift(hue_shift_degrees)


func make_glow() -> void:
	pass


func setMaterial(newAnimatedSprite:Node) -> void:
	print("Material Set Here Zombie")
	_secondary_flash_sprite = newAnimatedSprite


# --- Blood Hit VFX ---

func append_blood_hit(new_blood_hit:Node) -> void:
	damage_vfx_spawn_locations.append(new_blood_hit)


func erase_blood_hit(blood_hit_to_erase:Node) -> void:
	damage_vfx_spawn_locations.erase(blood_hit_to_erase)


# --- Combat ---

func fightDroneExplode() -> void:
	healthComp.willExplodeFromDrone()


func special_move() -> void:
	var specialMoveComp := $SpecialMoveComp
	print("Pole Vault Special COMP Manager")
	specialMoveComp.executeMove()
	animatedSprite.setSpecialMoveTrue()


func special_move2() -> void:
	animatedSprite.setSpecialMoveTrue()

func _buff_zombie()->void:
	buff_halo.show()
	if !is_buffed:
		attackComp.increase_damage(0.5)
		speedComp.increase_speed(0.25)
		is_buffed = true 
	#animatedSprite.buff()
	
	


# --- Death Flags ---

func column_explode() -> void:
	should_column_explode = true


func spawn_drone_on_zombie_death() -> void:
	should_spawn_drone_on_death = true


func make_spawn_slow_on_death() -> void:
	should_spawn_slow_field = true


# --- Silence ---

func silence() -> void:
	if !is_silenced:
		silence_field = (Global.get_silence_field()).instantiate()
		add_child(silence_field)
		silence_field.play()
		is_silenced = true
	else:
		return




# --- Dimension Change ---

func change_dimensions(new_position : Vector2) -> void:
	if new_position == Vector2.ONE:
		return 
	if self.is_in_group("Green"): #Green->Purple
		self.remove_from_group("Green")
		self.add_to_group("Purple")
		self.set_collision_layer_value(2, true)
		#set_hue_shift(-86)
		self.reparent(Global.get_game_controller().get_purple_dimension().get_node("GameLayer"))
	else:#Purple->Green
		self.remove_from_group("Purple")
		self.add_to_group("Green")
		self.set_collision_layer_value(3, true)
		#set_hue_shift(125)
		self.reparent(Global.get_game_controller().get_green_dimension().get_node("GameLayer"))
	self.global_position = new_position


# --- Getters ---

func get_blood_worth() -> float:
	return bloodWorth

func get_bleed_interval_time() -> int:
	return time_between_bleed

func get_health() -> float:
	return healthComp.health

func get_max_health() -> float:
	return healthComp.maxHealth

func get_speed() -> float:
	return speedComp.speed

func get_damage() -> float:
	return attackComp.attack_power

func get_attack_power() -> float:
	return attackComp.attack_power

func get_bleed_tick_damage() -> int:
	return bleed_tick_damage

func get_charge_cost() -> int:
	return charge_cost


# --- Input ---

func _on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		#print(self, " was clicked ")
		Global.set_zombie_info_bar(self)
		highlight_circle.show()
		pass


# --- Timer Handlers ---

func _on_JustNowSpawned_timeout() -> void:
	add_to_group("Alive-Enemies")

func get_is_injured()->bool:
	return healthComp.injured


func _on_ResetThisColor_timeout() -> void:
	animatedSprite.set_instance_shader_parameter("hit_flash", 0.0)
	if _secondary_flash_sprite:
		_secondary_flash_sprite.set_instance_shader_parameter("hit_flash", 0.0)


func _on_DebuffDegrade_timeout() -> void:
	if slow_amount > 0:
		slow_amount -= 10
	if slow_amount <= 0:
		slow_amount = 0
		speedComp.is_slow = false
		animatedSprite.is_slow = false 


func _on_blood_hit_animation_finished() -> void:
	bloodHit.visible = false
	bloodHit.rotation_degrees = 0
