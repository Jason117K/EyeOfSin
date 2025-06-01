extends Control
#Level 5

@onready var toolTips = $ToolTips
@onready var waveManager = $GameLayer/WaveManager

var mawText =  "res://Assets/Text/TextFiles/MawTutorial.txt"
var mawSpyderText =  "res://Assets/Text/TextFiles/SpiderMawBuff.txt"
var mawEggText = "res://Assets/Text/TextFiles/EggMawBuff.txt"
var spineMawText =  
var waspMawText = 

var mawAnim  = preload("res://Assets/Plants/Spriteframes/Maw.tres")
var mawSpyderScene = preload("res://Scenes/Tutorials/maw_spider_buff.tscn")
var mawEggScene = preload("res://Scenes/Tutorials/maw_egg_buff.tscn")
var spineMawScene =
var waspMawScene  =

var count := 0

# Sets Up the Tiles For Level 3 
func _ready():
	$GameLayer/GridManager.set_tiles_for_rows(0,1, 68)
	$GameLayer/GridManager.set_tiles_for_rows(1,2, 66)
	
	$GameLayer/GridManager.set_tiles_for_rows(2,3, 63)
	$GameLayer/GridManager.set_tiles_for_rows(3,4, 63)
	$GameLayer/GridManager.set_tiles_for_rows(4,5, 63)
	$GameLayer/GridManager.set_tiles_for_rows(5,6, 63)
	$GameLayer/GridManager.set_tiles_for_rows(6,7, 63)
	
	$GameLayer/GridManager.set_tiles_for_rows(7,8, 66)
	$GameLayer/GridManager.set_tiles_for_rows(8,9, 69)
	
	#Sets the first tutorial popup
	toolTips.set_text(mawText)
	toolTips.setAnim(mawAnim)
	toolTips.noButtonShow()


func _on_plant_manager_maw_placed() -> void:
	toolTips.setComplexSceneText(mawEggText)
	toolTips.setComplexScene(mawEggScene)



func _on_tool_tips_tool_tip_hid() -> void:
	
	count += 1
	print("Count is : ", count)
	match count :
		1: 
			print("1Matchhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh")
			toolTips.setComplexSceneText(mawSpyderText)
			toolTips.setComplexScene(mawSpyderScene)
		2:
			toolTips.setComplexSceneText(spineMawText)
			toolTips.setComplexScene(spineMawScene)
		3:
			toolTips.setComplexSceneText(spineMawText)
			toolTips.setComplexScene(waspMawScene)
		_:
			toolTips.setComplexSceneText(mawSpyderText)
			toolTips.setComplexScene(mawSpyderScene)
