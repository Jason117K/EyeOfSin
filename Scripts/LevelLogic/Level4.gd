extends Control
#Level4

@onready var toolTips = $ToolTips
@onready var waveManager = $GameLayer/WaveManager

var waspText = "res://Assets/Text/TextFiles/waspTutorial.txt"
var screenDoorZombieText = "res://Assets/Text/TextFiles/ScreenDoorZombieTutorial.txt"
var waspEggBuffText = "res://Assets/Text/TextFiles/WaspEggBuff.txt"

var waspAnim = preload("res://Assets/Plants/Spriteframes/Wasp.tres")
var screenDoorZombieAnim = preload("res://Assets/Zombies/Animations/Spriteframes/ScreenDoorZombie.tres")

var hive_egg_buff_scene = preload("res://Scenes/Tutorials/hive_egg_buff.tscn")


# Sets Up the Tiles For Level 4 
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
	toolTips.set_text(waspText)
	toolTips.setAnim(waspAnim)
	toolTips.noButtonShow()


func _on_plant_manager_wasp_placed() -> void:

	
	toolTips.setComplexSceneText(waspEggBuffText)
	toolTips.setComplexScene(hive_egg_buff_scene)
	#toolTips.hide()
	#waveManager.canStartGame = true


func _on_wave_manager_wave_1_started() -> void:
	toolTips.set_text_pause(screenDoorZombieText)
	toolTips.setAnim(screenDoorZombieAnim)
	toolTips.showButton()


func _on_tool_tips_tool_tip_hid() -> void:
	waveManager.canStartGame = true
