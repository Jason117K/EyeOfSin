extends TileMap

var show_debug_grid = true

func _ready():
	update()

func _input(event):
	if event.is_action_pressed("toggle_grid"):
		show_debug_grid = !show_debug_grid
		update()

func _draw():
	if not show_debug_grid:
		return
		
	print("Drawing")
	var cell_size = get_cell_size()
	var used_cells = get_used_cells()
	
	# Get the viewport size to determine how far to draw the grid
	var viewport_size = get_viewport_rect().size
	var start_pos = world_to_map(Vector2.ZERO)
	var end_pos = world_to_map(viewport_size)
	
	# Draw vertical lines
	for x in range(start_pos.x - 1, end_pos.x + 1):
		var from = map_to_world(Vector2(x, start_pos.y - 1))
		var to = map_to_world(Vector2(x, end_pos.y + 1))
		draw_line(from, to, Color(1, 1, 1, 1), 9.0)  # White color, thickness 2.0
	
	# Draw horizontal lines
	for y in range(start_pos.y - 1, end_pos.y + 1):
		var from = map_to_world(Vector2(start_pos.x - 1, y))
		var to = map_to_world(Vector2(end_pos.x + 1, y))
		draw_line(from, to, Color(1, 1, 1, 1), 2.0)  # White color, thickness 2.0
