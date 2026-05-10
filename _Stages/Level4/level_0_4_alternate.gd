extends LevelTemplate



@export var isGreenDimension := false 
var purple_dimension : Control

func _ready() -> void:
	attach_script_to_sway_children("res://Scripts/Environment/sway.gd")
	

func getIsGreenDimension():
	return isGreenDimension

func start_game():
	hide_all_demon_buttons_with_exception(["Occulum", "Crawler", "SpinalOcculum"])
	for node in get_parent().get_children():
		if node.has_method("getIsPurpleDimension"):
			purple_dimension = node
	purple_dimension.start_game()

func show_guide():
	$GameLayer/GridManager/TileMapLayer.place_rectangles_on_rows(2, 8)
	
