extends Area2D
#BaseZombie.gd

class_name Zombie 
# Defines basic behavior for all zombie types

signal zombie_death

@onready var compManager = $ComponentManager
@onready var speedComp = $SpeedComponent

var slow_field_scene = preload("res://Scenes/PlantScenes/web_tile_slow.tscn")
var grid: AStarGrid2D

const SPEED = 100.0
var cur_pt : int 
var moving : bool:
	set(v):
		moving = v; set_physics_process(moving)
var current_cell: Vector2i
var target_cell:  Vector2i
var move_pts: Array 
var isSetup := false 

func setup(_grid: AStarGrid2D, _targetCell : Vector2):
	#print("My SETUP CALLED")
	grid = _grid 
	current_cell = pos_to_cell(global_position)
	target_cell = _targetCell
	#target_cell = current_cell
	move_pts = grid.get_point_path(current_cell,Vector2i(pos_to_cell(_targetCell)))
	#print("111Grid is ",grid)
	#print("111Current cell is ",current_cell)
	#print("111Target Cell is ",target_cell)
	#print(current_cell, "MY MOVE PTS IS NOW ", move_pts, Vector2i(pos_to_cell(_targetCell)))
	move_pts = (move_pts as Array).map(func (p): return p + grid.cell_size / 2.0)
	target_cell = Vector2i(pos_to_cell(_targetCell))
	#move_pts.append(current_cell)
#	print("MY MOVE PTS IS ", move_pts)
	#print("My SETUP DONE")
	isSetup = true 

func pos_to_cell(pos:Vector2):
	return pos/ grid.cell_size

func _ready() -> void:
	moving = false
	#start_move()
	if self.is_in_group("Green"):
		print("SET TO GTREEEEEEEN SO CAN ATTTACK GREEEN")
		self.set_collision_layer_value(1,false)
		self.set_collision_layer_value(2,false)
		self.set_collision_layer_value(3,true)
	else:
		self.set_collision_layer_value(1,false)
		self.set_collision_layer_value(2,true)
		self.set_collision_layer_value(3,false)
	start_move()	
func start_move():
	if move_pts.is_empty(): return 
	cur_pt = 0; moving = true 		
		
		
# Component Manager Getter
func getCompManager():
	return compManager

# Tells Comp Manager the Zombie is Fighting a Hive Drone 
func fightDrone():
	compManager.fightDrone()

func make_spawn_slow_on_death():
	compManager.spawn_slow_field = true 
	
	
# Tells Comp Manager the Zombie Stopped Fighting a Hive Drone 
func stopFightingDrone():
	compManager.stopFightingDrone()

#Tells Comp Manager This Zombie Will Explode When Killed 
func fightDroneExplode():
	compManager.fightDroneExplode()
	
#Tells Comp Manager to execute this Zombie's special move
func special_move():
	compManager.special_move()

#TODO Pick Up Here Left Off Here 
func set_hue_shift(hue_shift_degrees):
	compManager.set_hue_shift(hue_shift_degrees)
	
#Kills the Zombie 
func die():
	if compManager.spawn_slow_field == true :
		spawn_slow_field_on_death()
	#if compMana
	print("Should die")
	zombie_death.emit()
	queue_free()

func spawn_slow_field_on_death():
	var slow_field
	slow_field = slow_field_scene.instantiate()
	slow_field.global_position = self.global_position
	#slow_field.position = position + Vector2(32, 8)  # Adjust starting position
	get_parent().add_child(slow_field)  # Add the projectile to the game layer DOUBLE CHECK

func _process(delta: float) -> void:
	if isSetup:
		pass
		#move_pts = grid.get_point_path(current_cell,Vector2i(pos_to_cell(target_cell)))
	#print("My  PRoCESS DEL", move_pts.size())
	if cur_pt == move_pts.size() - 1:
		#velocity = Vector2.ZERO
		global_position = move_pts[-1]
		current_cell = pos_to_cell(global_position)
	else:
	#	print("MY MOVE 3333PTS IS ", move_pts)
	#	print("333cur_pt:",cur_pt)
		#if (cur_pt + 1)  <= move_pts.size():
		
		var dir = (move_pts[cur_pt + 1] - move_pts[cur_pt]).normalized()
		if (move_pts[cur_pt + 1] - global_position).length() < 4:
			current_cell = pos_to_cell(global_position)
			cur_pt += 1
	#print("My My Setting Movement Target")
		speedComp.set_movement_target(move_pts[cur_pt + 1])
	
#func _physics_process(delta: float) -> void:
	#print("My PHYSIC PRoCESS DEL")
	#if cur_pt == move_pts.size() - 1:
		##velocity = Vector2.ZERO
		#global_position = move_pts[-1]
		#current_cell = pos_to_cell(global_position)
	#else:
		#var dir = (move_pts[cur_pt + 1] - move_pts[cur_pt]).normalized()
		#if (move_pts[cur_pt + 1] - global_position).length() < 4:
			#current_cell = pos_to_cell(global_position)
			#cur_pt += 1
	#print("My My Setting Movement Target")
	#speedComp.set_movement_target(move_pts[cur_pt + 1])
	#
func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if Global.solidPointSet:
				pass
				#grid = Global.get_grid()
				#grid.set_point_solid(Global.get_solid_point())
				#print("222Grid is ",grid)
				#print("222Current cell is ",current_cell)
				#print("222Target Cell is ",target_cell)
				#move_pts = grid.get_point_path(current_cell,Vector2i(pos_to_cell(target_cell)))
				#print("MY MOVE 2222222PTS IS ", move_pts)
			#print(current_cell, "MY MOVE PTS IS NOW ", move_pts, Vector2i(pos_to_cell(target_cell)))
			#move_pts = (move_pts as Array).map(func (p): return p + grid.cell_size / 2.0)
