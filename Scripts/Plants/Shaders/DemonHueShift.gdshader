shader_type canvas_item;

uniform float hue_shift_degrees : hint_range(-180, 180) = 0.0;
uniform vec4 target_color : source_color;
uniform vec4 replace_color : source_color;
uniform vec4 glow_color : source_color = vec4(223,66,66,256);
const vec4 modulate_factor = vec4(7, 7,7, 1.0);
//uniform vec4 modulate_factor : source_color = vec4(1.1, 1.1, 1.1, 1.0);
uniform float tolerance : hint_range(0.0, 1.0);
const float glow_tolerance = 0.2;
//uniform float glow_tolerance : hint_range(0.0, 1.0) = 0.5;

// Optimized HSV conversion
vec3 rgb2hsv(vec3 c) {
    vec4 K = vec4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
    vec4 p = c.g < c.b ? vec4(c.bg, K.wz) : vec4(c.gb, K.xy);
    vec4 q = c.r < p.x ? vec4(p.xyw, c.r) : vec4(c.r, p.yzx);

    float d = q.x - min(q.w, q.y);
    float e = 1.0e-10;
    return vec3(abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
}

vec3 hsv2rgb(vec3 c) {
    vec3 rgb = clamp(abs(fract(c.x + vec3(0.0, 2.0/3.0, 1.0/3.0)) * 6.0 - 3.0) - 1.0, 0.0, 1.0);
    return c.z * mix(vec3(1.0), rgb, c.y);
}

void fragment() {
	vec4 first_tex_color = texture(TEXTURE, UV);
		// Apply modulation to pixels matching glow_color
	float glow_dist = distance(first_tex_color.rgb, glow_color.rgb);
	if (glow_dist < glow_tolerance) {
		first_tex_color *= modulate_factor;
	}
	COLOR = first_tex_color;
    //vec4 tex_color = texture(TEXTURE, UV);
	vec4 tex_color = first_tex_color;
    if (tex_color.a == 0.0) discard;

    vec3 hsv = rgb2hsv(tex_color.rgb);

    // Convert degrees to hue fraction (-0.5 to 0.5 range)
    float hue_fraction = hue_shift_degrees / 360.0;

    // Apply shift with wrap-around
    hsv.x = fract(hsv.x + hue_fraction + 1.0);

    vec3 rgb = hsv2rgb(hsv);
    COLOR = vec4(rgb, tex_color.a);

	vec4 alternate_tex_color = vec4(rgb, tex_color.a);

    float dist = distance(alternate_tex_color.rgb, target_color.rgb);
	if (dist < tolerance) {
        alternate_tex_color.rgb = replace_color.rgb;
    }



    COLOR = alternate_tex_color;
}