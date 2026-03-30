class_name GameController extends Node

@export var scene : Control 

var current_scene
var current_alt_scene

var current_scene_owner 
var current_scenes := []
var previous_scenes := []

var on_scene_1 := true 
var swap_cooldown_timer 
var cooldown = 0.1
var can_swap := true 

var plant_manager

@onready var pauseButton = $PauseButton

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
	#Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	pauseButton.visible = true 
	#print("Changing scene to ", new_scene1 , " AND ", new_scene2)
	if !current_scenes.is_empty():
		if delete:
		#	print("Current Scenes is ",current_scenes )
		#	print("Current Scenes 1 is ",current_scenes[1] )
			current_scenes.remove_at(1)
		#	print("Current Scenes 0 is ",current_scenes[0] )
			current_scenes[0].queue_free()
			current_scenes.remove_at(0)
		elif keep_running:
			current_scene.visible = false # Keeps in memory and running 
		else:
		#	print("RRemoved Child")
			scene.remove_child(current_scene) #Keeps in memory, does not run 
		
	if current_scene == null:
		pass
	#	print("Current scene : ", current_scene, " is null ")
	else:
		pass
	#	print("Current scene is : ", current_scene)
	if current_alt_scene != null:
		if delete:
	#		print("Delete Here1",current_alt_scene)
			current_alt_scene.queue_free() # Removes Node Entirely 		
	if current_scene != null:
		if delete:
	#		print("Delete Herqe",current_scene)
			current_scene.queue_free() # Removes Node Entirely 
		elif keep_running:
			current_scene.visible = false # Keeps in memory and running 
		else:
	#		print("RRemoved Child")
			scene.remove_child(current_scene) #Keeps in memory, does not run 
			
			# Wait one frame to ensure the old scene is properly removed
	await get_tree().process_frame
#	print("New Scene 1 is  ", new_scene1 , " AND 2 is : ", new_scene2)
	var new1 = load(new_scene1).instantiate()
	scene.add_child(new1)
	current_scene = new1 
	current_scenes.append(new1)

	var new2 = load(new_scene2).instantiate()
	new2.visible = false 
	scene.add_child(new2)
	current_alt_scene = new2
	current_scenes.append(new2)
	
	#print("Current Scenes is now ", current_scenes)
	# Reinitialize WaveManager after both scenes are added so it finds new spawners
	$CurrentScene/WaveManager.call_deferred("_ready")
	# Force physics update to ensure collision detection works
	await get_tree().process_frame
	#print("UNPAUSE GAME")
	current_scenes[0].get_tree().paused = false  
	current_scenes[1].get_tree().paused = false 
	get_tree().paused = false 



func swap_scenes():
	if can_swap:
		can_swap = false
	#check
	
			
	#	print("Swap Scenes")
		#current_scene.visible = false 
		if on_scene_1:
			plant_manager = current_scenes[0].get_child(0)
			plant_manager.clear_hero_demon()
			
			current_scenes[1].visible = true 
			plant_manager = current_scenes[1].get_child(0)
			current_scenes[1].set_process_input(true)
			current_scenes[0].visible = false 
			current_scenes[1].set_process_input(false)
			on_scene_1 = false 
		else:
			plant_manager = current_scenes[1].get_child(0)
			plant_manager.clear_hero_demon()
			
			current_scenes[1].visible = false 
			current_scenes[1].set_process_input(false)
			current_scenes[0].visible = true 
			plant_manager = current_scenes[0].get_child(0)
			current_scenes[0].set_process_input(true)
			on_scene_1 = true 		
			
		swap_cooldown_timer.start()
	#for child in current_scene
	#plant_manager = current_scene.find_child("PlantManager")
	print("PlantManager Is ", plant_manager)
	plant_manager.swap_heart()
func reset_cooldown():
	can_swap = true
	
func place_empty_in_alt_scene(grid_pos):
	#return
	#print("Placing Empty in Alt At QQ ", grid_pos)
	if current_scenes[1].visible == false :
	#	print("current_scenes[1] is", current_scenes[1])
		current_scenes[1].place_empty_blocker_plant(grid_pos)
	elif current_scenes[0].visible == false :
		current_scenes[0].place_empty_blocker_plant(grid_pos)

func remove_empty_in_alt_scene(grid_pos):	
	#print("Removing Empty in Alt At QQ ", grid_pos)
	if current_scenes[1].visible == false :
	#	print("current_scenes[1] is", current_scenes[1])
		current_scenes[1].remove_empty_blocker_plant(grid_pos)
	elif current_scenes[0].visible == false :
		current_scenes[0].remove_empty_blocker_plant(grid_pos)	
	
	
func change_from_dual_scenes(new_scene : String, delete: bool = true, keep_running : bool = false) -> void:
	#print("Changing scene to ", new_scene)
	pauseButton.visible = false 
	#Delete Old Scenes
	
	if !current_scenes.is_empty():
		if delete:
			#print("Current Scenes is ",current_scenes )
			#print("Current Scenes 1 is ",current_scenes[1] )
			current_scenes.remove_at(1)
		#	print("Current Scenes 0 is ",current_scenes[0] )
			current_scenes.remove_at(0)
		
	if current_scene == null:
		pass
		#print("Current scene : ", current_scene, " is null ")
	else:
		pass
	#	print("Current scene is : ", current_scene)
		
	if current_alt_scene != null:
		if delete:
			#print("Delete Here1",current_scene)
			current_alt_scene.queue_free() # Removes Node Entirely 					
	
	if current_scene != null:
		if delete:
		#	print("Delete Herqe",current_scene)
			current_scene.queue_free() # Removes Node Entirely 
		elif keep_running:
			current_scene.visible = false # Keeps in memory and running 
		else:
		#	print("RRemoved Child")
			scene.remove_child(current_scene) #Keeps in memory, does not run 
			
	# Wait one frame to ensure the old scenes are properly removed
	await get_tree().process_frame
	
	var new = load(new_scene).instantiate()
	scene.add_child(new)
	current_scene = new 
	
	# Force physics update to ensure collision detection works
	await get_tree().process_frame
	get_tree().physics_frame
	
	current_scene._ready()
