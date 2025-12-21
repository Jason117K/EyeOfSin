extends Node2D

@onready var selection_menu = get_parent().get_parent().get_node("PlantSelectionMenu")
@export var map : TileMapLayer 
var astar_grid: AStarGrid2D

var ranAlready := false 

func _ready():
	astar_grid = AStarGrid2D.new()
	astar_grid.cell_size = map.tile_set.tile_size
	print("MY GIRD CELL SIZE IS ", astar_grid.cell_size)
	astar_grid.region = Rect2(Vector2.ZERO, (ceil(get_viewport_rect().size/astar_grid.cell_size)) * 2)
	astar_grid.update()
	
	for id in map.get_used_cells():
		
		var data = map.get_cell_tile_data(id)
		if data and data.get_custom_data('obstacle'):
			print("Set ", id, " solid")
			astar_grid.set_point_solid(id)
			
	Global.register_grid(astar_grid)
	
	
func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			var mouse_pos: Vector2 = map.get_global_mouse_position()
			var cell_coords: Vector2i = map.local_to_map(to_local(mouse_pos))
			print("Cell Coords: ", cell_coords, selection_menu.selected_plant_name)
			if (selection_menu.selected_plant_name != null):
				print("Selected Name is ", selection_menu.selected_plant_name)
				if selection_menu.selected_plant_name.contains("Walnut"):
					
					print("MY MARK SOLID")
					astar_grid.set_point_solid(cell_coords)
					Global.set_solid_point(cell_coords)
					# Example: Set cell at (5, 3) to use source 0, atlas position (2, 1)
					#map.set_cell(Vector2i(5, 3), 0, Vector2i(2, 1))
					map.set_cell(cell_coords, 3, Vector2i(0, 0))
					Global.register_grid(astar_grid)
			#if selection_menu.selected_plant
			#astar_grid.set_point_solid(id)


			
				
#func _input(event: InputEvent) -> void:
	#if event is InputEventMouseButton and event.pressed:
		#if event.button_index == MOUSE_BUTTON_LEFT:
			#var mouse_pos: Vector2 = map.get_global_mouse_position()
			#var cell_coords: Vector2i = map.local_to_map(to_local(mouse_pos))
			#var source_id: int = map.get_cell_source_id(cell_coords)
			#var atlas_coords: Vector2i = map.get_cell_atlas_coords(cell_coords)
			#var alternative_tile: int = map.get_cell_alternative_tile(cell_coords)
			#
			#print("Cell Coords: ", cell_coords)
			#print("Source ID: ", source_id)
			#print("Atlas Coords: ", atlas_coords)
			#print("Alternative Tile: ", alternative_tile)
