  shader_type canvas_item;
  render_mode unshaded;

  // Position of spotlight center in UV coordinates (0.0-1.0)
  uniform vec2 circle_position = vec2(0.5, 0.5);

  // Radius of spotlight in UV coordinates
  uniform float circle_size : hint_range(0.0, 0.5) = 0.15;

  // How dark the overlay is (0.0 = invisible, 1.0 = fully black)
  uniform float dimming : hint_range(0.0, 1.0) = 0.75;

  // Soft edge transition width
  uniform float edge_softness : hint_range(0.0, 0.1) = 0.03;

  void fragment() {
      // Calculate distance from current pixel to spotlight center
      float dist = distance(circle_position, UV);

      // Create smooth circular mask
      // 0.0 = inside spotlight (clear)
      // 1.0 = outside spotlight (dimmed)
      float mask = smoothstep(circle_size - edge_softness, circle_size + edge_softness, dist);

      // Apply dimming - black overlay with variable alpha
      COLOR = vec4(0.0, 0.0, 0.0, mask * dimming);
  }