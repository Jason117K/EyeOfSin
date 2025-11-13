shader_type canvas_item;

uniform float outline_width = 2.0;
uniform vec4 outline_color : source_color = vec4(1.0, 0.7, 0.0, 1.0);

void fragment() {
	vec4 texture_color = texture(TEXTURE, UV);
	
	// Check if we're at the edge of the texture
	float alpha = texture_color.a;
	
	// Sample points around current pixel
	vec2 size = vec2(outline_width) / vec2(textureSize(TEXTURE, 0));
	
	float outline = 0.0;
	outline += texture(TEXTURE, UV + vec2(0.0, size.y)).a;
	outline += texture(TEXTURE, UV + vec2(size.x, 0.0)).a;
	outline += texture(TEXTURE, UV + vec2(0.0, -size.y)).a;
	outline += texture(TEXTURE, UV + vec2(-size.x, 0.0)).a;
	outline = min(outline, 1.0) - alpha;
	
	// Apply the outline if we're at the edge
	COLOR = mix(texture_color, outline_color, outline);
}
