extends ProjectileShootComponent

@onready var attack_ray_1 = $DMG_RayCast2D
@onready var attack_ray_2 = $DMG_RayCast2D2
@onready var attack_ray_3 = $DMG_RayCast2D3
@onready var damage_zone := $DMGZone
@onready var shootPosition1 = $ShootSpawn1
@onready var shootPosition2 = $ShootSpawn2
@onready var shootPosition3 = $ShootSpawn3
@onready var shoot_positions = [shootPosition1, shootPosition2,shootPosition3]

func _ready() -> void:
	attack_rays = [attack_ray_1,attack_ray_2,attack_ray_3]
	super()
	set_damage_zone_collision()


func shoot_projectile():
	AudioManager.create_2d_audio_at_location(self.global_position, SoundEffect.SOUND_EFFECT_TYPE.SPYDER_SPIT)
	for shoot_pos in shoot_positions:
		projectile = projectile_scene.instantiate()
		projectile.position = shoot_pos.global_position
		get_parent().call_deferred("add_child", projectile)
	canAttack = false


func set_damage_zone_collision():
	if self.is_in_group("Green"):
		damage_zone.set_collision_mask_value(1,false)
		damage_zone.set_collision_mask_value(2,false)
		damage_zone.set_collision_mask_value(3,true)
	else:
		damage_zone.set_collision_mask_value(1,false)
		damage_zone.set_collision_mask_value(2,true)
		damage_zone.set_collision_mask_value(3,false)
