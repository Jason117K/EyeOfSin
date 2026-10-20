@tool
## Maw per-type stats. Names, types and defaults mirror Maw.gd's exports.
class_name MawStats extends DemonStats

@export_category("Digestion")
@export var bloodAmount: int = 10
@export var digestTime: float = 15.0
@export var baal_digestion_multiplier := 0.5
@export var wyrm_buffed_digestion_time : float = 5.0
@export var spinal_occulum_buffed_digestion_time : float = 9.0
@export var consume_zombie_group_wait_time := 5.0

@export_category("Buffed")
@export var spinal_occulum_heal_amount := 300
@export var spinalOcculumHealth: float = 1500
@export var spinal_occulum_max_health: float = 1500
@export var web_belch_distance := Vector2(128, 0)
