#class_name SquashAndStretch
extends DemonSpriteComp
### Attach this script to an AnimatedSprite2D node.
### Define per-frame scale targets and it will tween between them
### each time the frame changes, giving you programmatic squash & stretch.
#
### Where the sprite scales from. BOTTOM keeps feet on the ground,
### TOP keeps the head anchored, CENTER is the default behavior.
#enum Pivot { CENTER, BOTTOM, TOP }
#
### How much to squash/stretch. Higher = more exaggerated.
#@export var intensity: float = 1.0
#
### Duration of each tween (should roughly match your frame duration).
#@export var tween_duration: float = 0.15
#
### Easing used for the scale tween.
#@export var ease_type: Tween.EaseType = Tween.EASE_OUT
#
### Transition used for the scale tween.
#@export var trans_type: Tween.TransitionType = Tween.TRANS_BACK
#
### Which edge of the sprite stays anchored during scaling.
#@export var pivot: Pivot = Pivot.BOTTOM
#
### Per-frame scale targets as a Dictionary.
### Key = frame index (int), Value = Vector2 scale target.
### If a frame is not listed, it defaults to Vector2(1, 1).
### TIP: For volume preservation, when you shrink Y, grow X proportionally.
#@export var frame_scales: Dictionary = {
	#0: Vector2(1.0, 1.0),    # Frame 0: resting
	#1: Vector2(1.01, 0.99),  # Frame 1: slight squash (dropping)
	#2: Vector2(1.02, 0.98),    # Frame 2: more squash (dropping more)
	#3: Vector2(0.99, 1.01),  # Frame 3: slight stretch (rebounding up)
#}
#
#var _base_scale: Vector2
#var _base_offset: Vector2
#var _sprite_height: float = 0.0
#var _active_tween: Tween
#
#
#func _ready() -> void:
	#_base_scale = scale
	#_base_offset = offset
	#_calculate_sprite_height()
	#_apply_pivot_offset()
	#frame_changed.connect(_on_frame_changed)
	## Apply initial frame scale immediately
	#_apply_frame_scale(frame)
#
#
#func _calculate_sprite_height() -> void:
	### Grab the height from the current frame's texture.
	#var frames_data := sprite_frames
	#if frames_data == null:
		#return
	#var anim_name := animation
	#if frames_data.get_frame_count(anim_name) > 0:
		#var tex := frames_data.get_frame_texture(anim_name, 0)
		#if tex:
			#_sprite_height = tex.get_height()
#
#
#func _apply_pivot_offset() -> void:
	### Shift the sprite's offset so the chosen edge sits at the node origin.
	### This only runs once at startup.
	#match pivot:
		#Pivot.CENTER:
			## No adjustment needed
			#pass
		#Pivot.BOTTOM:
			## Move the sprite up so its bottom edge is at origin
			#offset.y = _base_offset.y - 13#_sprite_height * 0.5
		#Pivot.TOP:
			## Move the sprite down so its top edge is at origin
			#offset.y = _base_offset.y + _sprite_height * 0.5
#
#
#func _on_frame_changed() -> void:
	#_apply_frame_scale(frame)
#
#
#func _apply_frame_scale(frame_index: int) -> void:
	## Kill any in-progress tween so they don't stack
	#if _active_tween and _active_tween.is_valid():
		#_active_tween.kill()
#
	## Look up the target scale for this frame, default to (1, 1)
	#var target: Vector2 = frame_scales.get(frame_index, Vector2(1.0, 1.0))
#
	## Apply intensity multiplier (lerp from neutral toward target)
	#var final_scale := Vector2(
		#_base_scale.x * lerpf(1.0, target.x, intensity),
		#_base_scale.y * lerpf(1.0, target.y, intensity)
	#)
#
	## Compensate offset so the pivot edge stays anchored
	#var final_offset := offset
	#if pivot != Pivot.CENTER:
		#match pivot:
			#Pivot.BOTTOM:
				## When scale grows, push offset further up to keep bottom demoned
				#final_offset.y = _base_offset.y - (13) * final_scale.y
			#Pivot.TOP:
				## When scale grows, push offset further down to keep top demoned
				#final_offset.y = _base_offset.y + (14) * final_scale.y
#
	## Create and run the tween
	#_active_tween = create_tween()
	#_active_tween.set_ease(ease_type)
	#_active_tween.set_trans(trans_type)
	#_active_tween.set_parallel(true)
	#_active_tween.tween_property(self, "scale", final_scale, tween_duration)
	#if pivot != Pivot.CENTER:
		#_active_tween.tween_property(self, "offset", final_offset, tween_duration)
#
#
### Call this to reset the sprite to its original scale and offset.
#func reset_scale() -> void:
	#if _active_tween and _active_tween.is_valid():
		#_active_tween.kill()
	#scale = _base_scale
	#_apply_pivot_offset()
