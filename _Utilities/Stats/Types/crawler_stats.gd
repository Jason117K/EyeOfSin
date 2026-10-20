@tool
## Crawler per-type stats. Names, types and defaults mirror Crawler.gd's exports.
class_name CrawlerStats extends DemonStats

@export_category("Projectile")
@export var projectile_speed := 325
@export var damage: float = 10
@export var attack_speed_mult := 1.0
@export var shoot_interval := 2.0

@export_category("Buff Parameters")
@export var general_damage_increase := 10.0
@export var blood_worth_to_add := 10.0
@export var buffed_range_target_pos := Vector2(375.0, 0)
@export var spiderling_wait_time := 2
@export var baal_damage_multiplier := 2.0
@export var spinalOcculumHealth: float = 375

@export_category("Ultimate")
@export var mana_add_on_shot := 100
@export var ultimate_timer_wait_time := 0.2
