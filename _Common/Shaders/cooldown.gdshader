shader_type canvas_item;

uniform float fill_amount : hint_range(0.0, 1.0) = 0.0;
uniform vec4 fill_color : source_color = vec4(1.0, 0.0, 0.0, 1.0);
uniform vec4 empty_color : source_color = vec4(0.0, 0.0, 0.0, 0.0);

void fragment() {
    // UV.y is 0.0 at the top, 1.0 at the bottom
    // We want to fill from bottom up, so we invert it
    float from_bottom = 1.0 - UV.y;

    if (from_bottom <= fill_amount) {
        COLOR = fill_color;
    } else {
        COLOR = empty_color;
    }
}