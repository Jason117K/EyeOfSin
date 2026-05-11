@tool
extends TileMapLayer

@export var make_green := false

@export var rectangle_scene: PackedScene

## Container for spawned rectangle instances (for management/cleanup)
var spawned_rectangles: Array[Node2D] = []
## Amount to shift hue (0.0 to 1.0, wraps around)
@export_range(0.0, 1.0, 0.01) var hue_shift: float = 0.0:
	set(value):
		hue_shift = value
		_update_hue_shift()

var _shader_material: ShaderMaterial

func _ready() -> void:
	#print("Rect Ready Called")
	#place_rectangles_on_rows(2, 8)
	if make_green:
		_setup_shader()

func _setup_shader() -> void:
	var shader = Shader.new()
	shader.code = """
shader_type canvas_item;

uniform float hue_shift : hint_range(0.0, 1.0) = 0.0;

vec3 rgb_to_hsv(vec3 c) {
	vec4 K = vec4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
	vec4 p = mix(vec4(c.bg, K.wz), vec4(c.gb, K.xy), step(c.b, c.g));
	vec4 q = mix(vec4(p.xyw, c.r), vec4(c.r, p.yzx), step(p.x, c.r));
	
	float d = q.x - min(q.w, q.y);
	float e = 1.0e-10;
	return vec3(abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
}

vec3 hsv_to_rgb(vec3 c) {
	vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
	vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
	return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

void fragment() {
	vec4 color = texture(TEXTURE, UV);
	
	if (color.a > 0.01) {
		vec3 hsv = rgb_to_hsv(color.rgb);
		hsv.x = fract(hsv.x + hue_shift);
		color.rgb = hsv_to_rgb(hsv);
	}
	
	COLOR = color;
}
"""
	
	_shader_material = ShaderMaterial.new()
	_shader_material.shader = shader
	modulate = Color.WHITE  # Ensure modulate isn't affecting things
	self_modulate = Color.WHITE
	material = _shader_material
	_update_hue_shift()

func _update_hue_shift() -> void:
	if _shader_material and is_instance_valid(_shader_material):
		_shader_material.set_shader_parameter("hue_shift", hue_shift)

## Call this function to change the hue shift at runtime
func set_hue_shift_value(value: float) -> void:
	hue_shift = value
	
	
	
	
	
## Places rectangle sprites centered over each tile in the specified row range.
## start_row: First row (inclusive)
## end_row: Last row (inclusive)
func place_rectangles_on_rows(start_row: int, end_row: int) -> void:
	#print("rectrectrectrectrectrectrect")
	if rectangle_scene == null:
		push_error("Rectangle scene not assigned!")
		return
	
	# Validate row range
	if start_row > end_row:
		push_warning("start_row > end_row, swapping values")
		var temp := start_row
		start_row = end_row
		end_row = temp
	
	# Get all used cells and filter by row
	var used_cells := get_used_cells()
	#print("Spawn Rectttvvvvvvvvvvvvvt")
	for cell_coords in used_cells:
		#print("Spawn Rectzzzzzzttt")
		if cell_coords.y >= start_row and cell_coords.y <= end_row:
			#print("Spawn Recttttppppp")
			_spawn_rectangle_at_cell(cell_coords)
			
	#print("All Rectangles Should be placed on rows")			
	## Spawns a single rectangle centered on the given tile cell
func _spawn_rectangle_at_cell(cell_coords: Vector2i) -> void:
#	print("Spawn Rectttt")
	var rect_instance: Node2D = rectangle_scene.instantiate()
	rect_instance.scale = Vector2(0.2,0.356)
	rect_instance.z_index = 2
	
	# Get the center position of the tile in local coordinates
	var tile_center := map_to_local(cell_coords)
	
	rect_instance.position = tile_center
	add_child(rect_instance)
	spawned_rectangles.append(rect_instance)


## Clears all spawned rectangles
func clear_rectangles() -> void:
	for rect in spawned_rectangles:
		if is_instance_valid(rect):
			rect.queue_free()
	spawned_rectangles.clear()
	
