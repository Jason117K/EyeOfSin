extends Node2D

@onready var tilemapLayer := $TileMapLayer
var block_layer : TileMapLayer

# Define the grid dimensions for your game
const GRID_COLUMNS = 24  # Adjust based on your game's design
const GRID_ROWS = 13      # Adjust based on your game's design

@export var make_green := false

func _ready() -> void:
	tilemapLayer._ready()
	for tilemap_layer_child in self.get_children():
		if "Block" in tilemap_layer_child.name:
			block_layer = tilemap_layer_child

	if make_green:
		tilemapLayer.make_green = true
		tilemapLayer._setup_shader()
		
#		$TileMapLayer4._setup_shader()
		if block_layer != null:
			block_layer._setup_shader()
		
	

func is_blocked(grid_pos:Vector2)->bool:
	if block_layer != null:
		grid_pos = block_layer.local_to_map(block_layer.to_local(grid_pos))
		var data: TileData = block_layer.get_cell_tile_data(grid_pos)
		if data == null:
			return false 
		#print("Return ", data.get_custom_data("block"))
		return data.get_custom_data("block")	
		
	else:
		return false 

# Function to set tiles in a given range of rows
func set_tiles_for_rows(row_start: int, row_end: int, tile_id: int) -> void:
	# Use predefined grid width instead of get_used_rect()
	var map_width := GRID_COLUMNS
	
	# Alternatively, calculate based on viewport and tile size:
	# var tile_size = tilemapLayer.tile_set.tile_size
	# var map_width = int(get_viewport().size.x / tile_size.x)
	
	# With TileMapLayer, we don't need to specify layer index
	# We just need:
	# - coords (Vector2i for the tile position)
	# - source_id (typically 0 for the first tileset)
	# - atlas_coords (Vector2i for the tile coordinates in the atlas)
	
	var source_id := tile_id  # First tileset source

	# Calculate atlas coordinates from tile_id
	# Adjust this based on how your tileset is organized
	var atlas_coords := Vector2i(0, 0)
	
	# If your tileset has multiple rows of tiles:
	# var tileset_columns = 10  # Number of columns in your tileset
	# var atlas_x = tile_id % tileset_columns
	# var atlas_y = tile_id / tileset_columns
	# var atlas_coords = Vector2i(atlas_x, atlas_y)
	
	# Loop through the specified rows
	for y in range(row_start, row_end):
		# Loop through each column in the row
		for x in range(map_width):
			tilemapLayer.set_cell(Vector2i(x, y), source_id, atlas_coords)

# Alternative function that takes explicit grid dimensions
func set_tiles_for_rows_with_width(row_start: int, row_end: int, tile_id: int, grid_width: int) -> void:
	var source_id := 0
	var atlas_coords := Vector2i(tile_id, 0)
	
	for y in range(row_start, row_end):
		for x in range(grid_width):
			tilemapLayer.set_cell(Vector2i(x, y), source_id, atlas_coords)
