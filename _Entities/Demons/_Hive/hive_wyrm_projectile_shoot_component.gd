extends WyrmProjectileShootComponent

@onready var shootPosition := $"../HiveLaserShootComp"

@onready var attack_ray := $"../DMG_RayCast2D"
@onready var laser_shoot_comp := $"../HiveLaserShootComp"

func _ready() -> void:
	cooldown = parent_demon.projectile_cooldown
	auto_fire = parent_demon.projectile_auto_fire
	projectile_speed = parent_demon.projectile_speed
	projectile_damage = parent_demon.projectile_damage

	animSpriteComp = $"../AnimatedSpriteComponent"
	shoot_positions = [shootPosition]
	attack_rays = [attack_ray]
	set_attack_rays_collision()
	if auto_fire:
		#print("AUTO FIRE TRUUUU")
		cooldown_timer = Timer.new()
		add_child(cooldown_timer)
		cooldown_timer.wait_time = cooldown
		cooldown_timer.connect("timeout", Callable(self, "fire_laser"))
		cooldown_timer.start()
	node_ready = true

func fire_laser() -> void:
	print("Try Fire Laser")
	if canAttack && laser_shoot_comp.done_firing:
		laser_shoot_comp.fire()
		shoot_projectile()
	else:
		pass
		#print("Cannot Attack")
		
func apply_buffs_to_projectile(projectile_to_buff: Node) -> void:
	projectile_to_buff.max_distance_can_travel = laser_shoot_comp.max_length
	projectile_to_buff.bleed = false
	projectile_to_buff.piercing = true
	projectile_to_buff.is_slowing = false
	print("Set Silencing To True, parent is ", get_parent())
	projectile_to_buff.silencing = true
	projectile_to_buff.damage = projectile_damage
	projectile_to_buff.speed = projectile_speed
	projectile_to_buff.hide()

func enable_auto_fire() -> void:
	auto_fire = true
	if cooldown_timer == null:
		cooldown_timer = Timer.new()
		add_child(cooldown_timer)
		cooldown_timer.wait_time = cooldown
		cooldown_timer.connect("timeout", Callable(self, "fire_laser"))
	cooldown_timer.start()
