shader_type canvas_item;

uniform vec4 blood_color : source_color = vec4(0.6, 0.0, 0.0, 1.0);
uniform bool active = false;
instance uniform float hit_flash : hint_range(0.0, 1.0) = 0.0;

void fragment() {
	if (active) {
		vec4 tex = texture(TEXTURE, UV);
		COLOR = vec4(blood_color.rgb, tex.a * blood_color.a * COLOR.a);
	}
	COLOR.rgb = mix(COLOR.rgb, vec3(1.0), hit_flash);
}
