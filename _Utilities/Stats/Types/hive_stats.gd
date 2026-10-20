@tool
## Hive per-type stats. Names, types and defaults mirror Hive.gd's exports,
## including the drone_* values the Hive hands to its drones.
class_name HiveStats extends DemonStats

@export_category("Swarm")
@export var waitTime := 7.0
@export var buffedWaitTime := 4.0
@export var spinalOcculumHealth := 800

@export_category("Drones")
@export var drone_attack_damage := 7
@export var drone_health := 100
@export var drone_max_health := 100
@export var drone_move_speed := 150
@export var drone_attack_range := 20
@export var drone_baal_damage_multiplier := 3.0
@export var drone_baal_health_multiplier := 2.0
@export var drone_spinal_occulum_buffed_health := 200
@export var drone_spinal_occulum_buffed_max_health := 200

@export_category("Projectile")
@export var projectile_cooldown: float = 3
@export var occulum_buff_cooldown: float = 0.9
@export var projectile_speed := 600
@export var projectile_damage := 20

@export_category("Laser")
@export var laser_damage: float = 20
@export var maw_damage: float = 60
@export var duration: float = 0.5
@export var laser_cooldown: float = 3
@export var blood_buff_cooldown: float = 0.9
