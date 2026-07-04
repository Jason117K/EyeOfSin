## Dimension constants: group names, collision layer indices, render bits.
## The convention is load-bearing (README): same-dimension nodes detect each
## other, cross-dimension never do. Layers are assigned in CODE at spawn.
class_name Dim extends RefCounted

const PURPLE := &"Purple"
const GREEN := &"Green"

# Collision layer indices (1-based, as passed to set_collision_*_value).
const LAYER_SHARED := 1            # engine default bit; cleared on gameplay areas
const LAYER_PURPLE_DEMONS := 2
const LAYER_GREEN_DEMONS := 3
const LAYER_PURPLE_ZOMBIES := 4
const LAYER_GREEN_ZOMBIES := 5
const LAYER_PURPLE_BUFF := 12
const LAYER_GREEN_BUFF := 13

# Canvas visibility bits ([purple, green]); the shared UI layer is bit 0.
# Single source of truth — GameController.DIM_BITS references this.
const DIM_BITS := [1 << 1, 1 << 2]


# Dimension membership is a group, not a field. Nodes in neither group are
# treated as Purple (the default dimension).
static func of(node: Node) -> StringName:
	return GREEN if node.is_in_group(GREEN) else PURPLE


static func other(color: StringName) -> StringName:
	return PURPLE if color == GREEN else GREEN
