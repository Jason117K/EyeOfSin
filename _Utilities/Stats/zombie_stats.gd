@tool
## Core zombie stats. Names, types and defaults mirror BaseZombie.gd's exports.
class_name ZombieStats extends UnitStats

@export_category("Health")
@export var health := 76
@export var healthRegen := 0.0
@export var should_health_regen := false
@export var time_between_health_regen := 5
@export var time_between_bleed := 1
@export var bleed_tick_damage := 0
@export var has_armor := false
@export var debuff_duration := 1.0

@export_category("Speed")
@export var speed : float = 16

@export_category("Attack")
@export var attack_power := 33
@export var attack_speed := 1.0
@export_range(0.1, 1.0) var attack_damage_point := 0.667

@export_category("Rewards")
@export var bloodWorth := 0.0
@export var charge_cost := 1
