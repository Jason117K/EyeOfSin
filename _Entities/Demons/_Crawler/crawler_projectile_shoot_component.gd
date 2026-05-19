extends ProjectileShootComponent

var blood_worth_to_add := 10.0
@onready var attack_ray_1 := $"../DMG_RayCast2D"
var second_shot_timer : Timer

func _ready() -> void:
	attack_rays = [attack_ray_1]
	damage = parent_demon.damage
	attack_speed_mult = parent_demon.attack_speed_mult
	projectile_spawn_offest = parent_demon.projectile_spawn_offest
	blood_worth_to_add = parent_demon.blood_worth_to_add
	super()
	
	second_shot_timer = Timer.new()
	add_child(second_shot_timer)
	second_shot_timer.wait_time = 0.2  # Wait 2 seconds
	second_shot_timer.one_shot = true  # Do not Repeat continuously
	second_shot_timer.autostart = false  # Don't start automatically
	second_shot_timer.timeout.connect(second_shoot_projectile)
	node_ready = true 

func shoot_projectile():
	super()
	#if hiveBuffed:
		#second_shot_timer.start()
	if hiveBuffed:
		print("Shoot More Is Hived Buffed ")
		add_projectile(Vector2(0, 32))
		add_projectile(Vector2(0, -32))


func second_shoot_projectile():
	print("Shoot 2nd Proj From Crawler ")
	add_projectile(Vector2(30, 32))
	add_projectile(Vector2(30, -32))

	
func add_projectile(offset):
	AudioManager.create_2d_audio_at_location(self.global_position, SoundEffect.SOUND_EFFECT_TYPE.SPYDER_SPIT)
	projectile = projectile_scene.instantiate()
	projectile.position = parent_demon.position + offset  # Adjust starting position
	if get_parent().is_in_group("Green"):
		projectile.add_to_group("Green")
	else:
		projectile.add_to_group("Purple")
	parent_demon.get_parent().add_child(projectile)  # Add the projectile to the game layer
	
func apply_buffs_to_projectile(projectile_to_buff):
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
		
		

func receive_buff(newDemon):
	super(newDemon)
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
	
	
