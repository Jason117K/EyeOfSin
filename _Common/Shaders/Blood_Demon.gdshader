shader_type canvas_item;

// Replaces every visible pixel of the sprite with a flat color.
// Alpha of the original texture is preserved so the silhouette stays intact.
uniform vec4 blood_color : source_color = vec4(0.6, 0.0, 0.0, 1.0);
// When false, the sprite renders normally with no color replacement.
uniform bool active = false;

void fragment() {
	
	if (active) {
		vec4 tex = texture(TEXTURE, UV);
		COLOR = vec4(blood_color.rgb, tex.a * blood_color.a * COLOR.a);
	} 
}
