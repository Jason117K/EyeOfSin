@tool
## SpinalOcculum per-type stats. Names, types and defaults mirror
## SpinalOcculum.gd's exports. wyrm_buffed_health_regen is left out: nothing
## reads it (see REFACTOR_PLAN.md cleanup candidates).
class_name SpinalOcculumStats extends DemonStats

@export_category("Buffed Health")
@export var crawler_buffed_health := 850
@export var crawler_buffed_max_health := 850
@export var occulum_buffed_health := 850
@export var occulum_buffed_max_health := 800
@export var occulum_buffed_health_regen := 0.1
@export var wyrm_buffed_health := 850
@export var wyrm_buffed_max_health := 800
@export var maw_buffed_health := 850
@export var maw_buffed_max_health := 800
@export var maw_buffed_health_regen := 0.1

@export_category("Buff Parameters")
@export var lightning_damage := 10
@export var blood_spawn_time := 5
@export var spike_damage := 20

@export_category("Ultimate")
@export var mana_add_on_block_damage := 100
