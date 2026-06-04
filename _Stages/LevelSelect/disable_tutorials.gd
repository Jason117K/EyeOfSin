extends Button

@onready var is_disabled_panel :Panel = $Panel

var is_disabled := false 

var disabled_color := Color.RED
var enabled_color := Color("99999920")

@onready var style := is_disabled_panel.get_theme_stylebox("panel") as StyleBoxFlat

func _ready() -> void:
	set_status()

func _on_pressed() -> void:
	if is_disabled:
		is_disabled = false
	elif !is_disabled:
		is_disabled = true
	set_status()
	
func set_status()->void:
	if is_disabled:
		style.bg_color = disabled_color
		Global.skip_tutorials = true 
	elif !is_disabled:
		style.bg_color = enabled_color
		Global.skip_tutorials = false
