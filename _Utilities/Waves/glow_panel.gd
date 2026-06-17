extends Panel

@export var dim_glow_mult := 1.21
@export var bright_glow_mult := 3

@onready var glow_mult := dim_glow_mult

var og_r : float
var og_g : float 
var og_b : float 

var panel_stylebox : StyleBoxFlat
var style_box_color : Color

var linear : Color 

func _ready() -> void:
	panel_stylebox = get_theme_stylebox("panel")
	#set_glow_factor(true)
	
func set_color(is_green : bool)->void:
	if is_green:
		panel_stylebox.bg_color = Color.DARK_GREEN
	else:
		pass
		
	style_box_color = panel_stylebox.bg_color
	linear = style_box_color.srgb_to_linear()
	og_r = linear.r
	og_g = linear.g
	og_b = linear.b		
		
	


func set_glow_factor(is_dim:bool) -> void:
	if is_dim:
		glow_mult = dim_glow_mult
		#linear.r = og_r
		#linear.g = og_g
		#linear.b = og_b
		#return
	else:
		glow_mult = bright_glow_mult
		
	linear = style_box_color.srgb_to_linear()
	linear.r = og_r * glow_mult
	linear.g = og_g * glow_mult
	linear.b = og_b * glow_mult
	style_box_color = linear.linear_to_srgb()
	
	panel_stylebox.bg_color = style_box_color
	
