extends LevelTemplate

@export var isGreenDimension := false 
var purple_dimension : Control

func _ready() -> void:
	attach_script_to_sway_children("res://Scripts/Environment/sway.gd")
	

func getIsGreenDimension():
	return isGreenDimension



	

func start_game():
	waveManager = get_parent().get_node("WaveManager")
	show_all_demon_buttons()
	for node in get_parent().get_children():
		if node.has_method("getIsPurpleDimension"):
			purple_dimension = node
	#print("Purple Dim is ", purple_dimension)
	purple_dimension.start_game()	
	waveManager.canStartGame = true



func show_guide():
	$GameLayer/GridManager/TileMapLayer.place_rectangles_on_rows(2, 8)
