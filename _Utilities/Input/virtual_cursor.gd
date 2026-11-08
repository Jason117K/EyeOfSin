class_name VirtualCursor
extends CanvasLayer
## Stick-driven pointer for controllers. It moves the real OS mouse, so every
## hover, physics-picking and GUI path that works with a mouse works unchanged.

const CURSOR_TEXTURE := preload("res://_Assets/Lock.png")
const STICK_DEADZONE := 0.2
const DOUBLE_CLICK_MSEC := 400
const DOUBLE_CLICK_DISTANCE := 6.0
const SCROLL_REPEAT_SECONDS := 0.08
# Warp motion lands within a pixel of the cursor after the stretch round trip.
const WARP_MATCH_DISTANCE := 1.5

@export var max_speed := 260.0
@export var response_exponent := 2.0

var _sprite := Sprite2D.new()
var _position := Vector2.ZERO
var _controller_active := false
var _last_press_msec := -DOUBLE_CLICK_MSEC
var _last_press_position := Vector2.INF
var _scroll_cooldown := 0.0


func _ready() -> void:
	layer = 128
	process_mode = Node.PROCESS_MODE_ALWAYS
	_sprite.texture = CURSOR_TEXTURE
	_sprite.visible = false
	add_child(_sprite)
	_position = get_viewport().get_visible_rect().get_center()


func _process(delta: float) -> void:
	var real_delta := delta / Engine.time_scale if Engine.time_scale > 0.0 else delta
	var stick := _strongest_stick(JOY_AXIS_LEFT_X, JOY_AXIS_LEFT_Y)
	if stick != Vector2.ZERO:
		_activate_controller()
		var speed := pow(stick.length(), response_exponent) * max_speed
		move_to(_position + stick.normalized() * speed * real_delta)
	_scroll(real_delta)


func _input(event: InputEvent) -> void:
	if event is InputEventJoypadButton and event.button_index == JOY_BUTTON_A:
		get_viewport().set_input_as_handled()
		_activate_controller()
		_send_left_button(event.pressed)
	elif event is InputEventMouseMotion and not _is_own_warp(event):
		_deactivate_controller(event.position)


func move_to(viewport_position: Vector2) -> void:
	_position = viewport_position.clamp(Vector2.ZERO, get_viewport().get_visible_rect().size)
	_sprite.position = _position
	Input.warp_mouse(_to_window(_position))


func snap_to(control: Control) -> void:
	move_to(control.get_global_rect().get_center())


func _activate_controller() -> void:
	if _controller_active:
		return
	_controller_active = true
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
	_sprite.visible = true
	move_to(_position)


func _deactivate_controller(mouse_position: Vector2) -> void:
	_position = mouse_position
	if not _controller_active:
		return
	_controller_active = false
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	_sprite.visible = false


func _is_own_warp(motion: InputEventMouseMotion) -> bool:
	return _controller_active and motion.position.distance_to(_position) <= WARP_MATCH_DISTANCE


func _send_left_button(pressed: bool) -> void:
	var click := _make_button_event(MOUSE_BUTTON_LEFT, pressed)
	if pressed:
		var now := Time.get_ticks_msec()
		click.double_click = now - _last_press_msec <= DOUBLE_CLICK_MSEC \
				and _position.distance_to(_last_press_position) <= DOUBLE_CLICK_DISTANCE
		_last_press_msec = -DOUBLE_CLICK_MSEC if click.double_click else now
		_last_press_position = _position
	Input.parse_input_event(click)


func _scroll(real_delta: float) -> void:
	_scroll_cooldown = maxf(_scroll_cooldown - real_delta, 0.0)
	var vertical := _strongest_stick(JOY_AXIS_RIGHT_X, JOY_AXIS_RIGHT_Y).y
	if vertical == 0.0 or _scroll_cooldown > 0.0:
		return
	_activate_controller()
	_scroll_cooldown = SCROLL_REPEAT_SECONDS
	var wheel := MOUSE_BUTTON_WHEEL_DOWN if vertical > 0.0 else MOUSE_BUTTON_WHEEL_UP
	for pressed: bool in [true, false]:
		var event := _make_button_event(wheel, pressed)
		event.factor = absf(vertical)
		Input.parse_input_event(event)


func _make_button_event(button: MouseButton, pressed: bool) -> InputEventMouseButton:
	var event := InputEventMouseButton.new()
	event.button_index = button
	event.pressed = pressed
	event.position = _to_window(_position)
	event.global_position = event.position
	if pressed:
		event.button_mask = Input.get_mouse_button_mask() | (1 << (button - 1))
	else:
		event.button_mask = Input.get_mouse_button_mask() & ~(1 << (button - 1))
	return event


func _to_window(viewport_position: Vector2) -> Vector2:
	return get_viewport().get_screen_transform() * viewport_position


# The Deck can expose more than one pad, so the strongest tilt wins rather than device 0.
func _strongest_stick(x_axis: JoyAxis, y_axis: JoyAxis) -> Vector2:
	var strongest := Vector2.ZERO
	for device in Input.get_connected_joypads():
		var tilt := Vector2(Input.get_joy_axis(device, x_axis), Input.get_joy_axis(device, y_axis))
		if tilt.length() > strongest.length():
			strongest = tilt
	if strongest.length() < STICK_DEADZONE:
		return Vector2.ZERO
	return strongest.limit_length(1.0)
