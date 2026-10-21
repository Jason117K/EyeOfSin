## All demon-pair synergies, editable in the inspector. Data only —
## discovery STATE lives in the Discovery statics (saved to user://discovery.cfg).
## Adding a new synergy = adding one SynergyDefinition to SynergyCatalog.tres.
class_name SynergyCatalog extends Resource

@export var synergies: Array[SynergyDefinition] = []

var _by_id: Dictionary = {}
var _by_codex_slot: Dictionary = {} # "<codex_page>:<codex_alt_index>" -> definition


func get_by_id(id: StringName) -> SynergyDefinition:
	if _by_id.is_empty():
		for s in synergies:
			_by_id[s.id] = s
	return _by_id.get(id)


## The synergy shown on a codex page's alt tab (page = true name, index 2..6), or null.
func get_by_codex_slot(page: StringName, alt_index: int) -> SynergyDefinition:
	if _by_codex_slot.is_empty():
		for s in synergies:
			_by_codex_slot["%s:%d" % [s.codex_page, s.codex_alt_index]] = s
	return _by_codex_slot.get("%s:%d" % [page, alt_index])


func has_id(id: StringName) -> bool:
	return get_by_id(id) != null
