extends Control
#Level3

@onready var toolTips = $ToolTips
@onready var waveManager = $GameLayer/WaveManager

var eggWyrmPlaced := false
var walnutPlaced := false 

var bloodBuffTutorial = "res://Assets/Text/TextFiles/BloodBuffTutorial.txt"
var bloodBuffTutorial2 = "res://Assets/Text/TextFiles/BloodBuffTutorial12.txt"
var bloodBuffTutorial3 = "res://Assets/Text/TextFiles/BloodBuffTutorial2.txt"
var bloodBuffTutorial4 = "res://Assets/Text/TextFiles/BloodBuffTutorial3.txt"
var lastBloodTutorial = "res://Assets/Text/TextFiles/LastBloodBuffTutorial.txt"
var hive_egg_buff_scene = preload("res://Scenes/Tutorials/egg_spine_buff.tscn")

var count := 1

# Sets Up the Tiles For Level 3 
func _ready():
	Global.resetSunflowerCount()
	process_mode = Node.PROCESS_MODE_ALWAYS
	#$GameLayer/GridManager.set_tiles_for_rows(0,1, 68)
	##$GameLayer/GridManager.set_tiles_for_rows(1,2, 66)
	#
	#$GameLayer/GridManager.set_tiles_for_rows(2,3, 63)
	#$GameLayer/GridManager.set_tiles_for_rows(3,4, 63)
	#$GameLayer/GridManager.set_tiles_for_rows(4,5, 63)
	#$GameLayer/GridManager.set_tiles_for_rows(5,6, 63)
	#$GameLayer/GridManager.set_tiles_for_rows(6,7, 63)
	#
	##$GameLayer/GridManager.set_tiles_for_rows(7,8, 66)
	#$GameLayer/GridManager.set_tiles_for_rows(8,9, 69)
	
	toolTips.set_text(bloodBuffTutorial)
	toolTips.showButton()
	make_camera_current()


func _on_plant_manager_egg_worm_placed() -> void:
	if !eggWyrmPlaced:
		toolTips.set_text(bloodBuffTutorial3)
		toolTips.noButtonShow()
		eggWyrmPlaced = true
		
		
		
		
		
	
	
#You will know a BLOOD BUFF is activated by the floating BLOOD around a given SUMMON.

func _on_plant_manager_walnut_placed() -> void:
	if !walnutPlaced:
		print("HID WALNUT PSVCED")
		toolTips.set_text(bloodBuffTutorial4)
		#waveManager.canStartGame = true
		toolTips.showButton()
		walnutPlaced = true 


func _on_wave_manager_wave_2_almost_start() -> void:
	waveManager.startSecondWave()


func _on_tool_tips_tool_tip_hid() -> void:
	#print("HID, COUNT IS ",count )
	match count:
		1:
			toolTips.setComplexSceneText(bloodBuffTutorial2)
			toolTips.setComplexScene(hive_egg_buff_scene)
			toolTips.hideComplexSceneButton()
		2:
			toolTips.set_text(lastBloodTutorial)
			toolTips.showButton()
		3:
			waveManager.canStartGame = true
	count += 1


func make_camera_current():
	$Camera2D.make_current()
