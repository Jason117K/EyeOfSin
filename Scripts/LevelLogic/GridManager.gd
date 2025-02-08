extends Node2D
#GridManager.gd

#Stores a reference to the game tilemap 
onready var tilemap = $TileMap2

#Handles Setting Up the Game's tiles correctly for a given level

# Function to set tiles in a given range of rows 
func set_tiles_for_rows(row_start:int, row_end: int, tile_id: int):
	 # Get the number of columns in the tilemap (you can also use your own logic to define it)
	var map_width = tilemap.get_used_rect().size.x
	# Loop through the specified number of rows
	for y in range(row_start,row_end):
		# Loop through each column in the row
		for x in range(map_width):
			# Set the tile at (x, y) to the specified tile_id
			tilemap.set_cell(x, y, tile_id)



	
