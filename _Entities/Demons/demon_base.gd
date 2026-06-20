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
@export var syn_shield_position := Vector2(-2,-6)
@export var hit_flash_duration := 0.3

# --- Component References ---
@onready var animSpriteComp: AnimatedSprite2D = $AnimatedSpriteComponent
@onready var healthComp: Node = $HealthComponent
@onready var heal_anim_sprite: AnimatedSprite2D = $HealAnimSprite
@onready var buffNodes: Node = $BuffNodesComponent
@onready var erase_button : TextureButton = $EraseButton
@onready var erase_mouse_area : Area2D = $EraseMouseArea
@onready var spawn_juice_anim := $SpawnJuiceAnim
@onready var baal_halo : AnimatedSprite2D = $BaalHalo

@onready var preview_nodes := $PreviewNodes

@onready var highlight_circle := $HighlightCircle

var demon_buff_name : String = "None"

var special_description_file : String

var can_show_preview := false
var new_syn_shield_instance :AnimatedSprite2D 
var syn_timer : Timer
var invulnerable := false 
var is_shielded := false
var reduced_damage_percent := 0.0
var game_time: float = 0.0

@onready var hide_highlight_timer : Timer = Timer.new()

# --- State ---
var area: Area2D
var isBuffed := false
var demon_manager : Node
var spawn_done := false 
var is_hero := false
var hit_flash_active : bool = false 
var time_since_hit : float = 0.0 

var all_synergies : Array 
var my_active_dimension : Control

# --- Signals ---
signal demon_die






# --- Lifecycle (_ready) ---

func _ready() -> void:
	highlight_circle.hide()
	if is_empty:
		set_process(false)
		return
	#set_process(false)
	# --- Phase 1: Collision layers (Green/Purple) ---
	_init_collision()
	# --- Phase 2: Signal wiring ---
	_wire_signals()
	# --- Phase 3: Shared references ---
	_init_demon_manager()
	# --- Phase 4: Post-spawn detection (deferred, async) ---
	_schedule_post_spawn()
	Global.register_demon(self)
	
	erase_button.mouse_entered.connect(show_erase_button)
	erase_mouse_area.mouse_exited.connect(hide_erase_button_on_mouse_leave)
	erase_button.pressed.connect(die_fromClearSpace)
	erase_button.hide()
	
	spawn_juice_anim.play()
	
	hide_highlight_timer.one_shot = true 
	hide_highlight_timer.autostart = false
	hide_highlight_timer.wait_time = 6.0
	hide_highlight_timer.timeout.connect(hide_highlight)
	add_child(hide_highlight_timer)
	
	highlight_circle.visibility_changed.connect(_on_highlight_circle_visibility_changed)
	Global.notification_bar.show_new_demon_notification.connect(hide_highlight)
	
	if self.is_in_group("Green"):
		my_active_dimension = Global.game_controller.get_green_dimension()
	else:
		my_active_dimension = Global.game_controller.get_purple_dimension()
		
	ScoreManager.level_ended.connect(broadcast_time_alive)

func broadcast_time_alive()->void:
	ScoreManager.add_score_from_demon(game_time, get_is_buffed())
	

func _process(delta: float) -> void:
	game_time += delta
	if hit_flash_active:
		time_since_hit += delta
		if time_since_hit >= hit_flash_duration:
			hit_flash_active = false
			time_since_hit = 0
			_on_ResetThisColor_timeout()

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

func get_special_description_file(this_all_synergies : Array[String],demonName : String)->String:
	for synergy_file_name in this_all_synergies:
		if synergy_file_name.containsn(demonName):
			return synergy_file_name 
	return ""

func _on_mouse_entered() -> void:
	if can_show_preview && Global.game_controller.get_active_dimension() == my_active_dimension:
		$PreviewNodes.visible = true
	else:
		print("")
	
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

func show_buff_preview_nodes()->void:
	for node in preview_nodes.get_children():
		if node.name.contains("Buff"):
			node.visible = true
		else:
			node.visible = false 
	preview_nodes.visible = true 

func hide_buff_preview_nodes()->void:
	preview_nodes.visible = false 

	for node in preview_nodes.get_children():
		node.visible = true  
		
		

# --- Buff System ---

func baal_buff()->void:
	print("Show Baal Halo")
	animSpriteComp.speed_scale = animSpriteComp.speed_scale * 2
	baal_halo.show()

func undo_baal_buff()->void:
	print("Hide Baal Halo")
	baal_halo.hide()
	animSpriteComp.speed_scale = 1 #animSpriteComp.default_anim_speed_scale

# Called by children after extracting demonName string from the buffing demon node.
# Order: guard → healthComp → animSpriteComp → flag set
func receive_buff(demonName) -> void:
	if demonName == truncate_string(self.get_name()):
		
		return
	special_description_file = get_special_description_file(all_synergies,demonName)
	if !isBuffed:
		print(self.name, " Received Buff from ", demonName)
		healthComp.receive_buff(demonName)
		animSpriteComp.receive_buff(demonName)
		isBuffed = true
		_set_buff_flag(demonName)

