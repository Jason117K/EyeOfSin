extends Control
#Main.gd 

@onready var toolTips = $ToolTips

var startingTutorialText = "res://Assets/Text/TextFiles/FirstTutorial.txt"
var sunFlowerText = "res://Assets/Text/TextFiles/SunflowerIntro.txt"
var placeSummonText = "res://Assets/Text/TextFiles/PlaceSummon.txt"
var spyderTutorialText = "res://Assets/Text/TextFiles/SpyderTutorial.txt"
var basicOffenseDefenseText = "res://Assets/Text/TextFiles/basicOffensiveDefense.txt"
var walnutTutorial = "res://Assets/Text/TextFiles/OccularSpineTutorial.txt"
var coneheadTutorial = "res://Assets/Text/TextFiles/ConeheadTutorial.txt"
var dancerTutorial = "res://Assets/Text/TextFiles/DancerTutorial.txt"
var bucketHeadTutorial = "res://Assets/Text/TextFiles/BucketHeadTutorial.txt"

var coneheadAnim = preload("res://Assets/Zombies/Animations/Spriteframes/Severed.tres")
var dancerAnim = preload("res://Assets/Zombies/Animations/Spriteframes/DancerAnim.tres")
var eyeAnim = preload("res://Assets/Zombies/Animations/Spriteframes/eyeFrames.tres")
var walnutAnim = preload("res://Assets/Zombies/Animations/Spriteframes/walnutFrames.tres")
var spyderAnim = preload("res://Assets/Zombies/Animations/Spriteframes/spyderFrames.tres")
var bucketHeadAnim = preload("res://Assets/Zombies/Animations/Spriteframes/BucketHead.tres")

var showNextTutuorial : bool = false
var sunflowerPlaced := false
var spyderPlaced := false
var walnutPlaced := false 

var count : int = 1

@onready var waveManager = $GameLayer/WaveManager

#Sets up Tilemap 
func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	#$GameLayer/GridManager.set_tiles_for_rows(0,1, 28)
	$GameLayer/GridManager.set_tiles_for_rows(0,1, 68)
	#$GameLayer/GridManager.set_tiles_for_rows(1,2, 66)
	
	#$GameLayer/GridManager.set_tiles_for_rows(2,3, 66)
	$GameLayer/GridManager.set_tiles_for_rows(3,4, 63)
	$GameLayer/GridManager.set_tiles_for_rows(4,5, 63)
	$GameLayer/GridManager.set_tiles_for_rows(5,6, 63)
	#$GameLayer/GridManager.set_tiles_for_rows(6,7, 66)
	
	#$GameLayer/GridManager.set_tiles_for_rows(7,8, 66)
	$GameLayer/GridManager.set_tiles_for_rows(8,9, 69)
	
	#Sets the first tutorial popup
	toolTips.set_text(startingTutorialText)
	
	
func _process(delta: float) -> void:
	if showNextTutuorial && count < 2:
		toolTips.set_text(sunFlowerText)
		$PlantSelectionMenu.showEyeSummon()
		count = count + 1
		toolTips.noButtonShow()

func _on_tool_tips_tool_tip_hid() -> void:
	if showNextTutuorial:
		$GameLayer/WaveManager.canStartGame = true 
		print("Let the games begin")
	showNextTutuorial = true 
	


func _on_plant_selection_menu_clicked_eye() -> void:
	if count < 3:
		
		toolTips.set_text(placeSummonText)
		toolTips.setAnim(eyeAnim)
		toolTips.noButtonShow()
		count = count + 1


func _on_plant_manager_plant_placed() -> void:
	if !sunflowerPlaced:
		toolTips.set_text(spyderTutorialText)
		toolTips.setAnim(spyderAnim)
		sunflowerPlaced = true 


func _on_plant_manager_spyder_placed() -> void:
	if !spyderPlaced:
		toolTips.set_text(basicOffenseDefenseText)
		toolTips.showButton()
		spyderPlaced = true 


func _on_wave_manager_wave_2_almost_start() -> void:
	toolTips.set_text(walnutTutorial)
	toolTips.setAnim(walnutAnim)
	toolTips.noButtonShow()
	pass


func _on_plant_manager_walnut_placed() -> void:
	if !walnutPlaced:
		toolTips.hide()
		print("Walnut Placed")
		waveManager.startSecondWave()
		walnutPlaced = true


func _on_wave_manager_wave_2_started() -> void:
	toolTips.set_text_pause(coneheadTutorial)
	toolTips.setAnim(coneheadAnim)
	toolTips.showButton()
	pass # Replace with function body.


func _on_wave_manager_wave_3_started() -> void:
	toolTips.set_text_pause(bucketHeadTutorial)
	toolTips.setAnim(bucketHeadAnim)
	toolTips.showButton()
	pass # Replace with function body.
