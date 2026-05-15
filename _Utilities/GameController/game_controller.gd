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


func _ready() -> void:
	Global.game_controller = self
	current_scene = scene_container.get_child(0)

	swap_cooldown_timer = Timer.new()
	swap_cooldown_timer.wait_time = 0.1
	swap_cooldown_timer.one_shot = true
	swap_cooldown_timer.timeout.connect(func(): can_swap = true)
	add_child(swap_cooldown_timer)


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


func _apply_dimension_visibility() -> void:
	if current_scenes.size() < 2:
		return
	var active_idx := 0 if on_scene_1 else 1
	var hidden_idx := 1 if on_scene_1 else 0
	current_scenes[active_idx].visible = true
	current_scenes[active_idx].set_process_input(true)
	current_scenes[hidden_idx].visible = false
	current_scenes[hidden_idx].set_process_input(false)


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
	new2.visible = false
	scene_container.add_child(new2)
	current_scenes.append(new2)

	on_scene_1 = true
	$CurrentScene/WaveManager.call_deferred("_ready")
	await get_tree().process_frame
	get_tree().paused = false


func change_from_dual_scenes(new_scene_path: String, delete: bool = true, keep_running: bool = false) -> void:
	pause_button.visible = false

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


# --- Pause Overlay Transitions ---

func change_scene_with_pause(new_scene_path: String) -> void:
	Global.hide_notification_bar()
	pause_button.visible = false

	if current_scene != null:
		current_scene.visible = false

	for s in current_scenes:
		if is_instance_valid(s):
			s.visible = false
			s.get_tree().paused = true

	await get_tree().process_frame

	var new_node = load(new_scene_path).instantiate()
	scene_container.add_child(new_node)
	previous_scenes.append(current_scene)
	current_scene = new_node


func change_scene_with_pause_from_dual_scene(new_scene_path: String) -> void:
	Global.hide_notification_bar()
	pause_button.visible = false

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
	_apply_dimension_visibility()

	if on_scene_1:
		current_scene = current_scenes[0]
	else:
		current_scene = current_scenes[1]


# --- Dimension Swapping ---

func swap_scenes() -> void:
	Global.start_swap_ability()
	if !can_swap:
		return

	Global.hide_notification_bar()
	can_swap = false

	var leaving_idx := 0 if on_scene_1 else 1
	var entering_idx := 1 if on_scene_1 else 0

	current_scenes[leaving_idx].get_demon_manager().clear_hero_demon()
	current_scenes[leaving_idx].visible = false
	current_scenes[leaving_idx].set_process_input(false)
	current_scenes[entering_idx].visible = true
	current_scenes[entering_idx].set_process_input(true)

	on_scene_1 = !on_scene_1
	demon_manager = current_scenes[entering_idx].get_demon_manager()

	swap_cooldown_timer.start()
	demon_manager.swap_heart()


func on_purple_scene() -> bool:
	return on_scene_1


# --- Alt-Dimension Helpers ---

func get_alt_dimension() -> Node:
	if on_scene_1:
		print("Get Alt D Returns ", current_scenes[1])
		return current_scenes[1]
	print("Get Alt D Returns ", current_scenes[0])
	return current_scenes[0]


func _get_hidden_scene() -> Node:
	if current_scenes.size() < 2:
		return null
	if !current_scenes[1].visible:
		return current_scenes[1]
	if !current_scenes[0].visible:
		return current_scenes[0]
	return null


func place_empty_in_alt_scene(grid_pos) -> void:
	var hidden := _get_hidden_scene()
	if hidden:
		hidden.place_empty_blocker_demon(grid_pos)


func remove_empty_in_alt_scene(grid_pos) -> void:
	var hidden := _get_hidden_scene()
	if hidden:
		hidden.remove_empty_blocker_demon(grid_pos)


func register_heart_alt_scene(new_hero_demon) -> void:
	var hidden := _get_hidden_scene()
	if hidden:
		hidden.get_child(0).hero_demon = new_hero_demon


func get_current_scene_filepath() -> String:
	return current_scene.scene_file_path


# --- Guide Functions ---

func show_guide() -> void:
	#print("Undo Clear and SHOW THE GUIDE for ", current_scene, " and ", get_alt_dimension())
	print("Undo Clear and SHOW THE GUIDE for ", current_scenes[0], " and ", current_scenes[1])
	if current_scene and current_scenes.size() >= 2:
		current_scenes[0].show_guide()
		current_scenes[1].show_guide()

func clear_guide() -> void:
	print("Should Clear Guide")
	if current_scene and current_scenes.size() >= 2:
		print("Should DEF Clear Both Guides")
		current_scenes[0].hide_guide()
		current_scenes[1].hide_guide()
