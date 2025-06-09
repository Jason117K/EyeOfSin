class_name GameController extends Node

@export var scene : Control 

var current_scene


func _ready() -> void:
	Global.game_controller = self 
	#TODO safsfaafsafe
	current_scene = self.get_node("CurrentScene").get_child(0)


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
