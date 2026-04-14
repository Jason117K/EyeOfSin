extends Button

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

var _breath_tween: Tween


func _ready() -> void:
	pivot_offset = size / 2.0
	
	if breathing:
		_start_breathing()


func _on_resized() -> void:
	pivot_offset = size / 2.0


func _start_breathing() -> void:
	_stop_breathing()
	
	scale = Vector2(min_scale, min_scale)
	
	_breath_tween = create_tween()
	_breath_tween.set_trans(Tween.TRANS_SINE)
	_breath_tween.set_ease(Tween.EASE_IN_OUT)
	_breath_tween.set_loops()
	
	_breath_tween.tween_property(self, "scale", Vector2(max_scale, max_scale), breath_duration)
	_breath_tween.tween_property(self, "scale", Vector2(min_scale, min_scale), breath_duration)


func _stop_breathing() -> void:
	if _breath_tween and _breath_tween.is_valid():
		_breath_tween.kill()
	scale = Vector2.ONE
