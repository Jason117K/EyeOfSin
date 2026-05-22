class_name GameController extends Node

@export var scene_container: Control

var current_scene: Node
var current_scenes: Array = []
var previous_scenes: Array = []

var on_scene_1 := true
var can_swap := true
var swap_cooldown_timer: Timer

var demon_manager

@onready var pause_button: Button = $PauseButton
@onready var pip := $PipRoot
@onready var demon_selection_menu := $CurrentScene/DemonSelectionMenu

# Dimension visibility-layer scheme. Bit 0 (=1) = shared UI / non-level scenes.
const DIM_BITS := [1 << 1, 1 << 2]
const UI_BIT := 1
var _default_root_cull_mask := 0xFFFFFFFF


func _ready() -> void:
	Global.game_controller = self
	current_scene = scene_container.get_child(0)

	swap_cooldown_timer = Timer.new()
	swap_cooldown_timer.wait_time = 0.1
	swap_cooldown_timer.one_shot = true
	swap_cooldown_timer.timeout.connect(func(): can_swap = true)
	add_child(swap_cooldown_timer)

	_default_root_cull_mask = get_viewport().canvas_cull_mask
	get_tree().node_added.connect(_on_node_added)


# --- Internal Helpers ---

func _remove_and_free(node: Node) -> void:
	if !is_instance_valid(node):
		return
	if node.get_parent():
		node.get_parent().remove_child(node)
	node.queue_free()


func _cleanup_all_scenes() -> void:
	var freed_nodes: Array = []
	for s in current_scenes:
		if is_instance_valid(s) and s not in freed_nodes:
			_remove_and_free(s)
			freed_nodes.append(s)
	if is_instance_valid(current_scene) and current_scene not in freed_nodes:
		_remove_and_free(current_scene)
	current_scenes.clear()
	current_scene = null
	pip.hide_pip()
	get_viewport().canvas_cull_mask = _default_root_cull_mask


func _apply_dimension_visibility() -> void:
	if current_scenes.size() < 2:
		return
	current_scenes[0].visible = true
	current_scenes[1].visible = true
	_apply_view_masks()


func print_scene_tree(node: Node = self, indent: int = 0) -> void:
	var prefix := "\t".repeat(indent)
	print(prefix + node.name + "(" + node.get_class() + ")")
	for child in node.get_children():
		print_scene_tree(child, indent + 1)


# --- Single Scene Transitions ---

func change_scene(new_scene_path: String, delete: bool = true, keep_running: bool = false) -> void:
	Global.hide_notification_bar()
	pause_button.visible = false

	if current_scene != null:
		if delete:
			_remove_and_free(current_scene)
		elif keep_running:
			current_scene.visible = false
		else:
			scene_container.remove_child(current_scene)

	current_scene = null
	await get_tree().process_frame

	var new_node = load(new_scene_path).instantiate()
	scene_container.add_child(new_node)
	current_scene = new_node


# --- Dual Scene Transitions ---

func change_dual_scenes(scene1_path: String, scene2_path: String, delete: bool = true, keep_running: bool = false) -> void:
	#print_scene_tree()
	Global.hide_notification_bar()
	pause_button.visible = true

	if delete:
		_cleanup_all_scenes()
	elif keep_running:
		if current_scene:
			current_scene.visible = false
	else:
		for s in current_scenes:
			if is_instance_valid(s):
				scene_container.remove_child(s)
		current_scenes.clear()
		current_scene = null

	await get_tree().process_frame

	var new1 = load(scene1_path).instantiate()
	scene_container.add_child(new1)
	current_scene = new1
	current_scenes.append(new1)

	var new2 = load(scene2_path).instantiate()
	new2.visible = true
	scene_container.add_child(new2)
	current_scenes.append(new2)

	on_scene_1 = true
	_stamp_scene(current_scenes[0], DIM_BITS[0])
	_stamp_scene(current_scenes[1], DIM_BITS[1])
	_apply_view_masks()
	current_scenes[0].get_node("Camera2D").make_current()
	pip.show_pip()

	$CurrentScene/WaveManager.call_deferred("_ready")
	await get_tree().process_frame
	get_tree().paused = false

	#if on_scene_1:
	#demon_selection_menu.visibility_layer = 0
	#demon_selection_menu.set_visibility_layer_bit(2, true)   # bit 3 -> layer 
	#else:
	demon_selection_menu.visibility_layer = 0
	demon_selection_menu.set_visibility_layer_bit(1, true)   # bit 3 -> layer 