func _set_buff_flag(demonName: String) -> void:
	demon_buff_name = demonName
	
	match demonName:
		"Occulum":
				occulumBuff = true
				
		"Crawler": 
				crawlerBuff = true
		"SpinalOcculum":
				spinalOcculumBuff = true
		"Wyrm":
				wyrmBuff = true
		"Hive":
				hiveBuff = true
		"Maw":
				mawBuff = true

		
	
func get_special_description() -> String:
	var file := FileAccess.open(special_description_file, FileAccess.READ)
	if file == null:
		push_error("Could not open file: %s. Error: %d" % [special_description_file, FileAccess.get_open_error()])
		return ""
	var first_line := file.get_line()
	return first_line.to_upper()
	
func get_demon_icon() -> Texture2D:
	return animSpriteComp.current_icon
	
func debuff() -> void:
	print(self,"Self Being Debuffed")
	isBuffed = false
	_reset_buff_flags()
	healthComp.debuff()
	animSpriteComp.debuff()
	special_description_file = get_special_description_file(all_synergies,"Base")
	

func _reset_buff_flags() -> void:
	demon_buff_name = "None"
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

func hide_preview()->void:
	if get_preview_nodes() != null:
		#print(get_preview_nodes())
		for node in get_preview_nodes().get_children():
			node.hide()


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
	if !invulnerable:
		healthComp.take_damage(damage)
		animSpriteComp.set_instance_shader_parameter("hit_flash", 1.0)
		hit_flash_active = true
		
func _on_ResetThisColor_timeout() -> void:
	animSpriteComp.set_instance_shader_parameter("hit_flash", 0.0)

		
			
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
	print("Getting Preview Nodes")
	if "Level0-1" in Global.game_controller.get_active_dimension().name:
		print("Making Tile Alpha Invis")
		$PreviewNodes/BloodTileFront.modulate = Color(1,1,1,0)
		$PreviewNodes/BloodTileBack1.modulate = Color(1,1,1,0)
		$PreviewNodes/BloodTileBack2.modulate = Color(1,1,1,0)
	return $PreviewNodes

func get_true_name() -> String:
	return ""

func shield(syn_shield:PackedScene,duration:float)->void:
	print("Will Now Shield ", self)
	new_syn_shield_instance = syn_shield.instantiate()
	add_child(new_syn_shield_instance)
	new_syn_shield_instance.global_position = syn_shield_position + global_position
	new_syn_shield_instance.play("load")
	syn_timer = Timer.new()
	syn_timer.autostart = false
	syn_timer.one_shot = true 
	syn_timer.wait_time = duration
	syn_timer.timeout.connect(end_shield)
	add_child(syn_timer)
	syn_timer.start()
	
	invulnerable = true 

func weak_shield(syn_shield:PackedScene,duration:float)->void:
	shield(syn_shield,duration)
	invulnerable = false 
	reduced_damage_percent = 0.3

	
func end_shield()->void:
	new_syn_shield_instance.queue_free()
	syn_timer.queue_free()
	invulnerable = false 
	
	
# --- Input ---

func _on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed && spawn_done:
		#print(self, " was clicked, node is ", _viewport)
		Global.set_demon_info_bar(self)
		highlight_circle.show()
		pass
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.double_click:
	# your double-click logic here
		show_erase_button()
		pass

func show_erase_button()->void:
	erase_button.show()
	pass
	
func hide_erase_button_on_mouse_leave()->void:
	erase_button.hide()

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

func demon_selected(selected_demon : Demon) -> void:
	if buffNodes == null:
		return
	if selected_demon.get_demon_true_name() == self.get_demon_true_name():
		return 
	for tile in buffNodes.get_children():
		if not (tile is Area2D and tile.visible):
			continue
		tile.show_preview_square()
		var my_birth: float = tile.get_area_birth_time()
		var should_hide := false
		for other : Area2D in tile.get_overlapping_areas():
			if other == self:
				continue  # don't let Maw/Heart's own body hide its tiles
			if other.is_in_group("Demons") and not ("Drone" in other.name):
				should_hide = true                       # rule 1: occupied
				break
			if "TileArea" in other.name and other.visible and other.get_area_birth_time() < my_birth:
				should_hide = true                       # rule 2: older zone wins
				break
		if should_hide:
			tile.hide_preview_square()
				
func demon_deselected()->void:
	if buffNodes != null:
		for this_buff_area in buffNodes.get_children():
			if this_buff_area.visible == true && this_buff_area is Area2D:
				this_buff_area.hide_preview_square()

func get_demon_true_name() -> String:
	return ""
	
	
func hide_highlight(new_demon_to_highlight : Demon = null)->void:
	if new_demon_to_highlight != self:
		highlight_circle.hide()

func _on_highlight_circle_visibility_changed() -> void:
	if highlight_circle != null:
		if highlight_circle.visible == true:
			hide_highlight_timer.start()

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
