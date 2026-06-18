extends NinePatchRect

var panel_to_outline : Control 
var alt_red_texture = preload("res://_Entities/Demons/Cards/Empty_Display_CARD.png")

@export var make_red := true 
@export var padding : Vector2 = Vector2(8,8)

func _ready() -> void:
	panel_to_outline = get_node_or_null("../DemoVisualContainer")
	if panel_to_outline != null:
		#print("Node Not Null Adjusting Nine Patch Size to ", panel_to_outline.size + padding)
		self.custom_minimum_size = panel_to_outline.size + padding
	else:
		pass
		#print("NODE WAS NULLL")
	if get_parent().name.containsn("zombie"):
		make_red = false
	if make_red:
		self.texture = alt_red_texture 
		
