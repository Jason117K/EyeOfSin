extends Area2D

class_name Demon

# ============================================================
# DEMON EXECUTION FLOW
# ============================================================
#
# _ready() — synchronous phases, children call super() first:
#   1. set_process(false)      — disabled by default, children opt-in
#   2. _init_collision()       — Green/Purple collision layers
#   3. _wire_signals()         — input_event, area_entered/exited
#   4. _init_demon_manager()   — DemonManager reference lookup
#   5. _schedule_post_spawn()  — ASYNC: heart buff detection after 2 physics frames
#   Then children do demon-specific setup (raycasts, timers, components).
#
# receive_buff(demonName: String) — children extract name, then call super():
#   1. Guard: skip if self-buff or already buffed
#   2. healthComp.receive_buff()
#   3. animSpriteComp.receive_buff()
#   4. isBuffed = true + buff flag set
#   Then children dispatch to their own components (shoot, laser, swarm, etc.)
#
# die() — template method, children override _cleanup()/_cleanup_manager():
#   1. demon_die.emit()
#   2. _cleanup_manager()  — DemonManager.clear_space (skipped in die_fromClearSpace)
#   3. _cleanup()          — buffNodes + demon-specific teardown
#   4. queue_free()
#
# debuff() — children do component cleanup, then call super():
#   1. Child component-specific cleanup
#   2. isBuffed = false + reset all buff flags
# ============================================================

# --- Exports ---
@export var wyrmBuff: bool = false
@export var hiveBuff: bool = false
@export var spinalOcculumBuff: bool = false
@export var mawBuff: bool = false
@export var crawlerBuff: bool = false
@export var occulumBuff: bool = false
@export var cost: float = 50

@export var health: float = 800
@export var healthRegen: float = 0.0
@export var maxHealth: float = 800
@export var regen_wait_time := 1
@export var is_empty := false 
# --- Component References ---
@onready var animSpriteComp: AnimatedSprite2D = $AnimatedSpriteComponent
@onready var healthComp: Node = $HealthComponent
@onready var heal_anim_sprite: AnimatedSprite2D = $HealAnimSprite
@onready var buffNodes: Node = $BuffNodesComponent

# --- State ---
var area: Area2D
var isBuffed := false
var demon_manager : Node
var spawn_done := false 
# --- Signals ---
signal demon_die


# --- Lifecycle (_ready) ---

func _ready() -> void:
	if is_empty:
		set_process(false)
		return
	set_process(false)
	# --- Phase 1: Collision layers (Green/Purple) ---
	_init_collision()
	# --- Phase 2: Signal wiring ---
	_wire_signals()
	# --- Phase 3: Shared references ---
	_init_demon_manager()
	# --- Phase 4: Post-spawn detection (deferred, async) ---
	_schedule_post_spawn()

func _init_collision() -> void:
	if is_in_group("Green"):
		set_collision_layer_value(1, false)
		set_collision_layer_value(2, false)
		set_collision_layer_value(3, true)
	else:
		set_collision_layer_value(1, false)
		set_collision_layer_value(2, true)
		set_collision_layer_value(3, false)

func _wire_signals() -> void:
	input_event.connect(_on_input_event)
	area_entered.connect(on_demon_area_entered)
	area_exited.connect(on_demon_area_exited)

func _init_demon_manager() -> void:
	var _dm_parent: Node = get_parent()
	if _dm_parent:
		var _dm_grandparent: Node = _dm_parent.get_parent()
		if _dm_grandparent and _dm_grandparent.has_node("DemonManager"):
			demon_manager = _dm_grandparent.get_node("DemonManager")

func _schedule_post_spawn() -> void:
	# Heart buff detection requires physics overlap resolution
	await get_tree().physics_frame
	await get_tree().physics_frame
	_detect_heart_buffs()

func _detect_heart_buffs() -> void:
	for new_area in get_overlapping_areas():
		if new_area.is_in_group("HeartBuff"):
			receive_heart_buff()


# --- Buff System ---

