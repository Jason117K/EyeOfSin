extends ProjectileShootComponent

@onready var attack_ray_1 := $"../DMG_RayCast2D"
var second_shot_timer : Timer

func _ready() -> void:
	attack_rays = [attack_ray_1]
	super()
	second_shot_timer = Timer.new()
	add_child(second_shot_timer)
	second_shot_timer.wait_time = 0.2  # Wait 2 seconds
	second_shot_timer.one_shot = true  # Do not Repeat continuously
	second_shot_timer.autostart = false  # Don't start automatically
	second_shot_timer.timeout.connect(second_shoot_projectile)

func shoot_projectile():
	super()
	
	
	if hiveBuffed:
		second_shot_timer.start()
	if walnutBuffed:
		projectile.walnutBuff = true 
	if sunBuffed:
		projectile.sunBuff = true 
	if wyrmBuffed:
		projectile.wyrmBuff = true


func second_shoot_projectile():
	print("Shoot 2nd Proj From Spider ")
	AudioManager.create_2d_audio_at_location(self.global_position, SoundEffect.SOUND_EFFECT_TYPE.SPYDER_SPIT)
	projectile = projectile_scene.instantiate()
	projectile.position = parent_demon.position + Vector2(32, 0)  # Adjust starting position
	parent_demon.get_parent().add_child(projectile)  # Add the projectile to the game layer
