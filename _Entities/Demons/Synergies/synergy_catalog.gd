## All demon-pair synergies, editable in the inspector. Data only —
## runtime unlock STATE lives on Global (unlocked_synergies).
## Adding a new synergy = adding one SynergyDefinition to SynergyCatalog.tres.
class_name SynergyCatalog extends Resource

@export var synergies: Array[SynergyDefinition] = []

var _by_id: Dictionary = {}


func get_by_id(id: StringName) -> SynergyDefinition:
	if _by_id.is_empty():
		for s in synergies:
			_by_id[s.id] = s
	return _by_id.get(id)


func has_id(id: StringName) -> bool:
	return get_by_id(id) != null
