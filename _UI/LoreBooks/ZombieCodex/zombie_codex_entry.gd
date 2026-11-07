class_name ZombieCodexEntry
extends Resource

## Key in ZombieRegistry.SCENES, which Discovery uses to unlock the entry.
@export var discovery_name: String
@export var title_key: String
@export_file("*.txt") var description_path: String

@export_group("Portrait")
@export var portrait: Texture2D
@export var portrait_flip_h := false

@export_group("Preview Animation")
@export var animation: SpriteFrames
@export var animation_name := &"default"
@export var animation_flip_h := false
@export var preview_scale := 3.0
