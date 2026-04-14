extends Line2D
#Line2D2.gd

#Handles setting the colors for Maw tentacles 


# Create colors with full alpha channel (1.0)
const START_COLOR = Color(1, 0, 0, 1) # Red
const END_COLOR = Color(0, 1, 0, 1)   # Green

const START_COLOR2 = Color.FUCHSIA

func _ready():
	# Create new gradient
	var new_gradient = Gradient.new()
	
	# Set gradient colors and offsets exactly
	new_gradient.set_offset(0, 0.0)  # First color at start (0.0)
	new_gradient.set_offset(1, 1.0)  # Second color at end (1.0)
	
	new_gradient.set_color(0, START_COLOR2)
	new_gradient.set_color(1, END_COLOR)
	
	# Apply gradient to line
	gradient = new_gradient
