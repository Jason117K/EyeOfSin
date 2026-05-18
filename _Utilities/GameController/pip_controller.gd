extends Control
# pip_controller.gd — view-only picture-in-picture of the inactive dimension.

@onready var _view: TextureRect = $PipView
@onready var _backdrop: ColorRect = $Backdrop
@onready var _viewport: SubViewport = get_parent().get_node("PipViewport")
@onready var _pip_camera: Camera2D = _viewport.get_node("PipCamera")

const SMALL_RECT := Rect2(530, 300, 200, 102)   # bottom-right corner
const LARGE_RECT := Rect2(70, 36, 600, 340)     # big centered overlay

var _mirror_camera: Camera2D = null              # inactive dimension's Camera2D
var enlarged := false


func _ready() -> void:
	# Share the main world so both dimensions render from the same scene tree.
	_viewport.world_2d = get_viewport().world_2d
	_pip_camera.enabled = true
	_pip_camera.make_current()                   # current within the SubViewport only
	_view.texture = _viewport.get_texture()
	_apply_rect(SMALL_RECT)
	visible = false


func _process(_dt: float) -> void:
	if _mirror_camera and is_instance_valid(_mirror_camera):
		_pip_camera.global_transform = _mirror_camera.global_transform
		_pip_camera.zoom = _mirror_camera.zoom


func set_mirror_camera(cam: Camera2D) -> void:
	_mirror_camera = cam


func set_pip_cull_mask(mask: int) -> void:
	_viewport.canvas_cull_mask = mask


func show_pip() -> void:
	visible = true


func hide_pip() -> void:
	visible = false


func toggle_size() -> void:
	enlarged = not enlarged
	_backdrop.visible = enlarged
	_apply_rect(LARGE_RECT if enlarged else SMALL_RECT)


func _apply_rect(r: Rect2) -> void:
	_view.position = r.position
	_view.size = r.size