#	print("Current Scenes is now ", current_scenes)
#	print("Current Scene is now ", current_scene)
#	print("UNPAUSE GAME")
	#current_scenes[0].get_tree().paused = false  
	#current_scenes[1].get_tree().paused = false 

	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
func get_current_scene_filepath():
	return current_scene.scene_file_path
	pass

func restore_previous_scene():
	var scene_to_restore = previous_scenes.back()
#	print("PPScene to restore is ",scene_to_restore )
	
	previous_scenes.pop_back() 
#	print("PPScene to restore iis ",scene_to_restore )
	scene_to_restore.visible = true 
	if scene_to_restore.has_method("make_camera_current"):
		scene_to_restore.make_camera_current()
	current_scene = scene_to_restore
	#print("PPPrevious Scenes Is ",previous_scenes )
	if previous_scenes.is_empty():
#		print("UNPAUSE GAME")
		scene_to_restore.get_tree().paused = false
	#	print("UNPPAUSE HER222E")
	pass
	
	
func change_scene_with_pause(new_scene : String):
#	print("PPChanging scene with PAUSE to ", new_scene)
	pauseButton.visible = false 
	if current_scene == null:
		pass
	#	print("Current scene : ", current_scene, " is null ")
	else:
		pass
	#	print("PPCurrent scene is : ", current_scene)
	if current_scene != null:
		current_scene.visible = false # Keeps in memory and running 
		pass
		
	if current_scenes.size() > 1:
		for scene in current_scenes:
			if scene != null:
				scene.visible =false 
	#			print("PAUSE GAME")
				scene.get_tree().paused = true  
#				print(scene , " is ppaused" , scene.get_tree().paused)
				
					
	await get_tree().process_frame
	var new = load(new_scene).instantiate()
	scene.add_child(new)

	previous_scenes.append(current_scene)
	current_scene = new
#	print("PPrevious Scenes is ",previous_scenes )
	
func change_scene_with_pause_from_dual_scene(new_scene : String):
#	print("PPChanging scene with PAUSE from DUAL to ", new_scene)
	pauseButton.visible = false 
	if current_scenes.size() > 1:
		for scene in current_scenes:
			if scene != null:
				scene.visible = false
		#		print("PAUSE GAME")
				scene.get_tree().paused = true  
			else:
				pass
			#	print("Scene is null")

	await get_tree().process_frame
	var new = load(new_scene).instantiate()
	new.visible = true 
	scene.add_child(new)


func restore_dual_scenes():
#	print("PPRestoring Dual Scenes", current_scenes)
	pauseButton.visible = true 
	if current_scene == null:
		pass
	#	print("Current scene : ", current_scene, " is null ")
	else:
		pass
	#	print("PPCurrent scene is : ", current_scene)
	if current_scene != null:
	#	print("Delete Her333e",current_scene)
		current_scene.queue_free() 
		pass
	await get_tree().process_frame
#	print("UNPPAUSE HE2222222222222222RE")
#	print("UNPAUSE GAME")
	current_scenes[0].get_tree().paused = false  
	current_scenes[1].get_tree().paused = false 
	if !on_scene_1:
		current_scenes[1].visible = true 
		current_scenes[1].set_process_input(true)
		current_scenes[0].visible = false 
		current_scenes[1].set_process_input(false)
		 
	else:
		current_scenes[1].visible = false 
		current_scenes[1].set_process_input(false)
		current_scenes[0].visible = true 
		current_scenes[0].set_process_input(true)
		


	


func change_scene(new_scene : String, delete: bool = true, keep_running : bool = false) -> void:
#	print("Changing scene to ", new_scene)
	pauseButton.visible = false 
	if current_scene == null:
		pass
#		print("Current scene : ", current_scene, " is null ")
	else:
		pass
	#	print("Current scene is : ", current_scene)
	if current_scene != null:
		if delete:
			#print("Delete Here",current_scene)
			current_scene.queue_free() # Removes Node Entirely 
		elif keep_running:
			current_scene.visible = false # Keeps in memory and running 
		else:
			
			#print("RRemoved Child")
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






func show_guide():
	#print("Current Scene is ",	current_scene)
	if current_scene:
		current_scene.show_guide()	
		current_alt_scene.show_guide()	
	
func clear_guide():
	#print("Current Scene is ",	current_scene)
	if current_scene:
		current_scene.hide_guide()	
		current_alt_scene.hide_guide()	
		
func register_heart_alt_scene(new_hero_demon):
	if current_scenes[1].visible == false :
		current_scenes[1].get_child(0).hero_demon = new_hero_demon
	elif current_scenes[0].visible == false :
		current_scenes[0].get_child(0).hero_demon = new_hero_demon
