@tool
class_name WaveTableHost extends Node

## Editor-only lens for authoring wave composition as tables.
##
## Stores no wave data of its own. The Wave Table Editor plugin
## (res://addons/wave_table_editor) finds every ZombieSpawner in the scene and
## reads/writes each spawner's own `waves` array directly, so there is exactly
## one source of truth. Select this node to see the tables.
##
## Completely inert at runtime.

## Subtree to search for ZombieSpawner nodes.
## Leave empty to search the whole edited scene.
@export var search_root: NodePath
