## Pulsing button/panel highlight FX (border + glow tween on any Control).
## Single home for the helper that was previously copy-pasted in Global,
## ToolTips, and DemonSelectionMenu. State rides on the target node via metas
## ("highlight_panel", "glow_tween"), so these can be static.
class_name UiFx extends RefCounted

const DEFAULT_BORDER_THICKNESS: int = 1
const DEFAULT_BORDER_COLOR: Color = Color.RED


static func add_pulsing_button_highlight(button, should_pulse : bool = true,
		border_color: Color = DEFAULT_BORDER_COLOR,
		border_thickness: int = DEFAULT_BORDER_THICKNESS) -> void:
	if not button:
		push_error("Button node is null!")
		return
	# Remove any existing highlight. Untyped fetch: the meta may hold a freed
	# panel, and assigning a freed instance to a typed var is a runtime error.
	if button.has_meta("highlight_panel"):
		var old = button.get_meta("highlight_panel")
		if is_instance_valid(old):
			old.queue_free()
		button.remove_meta("highlight_panel")

	# Create a Panel as a child to act as the border/glow
	var panel := Panel.new()
	panel.name = "HighlightPanel"
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE  # Don't eat clicks

	button.add_child(panel)

	panel.size = button.size
	panel.z_index = 2

	# Build the stylebox for the panel
	var highlight_style := StyleBoxFlat.new()
	highlight_style.bg_color = Color.TRANSPARENT
	highlight_style.border_width_left = border_thickness
	highlight_style.border_width_right = border_thickness
	highlight_style.border_width_top = border_thickness
	highlight_style.border_width_bottom = border_thickness
	highlight_style.border_color = border_color
	highlight_style.shadow_color = Color(border_color, 0.5)
	highlight_style.shadow_size = 2
	highlight_style.shadow_offset = Vector2.ZERO
	highlight_style.corner_radius_top_left = 2
	highlight_style.corner_radius_top_right = 2
	highlight_style.corner_radius_bottom_left = 2
	highlight_style.corner_radius_bottom_right = 2

	panel.add_theme_stylebox_override("panel", highlight_style)
	button.set_meta("highlight_panel", panel)

	if should_pulse:
		start_glow_pulse(button, panel, highlight_style, border_color)


static func start_glow_pulse(button, _panel: Panel, style: StyleBoxFlat,
		glow_color: Color = DEFAULT_BORDER_COLOR) -> void:
	if button.has_meta("glow_tween"):
		var old_tween: Tween = button.get_meta("glow_tween")
		if old_tween and old_tween.is_valid():
			old_tween.kill()

	var tween: Tween = button.create_tween()
	tween.set_loops()

	tween.tween_method(
		func(val: int) -> void:
			style.shadow_size = int(lerpf(4, 8, val))
			style.shadow_color = Color(glow_color, lerpf(0.2, 0.4, val)),
		0.0, 1.0, 1.2
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

	tween.tween_method(
		func(val: int) -> void:
			style.shadow_size = int(lerpf(8, 4, val))
			style.shadow_color = Color(glow_color, lerpf(0.4, 0.2, val)),
		0.0, 1.0, 1.2
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

	button.set_meta("glow_tween", tween)


static func stop_glow_pulse(button) -> void:
	if button.has_meta("glow_tween"):
		var tween: Tween = button.get_meta("glow_tween")
		if tween and tween.is_valid():
			tween.kill()
		button.remove_meta("glow_tween")

	# Remove the highlight panel (untyped fetch — see add_pulsing_button_highlight)
	if button.has_meta("highlight_panel"):
		var panel = button.get_meta("highlight_panel")
		if is_instance_valid(panel):
			panel.queue_free()
		button.remove_meta("highlight_panel")
	if button.get_child_count() > 0 and button.get_child(0).name == "HighlightPanel":
		button.get_child(0).queue_free()


static func remove_pulsing_button_highlight(button) -> void:
	if button.has_meta("glow_tween"):
		var tw: Tween = button.get_meta("glow_tween")
		if tw and tw.is_valid():
			tw.kill()
		button.remove_meta("glow_tween")
	if button.has_meta("highlight_panel"):
		var p = button.get_meta("highlight_panel")
		if is_instance_valid(p):
			p.queue_free()
		button.remove_meta("highlight_panel")
