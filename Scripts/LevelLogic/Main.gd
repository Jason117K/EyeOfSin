extends Control
#Main.gd 



#Sets up Tilemap 
func _ready():
	#$GameLayer/GridManager.set_tiles_for_rows(0,1, 28)
	$GameLayer/GridManager.set_tiles_for_rows(1,2, 26)
	
	$GameLayer/GridManager.set_tiles_for_rows(2,3, 26)
	$GameLayer/GridManager.set_tiles_for_rows(3,4, 23)
	$GameLayer/GridManager.set_tiles_for_rows(4,5, 23)
	$GameLayer/GridManager.set_tiles_for_rows(5,6, 23)
	$GameLayer/GridManager.set_tiles_for_rows(6,7, 26)
	
	#$GameLayer/GridManager.set_tiles_for_rows(7,8, 26)
	$GameLayer/GridManager.set_tiles_for_rows(8,9, 29)

