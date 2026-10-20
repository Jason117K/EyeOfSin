@tool
## Wyrm per-type stats. Names, types and defaults mirror Wyrm.gd's exports.
class_name WyrmStats extends DemonStats

@export_category("Ultimate")
@export var ultimate_damage :int = 100
@export var ultimate_bleed : int = 10
@export var mana_add_on_laser := 100

@export_category("Buffed Health")
@export var spinalOcculumBuffed_health := 650
@export var mawBuffed_health := 350

@export_category("Projectile")
@export var projectile_cooldown: float = 3
@export var occulum_buff_cooldown: float = 0.9
@export var projectile_speed := 600
@export var projectile_damage := 20
@export var bleed_damage_increase := 2
@export var buffed_range_target_pos := Vector2(450.0, 0)

@export_category("Laser")
@export var laser_damage: float = 20
@export var baal_damage_multiplier := 2.0
@export var maw_damage: float = 60
@export var duration: float = 0.5
@export var laser_cooldown: float = 3
@export var blood_buff_cooldown: float = 0.9
