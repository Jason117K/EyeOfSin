@tool
extends TileMapLayer

var make_green := false

## Amount to shift hue (0.0 to 1.0, wraps around)
@export_range(0.0, 1.0, 0.01) var hue_shift: float = 0.0:
	set(value):
		hue_shift = value
		_update_hue_shift()

var _shader_material: ShaderMaterial

func _ready() -> void:
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
