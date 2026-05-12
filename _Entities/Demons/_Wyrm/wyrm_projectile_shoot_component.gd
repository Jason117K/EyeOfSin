extends ProjectileShootComponent

var isSunBuffed := false 
var isCrawlerBuffed := false
var cooldown_timer : Timer 

@onready var attack_ray_1 = $"../DMG_RayCast2D"
@onready var shootPosition1 = $"../Worm1/LaserShootComponent"
@onready var shootPosition2 = $"../Worm2/LaserShootComponent"
@onready var laser_shoot_comp_1 := $"../Worm1/LaserShootComponent"
@onready var laser_shoot_comp_2 := $"../Worm2/LaserShootComponent"

@export var cooldown: float = 3
@export var sun_buff_cooldown: float = 0.9
@export var auto_fire := true 
@export var projectile_speed := 600
@export var projectile_damage := 20

func _ready() -> void:
	shoot_positions = [shootPosition1, shootPosition2]
	attack_rays = [attack_ray_1]
	super()
	
	if auto_fire:
		print("AUTO FIRE TRUUUU")
		cooldown_timer = Timer.new()
		add_child(cooldown_timer)
		cooldown_timer.wait_time = cooldown
		cooldown_timer.connect("timeout", Callable(self, "fire_laser"))
		#cooldown_timer.one_shot = true
		cooldown_timer.start()
	node_ready = true 
		
func fire_laser():
	if canAttack:
		laser_shoot_comp_1.fire()
		laser_shoot_comp_2.fire()
		shoot_projectile()
	else:
		print("Cannot Attack")
	
		
func apply_buffs_to_projectile(projectile_to_buff):
	projectile_to_buff.piercing = true 
	projectile_to_buff.is_slowing = false
	projectile_to_buff.damage = projectile_damage
	projectile_to_buff.speed = projectile_speed 
	projectile_to_buff.hide()
	
	if isCrawlerBuffed:
		projectile_to_buff.is_slowing = true
		
	if isSunBuffed:
		projectile_to_buff.canGenBlood = true 
