@tool
class_name WaveData extends Resource

## Ordered zombie spawn entries for a single wave.
## Entry order (drag-reorderable in the inspector) is the spawn order when
## the spawner's is_random is off. The read-only danger_score shown below
## entries is the count-weighted sum of ZombieRegistry.DANGER_SCORES.

@export var entries: Array[WaveEntry] = []:
	set(value):
		entries = value
		for entry in entries:
			if entry != null and not entry.changed.is_connected(_on_entry_changed):
				entry.changed.connect(_on_entry_changed)
		emit_changed()


func get_danger_score() -> int:
	var total := 0
	for entry in entries:
		if entry != null:
			total += entry.get_danger_score()
	return total


func _on_entry_changed() -> void:
	#notify_property_list_changed()
	emit_changed()


func _get_property_list() -> Array[Dictionary]:
	return [{
		"name": "danger_score",
		"type": TYPE_INT,
		"usage": PROPERTY_USAGE_EDITOR | PROPERTY_USAGE_READ_ONLY,
	}]


func _get(property: StringName) -> Variant:
	if property == &"danger_score":
		return get_danger_score()
	return null


## Convert to Dictionary for systems that still expect {type_name: count}.
func to_dict() -> Dictionary:
	var d := {}
	for entry in entries:
		if entry == null or entry.count <= 0:
			continue
		d[entry.type] = d.get(entry.type, 0) + entry.count
	return d


## Create a WaveData from a {type_name: count} Dictionary.
## Dictionary insertion order becomes entry (spawn) order.
static func from_dict(d: Dictionary) -> WaveData:
	var w := WaveData.new()
	var new_entries: Array[WaveEntry] = []
	for key: String in d:
		if key in ZombieRegistry.SCENES:
			var entry := WaveEntry.new()
			entry.type = key
			entry.count = d[key]
			new_entries.append(entry)
		else:
			push_warning("WaveData.from_dict: unknown zombie type '%s'" % key)
	w.entries = new_entries
	return w
