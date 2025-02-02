extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	$GameLayer/GridManager.set_tiles_for_rows(0,1, 18)
	$GameLayer/GridManager.set_tiles_for_rows(1,1, 17)
	
	$GameLayer/GridManager.set_tiles_for_rows(2,1, 21)
	$GameLayer/GridManager.set_tiles_for_rows(3,1, 22)
	$GameLayer/GridManager.set_tiles_for_rows(4,1, 3)
	$GameLayer/GridManager.set_tiles_for_rows(5,1, 4)
	$GameLayer/GridManager.set_tiles_for_rows(6,1, 12)
	
	$GameLayer/GridManager.set_tiles_for_rows(7,1, 15)
	$GameLayer/GridManager.set_tiles_for_rows(8,1, 18)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
