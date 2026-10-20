@tool
## A swappable stat config for one zombie or demon type. Drop a saved .tres into
## the unit scene's Stats slot; its values replace the scene's own exports before
## any component reads them. An empty slot keeps the scene's values.
##
## Contract: every stat field matches a root export of the unit by NAME and TYPE.
## apply_to() is generic, so a per-type subclass only declares fields. Subclasses
## must be @tool too (the capture EditorScript instantiates them in the editor).
class_name UnitStats extends Resource

## Fields that describe the config itself and are never copied onto the unit.
const META_FIELDS: Array[StringName] = [&"notes"]

## What changed in this version and why.
@export_multiline var notes: String


## The stat fields this config carries, its own and inherited.
func get_stat_names() -> Array[StringName]:
	var names: Array[StringName] = []
	for prop in get_script().get_script_property_list():
		var usage: int = prop.usage
		if not (usage & PROPERTY_USAGE_SCRIPT_VARIABLE and usage & PROPERTY_USAGE_STORAGE):
			continue
		if StringName(prop.name) in META_FIELDS:
			continue
		names.append(StringName(prop.name))
	return names


## Copies every stat onto the unit. Read-only on this resource: it is shared by
## every instance of the unit.
func apply_to(unit: Node) -> void:
	for stat in get_stat_names():
		if not stat in unit:
			push_error("%s: unit '%s' has no stat '%s'" % [resource_path, unit.name, stat])
			continue
		unit.set(stat, get(stat))
