## One placeable demon type: identity, scene, menu presentation, base cost.
class_name DemonDefinition extends Resource

## True name, e.g. "SpinalOcculum" — matches get_demon_true_name().
@export var id: StringName
@export var display_name: String
@export var scene: PackedScene
@export var icon: Texture2D
## Authoritative base cost: demon_base copies this over its scene export at
## _ready, and the selection menu displays it — balance here, not per scene.
@export var base_cost: int = 50
@export_file("*.txt") var special_description_file: String
