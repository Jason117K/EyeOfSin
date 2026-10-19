extends Zombie
# RangedZombie.gd

const PROJECTILE_SCENE := preload("res://_Entities/Zombies/_RangedZombie/ZombieProjectile.tscn")

@onready var projectile_spawn_point : Node2D = $ProjectileSpawnPoint


func _ready() -> void:
	super()
	if Global.gameIsStarted && self.is_demo == false:
		Global.unlock_zombie("Ranged")


func _make_attack_comp() -> ZombieAttackRefCountedComponent:
	return RangedZombieAttackComponent.new(self)


# Called by RangedZombieAttackComponent at the attack's damage point.
func shoot_projectile(damage: float, target_group: String) -> void:
	var projectile := PROJECTILE_SCENE.instantiate()
	# Group before entering the tree: the projectile's _ready reads it for its mask.
	projectile.add_to_group(Dim.of(self))
	projectile.damage = damage
	projectile.target_group = target_group
	projectile.direction = 1.0 if is_flipped else -1.0
	projectile.position = get_parent().to_local(projectile_spawn_point.global_position)
	get_parent().add_child(projectile)
	AudioManager.create_2d_audio_at_location(projectile_spawn_point.global_position, SoundEffect.SOUND_EFFECT_TYPE.SPYDER_SPIT)


func switch_sides() -> void:
	var was_flipped := is_flipped
	super()
	if not was_flipped:
		projectile_spawn_point.position.x = -projectile_spawn_point.position.x


func get_zombie_name() -> String:
	return " RANGED "

func silence() -> void:
	super()
	attackComp.silence()


func get_special_description() -> String:
	return ranged_special_description


func get_zombie_icon() -> CompressedTexture2D:
	return Global.ranged_icon
