@tool
class_name WaveEntry extends Resource

## One zombie type + count inside a wave. The entry's position in
## WaveData.entries is the spawn order when the spawner's is_random is off.
## The type dropdown is built from ZombieRegistry.SCENES so it never drifts.

var type: String = "Reborn":
	set(value):
		type = value
		emit_changed()
var count: int = 1:
	set(value):
		count = value
		emit_changed()


func get_danger_score() -> int:
	return count * int(ZombieRegistry.DANGER_SCORES.get(type, 1))


func _get_property_list() -> Array[Dictionary]:
	return [
		{
			"name": "type",
			"type": TYPE_STRING,
			"hint": PROPERTY_HINT_ENUM,
			"hint_string": ",".join(ZombieRegistry.SCENES.keys()),
			"usage": PROPERTY_USAGE_DEFAULT,
		},
		{
			"name": "count",
			"type": TYPE_INT,
			"hint": PROPERTY_HINT_RANGE,
			"hint_string": "0,99,1",
			"usage": PROPERTY_USAGE_DEFAULT,
		},
	]
