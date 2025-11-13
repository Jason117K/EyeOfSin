class_name GameController extends Node

@export var scene : Control 

var current_scene
var previous_scenes := []


func _ready() -> void:
	Global.game_controller = self 
	#TODO safsfaafsafe
	current_scene = self.get_node("CurrentScene").get_child(0)
	
func get_current_scene_filepath():
	return current_scene.scene_file_path
	pass

func restore_previous_scene():
	var scene_to_restore = previous_scenes.back()
	print("PPScene to restore is ",scene_to_restore )
	
	previous_scenes.pop_back() 
	print("PPScene to restore iis ",scene_to_restore )
	scene_to_restore.visible = true 
	if scene_to_restore.has_method("make_camera_current"):
		scene_to_restore.make_camera_current()
	current_scene = scene_to_restore
	print("PPPrevious Scenes Is ",previous_scenes )
	if previous_scenes.is_empty():
		scene_to_restore.get_tree().paused = false
	pass
	
	
func change_scene_with_pause(new_scene : String):
	print("PPChanging scene with PAUSE to ", new_scene)
	if current_scene == null:
		print("Current scene : ", current_scene, " is null ")
	else:
		print("PPCurrent scene is : ", current_scene)
	if current_scene != null:
		current_scene.visible = false # Keeps in memory and running 
		pass
	await get_tree().process_frame
	var new = load(new_scene).instantiate()
	scene.add_child(new)

	previous_scenes.append(current_scene)
	current_scene = new
	print("PPrevious Scenes is ",previous_scenes )
	



func change_scene(new_scene : String, delete: bool = true, keep_running : bool = false) -> void:
	print("Changing scene to ", new_scene)
	if current_scene == null:
		print("Current scene : ", current_scene, " is null ")
	else:
		print("Current scene is : ", current_scene)
	if current_scene != null:
		if delete:
			current_scene.queue_free() # Removes Node Entirely 
		elif keep_running:
			current_scene.visible = false # Keeps in memory and running 
		else:
			print("RRemoved Child")
			scene.remove_child(current_scene) #Keeps in memory, does not run 
			
			# Wait one frame to ensure the old scene is properly removed
	await get_tree().process_frame
	
	var new = load(new_scene).instantiate()
	scene.add_child(new)
	current_scene = new 
	
	# Force physics update to ensure collision detection works
	await get_tree().process_frame
	get_tree().physics_frame
	
	#
	#var new = load(new_scene).instantiate()
	#scene.add_child(new)
	#current_scene = new 