func change_from_dual_scenes(new_scene_path: String, delete: bool = true, keep_running: bool = false) -> void:
	pause_button.visible = false
	pip.hide_pip()
	get_viewport().canvas_cull_mask = _default_root_cull_mask

	if delete:
		_cleanup_all_scenes()
	elif keep_running:
		if current_scene:
			current_scene.visible = false
	else:
		if current_scene:
			scene_container.remove_child(current_scene)
		current_scenes.clear()
		current_scene = null

	await get_tree().process_frame

	var new_node = load(new_scene_path).instantiate()
	scene_container.add_child(new_node)
	current_scene = new_node
	on_scene_1 = true 


# --- Pause Overlay Transitions ---

func change_scene_with_pause(new_scene_path: String) -> void:
	Global.hide_notification_bar()
	pause_button.visible = false

	pip.hide_pip()

	if current_scene != null:
		current_scene.visible = false

	for s in current_scenes:
		if is_instance_valid(s):
			s.visible = false
			set_node_and_children_process_mode_disabled(s)
			#s.get_tree().paused = true

	await get_tree().process_frame

	var new_node = load(new_scene_path).instantiate()
	scene_container.add_child(new_node)
	previous_scenes.append(current_scene)
	current_scene = new_node


func change_scene_with_pause_from_dual_scene(new_scene_path: String) -> void:
	Global.hide_notification_bar()
	pause_button.visible = false
	pip.hide_pip()

	for s in current_scenes:
		if is_instance_valid(s):
			s.visible = false
			s.get_tree().paused = true

	await get_tree().process_frame

	var new_node = load(new_scene_path).instantiate()
	new_node.visible = true
	scene_container.add_child(new_node)
	current_scene = new_node


func restore_previous_scene() -> void:
	var scene_to_restore: Node = previous_scenes.pop_back()
	if scene_to_restore == null:
		return

	scene_to_restore.visible = true
	if scene_to_restore.has_method("make_camera_current"):
		scene_to_restore.make_camera_current()
	current_scene = scene_to_restore

	if previous_scenes.is_empty():
		scene_to_restore.get_tree().paused = false


func restore_dual_scenes() -> void:
	pause_button.visible = true

	if is_instance_valid(current_scene) and current_scene not in current_scenes:
		_remove_and_free(current_scene)

	await get_tree().process_frame
	get_tree().paused = false
	for s in current_scenes:
		if is_instance_valid(s):
			s.visible = false
			set_node_and_children_process_mode_inherit(s)
	_apply_dimension_visibility()
	pip.show_pip()

	if on_scene_1:
		current_scene = current_scenes[0]
	else:
		current_scene = current_scenes[1]
		
func set_node_and_children_process_mode_disabled(root: Node) -> void:
	if root == null:
		return
	root.process_mode = Node.PROCESS_MODE_DISABLED
	for child in root.get_children():
		set_node_and_children_process_mode_disabled(child)


func set_node_and_children_process_mode_inherit(root: Node) -> void:
	if root == null:
		return
	root.process_mode = Node.PROCESS_MODE_INHERIT
	for child in root.get_children():
		set_node_and_children_process_mode_inherit(child)
		
		
# --- Dimension Swapping ---