# Called by children after extracting demonName string from the buffing demon node.
# Order: guard → healthComp → animSpriteComp → flag set
func receive_buff(demonName : String) -> void:
	if demonName == truncate_string(self.get_name()):
		return
	if !isBuffed:
		print(self.name, " Received Buff from ", demonName)
		healthComp.receive_buff(demonName)
		animSpriteComp.receive_buff(demonName)
		isBuffed = true
		_set_buff_flag(demonName)

func _set_buff_flag(demonName: String) -> void:
	match demonName:
		"Occulum": occulumBuff = true
		"Crawler": crawlerBuff = true
		"SpinalOcculum": spinalOcculumBuff = true
		"Wyrm": wyrmBuff = true
		"Hive": hiveBuff = true
		"Maw": mawBuff = true

func debuff() -> void:
	isBuffed = false
	_reset_buff_flags()

func _reset_buff_flags() -> void:
	wyrmBuff = false
	hiveBuff = false
	spinalOcculumBuff = false
	mawBuff = false
	crawlerBuff = false
	occulumBuff = false

func get_is_buffed() -> bool:
	return isBuffed


# --- Death ---

func die() -> void:
	demon_die.emit()
	_cleanup_manager()
	_cleanup()
	queue_free()

func die_fromClearSpace() -> void:
	demon_die.emit()
	_cleanup()
	queue_free()

func _cleanup_manager() -> void:
	if demon_manager != null:
		demon_manager.clear_space(self.global_position)

func _cleanup() -> void:
	if buffNodes:
		buffNodes.clearBuffs()


# --- Health Delegation ---

func receive_heart_buff() -> void:
	print(self.name, " receive Heart Buff")
	buffNodes.get_child(0).visible = true
	increase_max_health(400)
	increase_health(400)

func remove_heart_buff() -> void:
	print(self.name, " remove Heart Buff")
	buffNodes.get_child(0).visible = false

func increase_health(added_health_amount: float) -> void:
	if healthComp.is_node_ready():
		healthComp.increase_health(added_health_amount)

func increase_max_health(added_health_amount: float) -> void:
	healthComp.increase_max_health(added_health_amount)

func take_damage(damage: float) -> void:
	healthComp.take_damage(damage)

func play_healing_anim() -> void:
	heal_anim_sprite.play()


# --- Getters ---

func get_health() -> float:
	return healthComp.get_health()

func get_max_health() -> float:
	return healthComp.get_max_health()

func get_animSpriteComp() -> DemonSpriteComp:
	return animSpriteComp

func get_preview_nodes() -> Node:
	return $PreviewNodes

func get_true_name() -> String:
	return ""


# --- Input ---

func _on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		#print(self, " was clicked, node is ", _viewport)
		Global.set_demon_info_bar(self)


# --- Heart Buff Area Detection ---

func on_demon_area_entered(new_area: Area2D) -> void:
	if new_area.is_in_group("HeartBuff"):
		pass
		#receive_heart_buff()

func on_demon_area_exited(old_area: Area2D) -> void:
	if old_area.is_in_group("HeartBuff"):
		remove_heart_buff()


# --- Spawn ---

func finish_spawn() -> void:
	spawn_done = true 
	animSpriteComp.visible = true
	animSpriteComp.animation = animSpriteComp.currentAnim
	animSpriteComp.play()

func set_spawn_anim_speed(new_speed_speed: float) -> void:
	animSpriteComp.set_spawn_anim_speed(new_speed_speed)


func get_special_description()->String:
	return ""




# --- Utilities ---

func truncate_string(input_string: String) -> String:
	for i in range(input_string.length()):
		var character :String = input_string[i]
		if character.is_valid_int():
			return input_string.substr(0, i)
	return input_string

func print_scene_tree(node: Node = self, indent: int = 0) -> void:
	var prefix := "\t".repeat(indent)
	print(prefix + node.name + "(" + node.get_class() + ")")
	for child in node.get_children():
		print_scene_tree(child, indent + 1)
