extends Control
#Level3

@onready var toolTips = $ToolTips
@onready var waveManager = $GameLayer/WaveManager

var eggWyrmPlaced := false
var walnutPlaced := false 

var bloodBuffTutorial = "res://Assets/Text/TextFiles/BloodBuffTutorial.txt"
var bloodBuffTutorial2 = "res://Assets/Text/TextFiles/BloodBuffTutorial2.txt"
var bloodBuffTutorial3 = "res://Assets/Text/TextFiles/BloodBuffTutorial3.txt"

# Sets Up the Tiles For Level 3 
func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	$GameLayer/GridManager.set_tiles_for_rows(0,1, 68)
	$GameLayer/GridManager.set_tiles_for_rows(1,2, 66)
	
	$GameLayer/GridManager.set_tiles_for_rows(2,3, 63)
	$GameLayer/GridManager.set_tiles_for_rows(3,4, 63)
	$GameLayer/GridManager.set_tiles_for_rows(4,5, 63)
	$GameLayer/GridManager.set_tiles_for_rows(5,6, 63)
	$GameLayer/GridManager.set_tiles_for_rows(6,7, 63)
	
	$GameLayer/GridManager.set_tiles_for_rows(7,8, 66)
	$GameLayer/GridManager.set_tiles_for_rows(8,9, 69)
	
	toolTips.set_text(bloodBuffTutorial)
	toolTips.noButtonShow()


func _on_plant_manager_egg_worm_placed() -> void:
	if !eggWyrmPlaced:
		toolTips.set_text(bloodBuffTutorial2)
		toolTips.noButtonShow()
		eggWyrmPlaced = true
		
		
		
		
		
	
	

func _on_plant_manager_walnut_placed() -> void:
	if !walnutPlaced:
		toolTips.set_text(bloodBuffTutorial3)
		waveManager.canStartGame = true
		toolTips.showButton()
		walnutPlaced = true 


func _on_wave_manager_wave_2_almost_start() -> void:
	waveManager.startSecondWave()
