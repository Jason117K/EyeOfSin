class_name GameController extends Node

@export var scene : Control 

var current_scene
var current_scene_owner 
var current_scenes := []
var previous_scenes := []

var on_scene_1 := true 
var swap_cooldown_timer 
var cooldown = 0.1
var can_swap := true 

func _ready() -> void:
	Global.game_controller = self 
	#TODO safsfaafsafe
	current_scene = self.get_node("CurrentScene").get_child(0)
	current_scene_owner = self.get_node("CurrentScene")
	swap_cooldown_timer = Timer.new()
	
	add_child(swap_cooldown_timer)
	swap_cooldown_timer.wait_time = cooldown
	swap_cooldown_timer.connect("timeout", Callable(self, "reset_cooldown"))	
	swap_cooldown_timer.one_shot = true 
	
func change_dual_scenes(new_scene1 : String, new_scene2 : String, delete: bool = true, keep_running : bool = false) -> void:
	print("Changing scene to ", new_scene1 , " AND ", new_scene2)
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
	
	var new1 = load(new_scene1).instantiate()
	scene.add_child(new1)
	current_scene = new1 
	current_scenes.append(new1)

	var new2 = load(new_scene2).instantiate()
	new2.visible = false 
	scene.add_child(new2)
	current_scenes.append(new2)
	
	current_scene._ready()
	#new2._ready()
	# Force physics update to ensure collision detection works
	await get_tree().process_frame
	get_tree().physics_frame	

func swap_scenes():
	if can_swap:
		can_swap = false
	#check
	
			
		print("Swap Scenes")
		current_scene.visible = false 
		if on_scene_1:
			current_scenes[1].visible = true 
			current_scenes[1].set_process_input(true)
			current_scenes[0].visible = false 
			current_scenes[1].set_process_input(false)
			on_scene_1 = false 
		else:
			current_scenes[1].visible = false 
			current_scenes[1].set_process_input(false)
			current_scenes[0].visible = true 
			current_scenes[0].set_process_input(true)
			on_scene_1 = true 		
			
		swap_cooldown_timer.start()
		
func reset_cooldown():
	can_swap = true
	
func place_empty_in_alt_scene(grid_pos):
	#return
	if current_scenes[1].visible == false :
		print("current_scenes[1] is", current_scenes[1])
		current_scenes[1].place_empty_blocker_plant(grid_pos)
	elif current_scenes[0].visible == false :
		print("current_scenes[0] is", current_scenes[0])
		current_scenes[0].place_empty_blocker_plant(grid_pos)
	
	
func get_green_scene():
	return current_scenes[1]
	
func get_purple_scene():
	return current_scenes[0]
	
		
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
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
	#print("PPPrevious Scenes Is ",previous_scenes )
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
