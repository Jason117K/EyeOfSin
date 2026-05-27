extends ProjectileShootComponent

var blood_worth_to_add := 10.0
var shoot_interval: float
var shoot_timer: Timer
@onready var attack_ray_1 := $"../DMG_RayCast2D"
var second_shot_timer: Timer
var damage_increase := 10

func _ready() -> void:
	attack_rays = [attack_ray_1]
	damage = parent_demon.damage
	damage_increase = parent_demon.general_damage_increase
	attack_speed_mult = parent_demon.attack_speed_mult
	projectile_spawn_offest = parent_demon.projectile_spawn_offest
	blood_worth_to_add = parent_demon.blood_worth_to_add
	shoot_interval = parent_demon.shoot_interval
	super()

	second_shot_timer = Timer.new()
	add_child(second_shot_timer)
	second_shot_timer.wait_time = 0.2
	second_shot_timer.one_shot = true
	second_shot_timer.autostart = false
	second_shot_timer.timeout.connect(second_shoot_projectile)

	# Shoot timer — controls fire rate, decoupled from animation speed
	shoot_timer = Timer.new()
	shoot_timer.wait_time = shoot_interval
	shoot_timer.one_shot = false
	shoot_timer.timeout.connect(_on_shoot_timer_timeout)
	add_child(shoot_timer)
	shoot_timer.start()
	node_ready = true

# Override: stop per-frame ray checking — shoot timer controls attack timing
func _process(_delta: float) -> void:
	pass

func _on_shoot_timer_timeout() -> void:
	# Don't interrupt an in-progress attack animation
	if animSpriteComp.animation == animSpriteComp.currentAttackAnim:
		return
	check_attack_rays()
	if canAttack && parent_demon.spawn_done:
		animSpriteComp.animation = animSpriteComp.currentAttackAnim
		animSpriteComp.play()

func shoot_projectile() -> void:
	super()
	#if hiveBuffed:
		#second_shot_timer.start()
	if hiveBuffed:
		print("Shoot More Is Hived Buffed ")
		add_projectile(Vector2(0, 32))
		add_projectile(Vector2(0, -32))


func second_shoot_projectile() -> void:
	print("Shoot 2nd Proj From Crawler ")
	add_projectile(Vector2(30, 32))
	add_projectile(Vector2(30, -32))


func add_projectile(offset: Vector2) -> void:
	AudioManager.create_2d_audio_at_location(self.global_position, SoundEffect.SOUND_EFFECT_TYPE.SPYDER_SPIT)
	projectile = projectile_scene.instantiate()
	projectile.position = parent_demon.position + offset  # Adjust starting position
	if get_parent().is_in_group("Green"):
		projectile.add_to_group("Green")
	else:
		projectile.add_to_group("Purple")
	parent_demon.get_parent().add_child(projectile)  # Add the projectile to the game layer
	
func apply_buffs_to_projectile(projectile_to_buff: Node) -> void:
	if spinalOcculumBuffed:
		print("Buff Projectile With Spine")
		projectile_to_buff.spinalOcculumBuff = true 
	if occulumBuffed:
		projectile_to_buff.give_blood_on_death = true 
		projectile_to_buff.blood_worth_to_add = self.blood_worth_to_add
	if wyrmBuffed:
		projectile_to_buff.wyrmBuff = true
	if hiveBuffed:
		pass
		
		

func receive_buff(newDemon: String) -> void:
	super(newDemon)
	damage = damage + damage_increase
	match newDemon:
		"Occulum":
			pass
		"Crawler":
			pass
		"SpinalOcculum" :
			pass
		"Wyrm":
			pass
		"Hive":
			pass
		"Maw":
			pass
	
	