func swap_scenes() -> void:
	Global.start_swap_ability()
	if !can_swap:
		return

	Global.hide_notification_bar()
	if on_scene_1:
		demon_selection_menu.visibility_layer = 0
		demon_selection_menu.set_visibility_layer_bit(2, true)   # bit 3 -> layer 
	else:
		demon_selection_menu.visibility_layer = 0
		demon_selection_menu.set_visibility_layer_bit(1, true)   # bit 3 -> layer 
		
		
	can_swap = false

	var leaving_idx := 0 if on_scene_1 else 1
	var entering_idx := 1 if on_scene_1 else 0

	current_scenes[leaving_idx].get_demon_manager().clear_hero_demon()
	on_scene_1 = !on_scene_1
	_apply_view_masks()
	current_scenes[entering_idx].get_node("Camera2D").make_current()

	demon_manager = current_scenes[entering_idx].get_demon_manager()

	swap_cooldown_timer.start()
	demon_manager.swap_heart()


func on_purple_scene() -> bool:
	return on_scene_1


func get_active_dimension() -> Node:
	if current_scenes.size() < 2:
		return current_scene
	return current_scenes[0] if on_scene_1 else current_scenes[1]


func toggle_pip_size() -> void:
	pip.toggle_size()


func _on_node_added(node: Node) -> void:
	if current_scenes.size() < 2 or not (node is CanvasItem):
		return
	#for i in 2:
		#var s: Node = current_scenes[i]
		#if is_instance_valid(s) and (node == s or s.is_ancestor_of(node)):
			#print(" Node ", node , " will have visibility layer set to DIM_BITS[",i,"]")
			#node.visibility_layer = DIM_BITS[i]
			#return


func _stamp_scene(scene: Node, layer: int) -> void:
	if scene is CanvasItem:
		#if "control" in scene.name:
		#print(scene.name , " will have visibility layer set to ", layer, scene.get_name())
		scene.visibility_layer = layer
	for child in scene.get_children():
		_stamp_scene(child, layer)
		#print("Calling stamp scene on child ", child, " and/on layer ", layer  )


func _apply_view_masks() -> void:
	var active_bit: int = DIM_BITS[0] if on_scene_1 else DIM_BITS[1]
	get_viewport().canvas_cull_mask = UI_BIT | active_bit | (1 << 9)
	var inactive_idx := 1 if on_scene_1 else 0
	pip.set_pip_cull_mask(DIM_BITS[inactive_idx])
	pip.set_mirror_camera(current_scenes[inactive_idx].get_node("Camera2D"))


# --- Alt-Dimension Helpers ---

func get_alt_dimension() -> Node:
	if on_scene_1:
		print("Get Alt D Returns ", current_scenes[1])
		return current_scenes[1]
	print("Get Alt D Returns ", current_scenes[0])
	return current_scenes[0]


func get_other_dimension():
	if on_purple_scene():
		return current_scenes[1]
	else:
		return current_scenes[0]


func place_empty_in_alt_scene(grid_pos) -> void:
	print("Should Place Empty Block Demon at ", grid_pos)
	var other_dimension = get_other_dimension()
	if other_dimension:
		other_dimension.place_empty_blocker_demon(grid_pos)


func remove_empty_in_alt_scene(grid_pos) -> void:
	var other_dimension = get_other_dimension()
	if on_purple_scene():
		other_dimension = current_scenes[1]
	else:
		other_dimension = current_scenes[0]
		
	if other_dimension:
		other_dimension.remove_empty_blocker_demon(grid_pos)


func register_heart_alt_scene(new_hero_demon) -> void:
	var other_dimension = get_other_dimension()
	if other_dimension:
		other_dimension.get_child(0).hero_demon = new_hero_demon


func get_current_scene_filepath() -> String:
	return current_scene.scene_file_path


# --- Guide Functions ---

func show_guide() -> void:
	#print("Undo Clear and SHOW THE GUIDE for ", current_scene, " and ", get_alt_dimension())
	#print("Undo Clear and SHOW THE GUIDE for ", current_scenes[0], " and ", current_scenes[1])
	if current_scene and current_scenes.size() >= 2:
		current_scenes[0].show_guide()
		current_scenes[1].show_guide()

func clear_guide() -> void:
	#print("Should Clear Guide")
	if current_scene and current_scenes.size() >= 2:
		#print("Should DEF Clear Both Guides")
		current_scenes[0].hide_guide()
		current_scenes[1].hide_guide()
