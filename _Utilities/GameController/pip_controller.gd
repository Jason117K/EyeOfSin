extends Control
# pip_controller.gd — view-only picture-in-picture of the inactive dimension.

@onready var _view: TextureRect = $PanelContainer/PipView#$PipView
@onready var _backdrop: ColorRect = $Backdrop
@onready var _viewport: SubViewport = get_parent().get_node("PipViewport")
@onready var _pip_camera: Camera2D = _viewport.get_node("PipCamera")
@onready var panel_container: PanelContainer = $PanelContainer
var _restamp_accum := 0.0
#const SMALL_RECT := Rect2(530, 300, 200, 102)   # bottom-right corner
const SMALL_RECT := Rect2(530, 325, 200, 82)
const LARGE_RECT := Rect2(70, 36, 600, 340)     # big centered overlay

var _mirror_camera: Camera2D = null              # inactive dimension's Camera2D
var enlarged := false


func _ready() -> void:
	# Share the main world so both dimensions render from the same scene tree.
	_viewport.world_2d = get_viewport().world_2d
	_pip_camera.enabled = false          # don't let it override canvas_transform
	#_view.texture = _viewport.get_texture()
	_apply_rect(SMALL_RECT)
	visible = false
	visibility_layer = 1 << 9        # PipRoot, reserved "PiP chrome" layer (512)
	_backdrop.visibility_layer = 1 << 9
	_view.visibility_layer = 1 << 9


func _process(dt: float) -> void:
	pass
	#_viewport.canvas_transform = get_viewport().canvas_transform
	#_restamp_accum += dt
	#if _restamp_accum >= 0.25:
		#_restamp_accum = 0.0
		#var gc = Global.game_controller
		#if gc.current_scenes.size() == 2:
			#gc.y(gc.current_scenes[0], gc.DIM_BITS[0])
			#gc._stamp_scene(gc.current_scenes[1], gc.DIM_BITS[1])



func set_mirror_camera(cam: Camera2D) -> void:
	_mirror_camera = cam


func set_pip_cull_mask(bit: int) -> void:
	_viewport.canvas_cull_mask = bit | 1
	#print("Setting Cull Mask To ", bit, " (actual mask: ", bit | 1, ")")
	if bit == 4:
		#_set_pip_border(Color("1e0530"))
		_set_pip_border(Color("042b17"))
	else:
		#_set_pip_border(Color("042b17"))
		_set_pip_border(Color("1e0530"))
	
	
func _set_pip_border(color: Color) -> void:
	var stylebox := panel_container.get_theme_stylebox("panel").duplicate() as StyleBoxFlat
	stylebox.border_color = color
	panel_container.add_theme_stylebox_override("panel", stylebox)

func show_pip() -> void:
	#print("Pip Should SHow")
	visible = true


func hide_pip() -> void:
	#print("Pip Should Hide")
	visible = false


func toggle_size() -> void:
	enlarged = not enlarged
	_backdrop.visible = enlarged
	_apply_rect(LARGE_RECT if enlarged else SMALL_RECT)


func _apply_rect(r: Rect2) -> void:
	_view.position = r.position
	_view.size = r.size
