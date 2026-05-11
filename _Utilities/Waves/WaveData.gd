class_name WaveData extends Resource

## Zombie spawn counts for a single wave.
## Field names must match ZombieRegistry keys exactly.

@export var Reborn: int = 0
@export var Severed: int = 0
@export var Unhallower: int = 0
@export var Flesheater: int = 0
@export var Erupter: int = 0
@export var Reanimator: int = 0
@export var Sundered: int = 0
@export var Amalgam: int = 0
@export var Rohan: int = 0


## Convert to Dictionary for systems that still expect {type_name: count}.
func to_dict() -> Dictionary:
	var d := {}
	for type_name in ZombieRegistry.SCENES:
		var count: int = get(type_name)
		if count > 0:
			d[type_name] = count
	return d


## Create a WaveData from a {type_name: count} Dictionary.
static func from_dict(d: Dictionary) -> WaveData:
	var w := WaveData.new()
	for key in d:
		if key in ZombieRegistry.SCENES:
			w.set(key, d[key])
		else:
			push_warning("WaveData.from_dict: unknown zombie type '%s'" % key)
	return w
