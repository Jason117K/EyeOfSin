@tool
## One unit in a StatsSet: which stat config that unit's scene uses.
class_name StatsSetEntry extends Resource

## The zombie or demon scene this entry applies to.
@export_file("*.tscn") var unit_scene: String
## Its config: a ZombieStats/DemonStats or that unit's per-type class.
@export var stats: UnitStats
