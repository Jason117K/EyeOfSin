## All placeable demon types, editable in the inspector.
## Adding a demon = its scene + one DemonDefinition in DemonCatalog.tres.
class_name DemonCatalog extends Resource

@export var demons: Array[DemonDefinition] = []

var _by_id: Dictionary = {}


func get_demon(id: StringName) -> DemonDefinition:
	if _by_id.is_empty():
		for d in demons:
			_by_id[d.id] = d
	return _by_id.get(id)
