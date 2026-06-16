extends NinePatchRect

#@export var border_scale: float = 1.5
@export var target: Control  # assign the PanelContainer in the inspector
@onready var wave_preview_controller := $"../.."

var position_offset := Vector2(22, 7)

func _ready() -> void:
	if target:
		self.visible = target.visible 
		wave_preview_controller.preview_setup.connect(_fit_to_target)
		# Target may not be laid out yet at _ready(); defer the first fit.
		_fit_to_target.call_deferred()
		target.visibility_changed.connect(change_visibility)


func _fit_to_target() -> void:
	if not target:
		return
	
	var t := target.size
	#size = t / border_scale
	size = target.size / self.scale.x
	#size.y = 36
	size = size# + Vector2(0,8)
	pivot_offset = size #* 0.5
	position = target.position + (t - size) #* 0.5
	position = position #+  Vector2(0,8)
	#size = size + Vector2(0,7)
	#scale = Vector2(border_scale, border_scale)
	#print("Target : ", target, " position is ", target.position)
	#position = target.position + position_offset

func change_visibility()->void:
	self.visible = target.visible
