## One placeable demon type: identity, scene, menu presentation, base cost.
class_name DemonDefinition extends Resource

## True name, e.g. "SpinalOcculum" — matches get_demon_true_name().
@export var id: StringName
@export var display_name: String
@export var scene: PackedScene
@export var icon: Texture2D
@export_file("*.txt") var special_description_file: String

var _scene_cost := -1


## Cost is balanced on the demon SCENE (its exported `cost`, or its Stats
## config when one is assigned), not here — the catalog only derives it for
## menu display, lazily, one instantiation per demon type per session.
func get_scene_cost() -> int:
	if _scene_cost < 0 and scene != null:
		var instance = scene.instantiate()
		# Never enters the tree, so _enter_tree's apply doesn't run.
		if instance.has_method("apply_stats"):
			instance.apply_stats()
		_scene_cost = int(instance.cost)
		instance.free()
	return _scene_cost
