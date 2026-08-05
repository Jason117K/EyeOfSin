extends Sprite2D

@export var breathing: bool = true:
	set(value):
		breathing = value
		if is_node_ready():
			if breathing:
				_start_breathing()
			else:
				_stop_breathing()

@export var min_scale: float = 0.6
@export var max_scale: float = 0.9
@export var breath_duration: float = 1.0

var default_self_modulate := Color("00000081")
@export var hover_self_modulate : Color
var _breath_tween: Tween
var _initial_scale: Vector2


func _ready() -> void:
	_initial_scale = scale
	##print("Rect Is Alive")
	visibility_layer = get_parent().get_parent().visibility_layer
	if breathing:
		_start_breathing()


func _start_breathing() -> void:
	_stop_breathing()
	
	scale = _initial_scale * min_scale
	
	_breath_tween = create_tween()
	_breath_tween.set_trans(Tween.TRANS_SINE)
	_breath_tween.set_ease(Tween.EASE_IN_OUT)
	_breath_tween.set_loops()
	
	_breath_tween.tween_property(self, "scale", _initial_scale * max_scale, breath_duration)
	_breath_tween.tween_property(self, "scale", _initial_scale * min_scale, breath_duration)


func _stop_breathing() -> void:
	if _breath_tween and _breath_tween.is_valid():
		_breath_tween.kill()
	scale = _initial_scale


func _on_area_2d_mouse_entered() -> void:
	##print("SELF CHANGE SELF MODULATE ", self)
	self_modulate = hover_self_modulate


func _on_area_2d_mouse_exited() -> void:
	self_modulate = default_self_modulate


func set_highlight()->void:
	self_modulate = hover_self_modulate

func undo_highlight()->void:
	self_modulate = default_self_modulate
	




##
