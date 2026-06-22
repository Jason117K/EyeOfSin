class_name WyrmProjectileShootComponent extends ProjectileShootComponent

var isOcculumBuffed := false
var isCrawlerBuffed := false
var isWyrmBleedBuffed := false
var hiveSpawnDroneBuffed := false
var cooldown_timer: Timer

@onready var attack_ray_1 := $"../DMG_RayCast2D"


#@onready var shootPosition1 = $"../Worm1/LaserShootComponent"
#@onready var shootPosition2 = $"../Worm2/LaserShootComponent"
#@onready var laser_shoot_comp_1 := $"../Worm1/LaserShootComponent"
#@onready var laser_shoot_comp_2 := $"../Worm2/LaserShootComponent"

var shootPosition1: Node
var shootPosition2: Node
var laser_shoot_comp_1: Node
var laser_shoot_comp_2: Node

var cooldown: float = 3
var occulum_buff_cooldown: float = 0.9
var auto_fire := true
var projectile_speed := 600
var projectile_damage := 20
var bleed_damage_increase := 2

func _ready() -> void:

	laser_shoot_comp_1 = get_node_or_null("../LaserShootComponent")
	laser_shoot_comp_2 = get_node_or_null("../LaserShootComponent2")
	shootPosition1 = get_node_or_null("../LaserShootComponent")
	shootPosition2 = get_node_or_null("../LaserShootComponent")
	
	
	
	cooldown = parent_demon.projectile_cooldown
	auto_fire = parent_demon.projectile_auto_fire
	occulum_buff_cooldown = parent_demon.occulum_buff_cooldown
	projectile_speed = parent_demon.projectile_speed
	projectile_damage = parent_demon.projectile_damage
	bleed_damage_increase = parent_demon.bleed_damage_increase
	damage = projectile_damage

	shoot_positions = [shootPosition1] #shootPosition2]
	attack_rays = [attack_ray_1]
	super()
	
	if auto_fire:
		#print("AUTO FIRE TRUUUU")
		cooldown_timer = Timer.new()
		add_child(cooldown_timer)
		cooldown_timer.wait_time = cooldown
		cooldown_timer.connect("timeout", Callable(self, "fire_laser"))
		#cooldown_timer.one_shot = true
		cooldown_timer.start()
	node_ready = true

func fire_laser() -> void:
	#print("Wyrm Queen Checking Can Attack ", canAttack)
	if canAttack:
		#print("Should Fire Laser Can Attack Queen")
		if parent_demon.spawn_done:
			#print("Will Now Fire Laser Queen")
			animSpriteComp.animation = animSpriteComp.currentAttackAnim
			animSpriteComp.play()

	
	else:
		pass
		#print("Cannot Attack")

func _on_animated_sprite_component_frame_changed() -> void:
	if animSpriteComp != null:
		if "attack" in animSpriteComp.animation:
			if animSpriteComp.frame == 4:
				laser_shoot_comp_1.fire()
				laser_shoot_comp_2.fire()
				print("Shoot that proj")
				shoot_projectile()
		
		
func apply_buffs_to_projectile(projectile_to_buff: Node) -> void:
	projectile_to_buff.bleed = true
	projectile_to_buff.piercing = true
	projectile_to_buff.is_slowing = false
	projectile_to_buff.damage = projectile_damage
	projectile_to_buff.speed = projectile_speed
	to_global(attack_rays[0].target_position)
	projectile_to_buff.max_distance_can_travel = (attack_rays[0].target_position).x
	print()
	projectile_to_buff.hide()
	
	if isCrawlerBuffed:
		projectile_to_buff.is_slowing = true
		
	if isOcculumBuffed:
		#print("Setting Can Gen Blood To True ")
		projectile_to_buff.canGenBlood = true

	if isWyrmBleedBuffed:
		projectile_to_buff.increase_bleed_damage(bleed_damage_increase)
		
	if hiveSpawnDroneBuffed:
		projectile_to_buff.spawn_drone_on_zombie_death = true

	if mawBuffed:
		projectile_to_buff.damage = parent_demon.maw_damage
		projectile_to_buff.column_explode = true

func wyrm_bleed_buff() -> void:
	isWyrmBleedBuffed = true
	
func debuff()->void:
	super()
	isCrawlerBuffed = false
	isOcculumBuffed = false
	isWyrmBleedBuffed = false
	hiveSpawnDroneBuffed = false
	mawBuffed = false
	
	
	
