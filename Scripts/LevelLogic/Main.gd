extends Control
#Main.gd 

@onready var toolTips = $ToolTips

var startingTutorialText = "res://Assets/Text/TextFiles/FirstTutorial.txt"
var sunFlowerText = "res://Assets/Text/TextFiles/SunflowerIntro.txt"
var placeSummonText = "res://Assets/Text/TextFiles/PlaceSummon.txt"
var spyderTutorialText = "res://Assets/Text/TextFiles/SpyderTutorial.txt"
var showNextTutuorial : bool = false
var count : int = 1

#Sets up Tilemap 
func _ready():
	#$GameLayer/GridManager.set_tiles_for_rows(0,1, 28)
	$GameLayer/GridManager.set_tiles_for_rows(0,1, 68)
	$GameLayer/GridManager.set_tiles_for_rows(1,2, 66)
	
	$GameLayer/GridManager.set_tiles_for_rows(2,3, 66)
	$GameLayer/GridManager.set_tiles_for_rows(3,4, 63)
	$GameLayer/GridManager.set_tiles_for_rows(4,5, 63)
	$GameLayer/GridManager.set_tiles_for_rows(5,6, 63)
	$GameLayer/GridManager.set_tiles_for_rows(6,7, 66)
	
	$GameLayer/GridManager.set_tiles_for_rows(7,8, 66)
	$GameLayer/GridManager.set_tiles_for_rows(8,9, 69)
	
	#Sets the first tutorial popup
	toolTips.set_text(startingTutorialText)
	
	
func _process(delta: float) -> void:
	if showNextTutuorial && count < 2:
		toolTips.set_text(sunFlowerText)
		count = count + 1
		toolTips.noButtonShow()

func _on_tool_tips_tool_tip_hid() -> void:
	showNextTutuorial = true 
	


func _on_plant_selection_menu_clicked_eye() -> void:
	toolTips.set_text(placeSummonText)


func _on_plant_manager_plant_placed() -> void:
	toolTips.set_text(spyderTutorialText)
