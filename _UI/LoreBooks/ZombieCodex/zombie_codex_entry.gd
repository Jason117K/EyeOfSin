class_name ZombieCodexEntry
extends Resource

## Key in ZombieRegistry.SCENES, which Discovery uses to unlock the entry.
@export var discovery_name: String
@export var title_key: String
@export_file("*.txt") var description_path: String

@export_group("Portrait")
@export var portrait: Texture2D
@export var portrait_flip_h := false
## Multiplies the portrait's fitted size on its grid card.
@export_range(0.1, 4.0, 0.05, "or_greater") var portrait_scale := 1.0
## Nudges the portrait on its grid card, in card pixels (+ is right/down).
@export var portrait_offset := Vector2.ZERO

@export_group("Preview Animation")
@export var animation: SpriteFrames
@export var animation_name := &"default"
@export var animation_flip_h := false
## Largest scale the codex preview may use. The preview shrinks below it to fit the panel.
@export var preview_scale := 3.0
