@tool
## Occulum per-type stats. Names, types and defaults mirror Occulum.gd's exports.
class_name OcculumStats extends DemonStats

@export_category("Blood Wait Times")
@export var bloodWaitTime := 30.0
@export var wyrmBloodWaitTime := 50.0
@export var hiveBloodWaitTime := 17.0
@export var crawlerBloodWaitTime := 23.0
@export var baal_blood_rate_multiplier := 1.5

@export_category("Healing Buff Parameters")
@export var heal_interval_wait_time := 10
@export var hive_burst_heal_amount := 50
@export var spinal_occulum_heal_over_time_amount := 25

@export_category("Buffed Health Parameters")
@export var maw_health := 600
@export var spinal_occulum_buffed_health := 500
@export var crawler_buffed_health := 375
@export var wyrm_buffed_health := 375
@export var hive_buffed_health := 375

@export_category("Ultimate Parameters")
@export var ultimate_blood_value := 200
@export var mana_add_on_generate_blood := 100

@export_category("Cost Scaling")
@export var cost_step := 15
@export var cost_step_after_four := 25
