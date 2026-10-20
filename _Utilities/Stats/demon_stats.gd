@tool
## Core demon stats. Names, types and defaults mirror demon_base.gd's exports.
## Damage is per-type (Crawler `damage`, Wyrm `projectile_damage`, ...), so it
## lives in per-type subclasses, not here.
class_name DemonStats extends UnitStats

@export_category("Cost")
@export var cost: float = 50

@export_category("Health")
@export var health: float = 800
@export var maxHealth: float = 800
@export var healthRegen: float = 0.0
@export var regen_wait_time := 1
@export var rib_health := 250
