@tool
## Act 2 boss per-type stats. Names, types and defaults mirror act2_boss_zombie.gd's
## exports. Its phase values replace the core health/speed when it spawns.
class_name Act2BossStats extends ZombieStats

@export_category("Phase 1")
@export var p1_health: float = 1500.0
@export var p1_speed: float = 8.0
@export var p1_attack_damage: float = 100.0
@export var p1_alt_attack_damage: float = 200.0

@export_category("Phase 2")
@export var p2_health: float = 1000.0
@export var p2_speed: float = 10.0
@export var p2_attack_damage: float = 75.0
@export var p2_alt_attack_damage: float = 150.0

@export_category("Phase 3")
@export var p3_health: float = 1500.0
@export var p3_speed: float = 6.0
@export var p3_attack_damage: float = 150.0
@export var p3_alt_attack_damage: float = 300.0

@export_category("Twins")
@export var twin_wait_time: float = 10.0
