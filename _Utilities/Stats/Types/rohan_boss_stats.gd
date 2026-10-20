@tool
## Rohan boss per-type stats. Names, types and defaults mirror
## rohan_boss_zombie.gd's exports.
class_name RohanBossStats extends ZombieStats

@export_category("Rohan Boss")
@export var piercing_cooldown: float = 9.0
@export var buff_cooldown: float = 20.0
@export var dash_cooldown: float = 7.0
@export var dash_speed: float = 110.0

@export_category("Rohan Boss Phase 2")
@export var realmswap_cooldown: float = 15.0
@export var realmswap_attack_threshold: int = 10
@export var phase_2_health_mult := 2.0
