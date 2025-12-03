extends Control



@onready var toolTips = $ToolTips
@export var make_green := false 



var startingTutorialText = "res://Assets/Text/TextFiles/FirstTutorial.txt"
var sunFlowerText = "res://Assets/Text/TextFiles/SunflowerIntro.txt"
var placeSummonText = "res://Assets/Text/TextFiles/PlaceSummon.txt"
var spyderTutorialText = "res://Assets/Text/TextFiles/SpyderTutorial.txt"
var basicOffenseDefenseText = "res://Assets/Text/TextFiles/basicOffensiveDefense.txt"
var walnutTutorial = "res://Assets/Text/TextFiles/OccularSpineTutorial.txt"
var coneheadTutorial = "res://Assets/Text/TextFiles/ConeheadTutorial.txt"
var dancerTutorial = "res://Assets/Text/TextFiles/DancerTutorial.txt"
var bucketHeadTutorial = "res://Assets/Text/TextFiles/BucketHeadTutorial.txt"
var bloodBuffTutorial = "res://Assets/Text/TextFiles/BloodBuffTutorial.txt"

var coneheadAnim = preload("res://Assets/Zombies/Animations/Spriteframes/Severed.tres")
var dancerAnim = preload("res://Assets/Zombies/Animations/Spriteframes/DancerAnim.tres")
var eyeAnim = preload("res://Assets/Zombies/Animations/Spriteframes/eyeFrames.tres")
var walnutAnim = preload("res://Assets/Zombies/Animations/Spriteframes/walnutFrames.tres")
var spyderAnim = preload("res://Assets/Zombies/Animations/Spriteframes/spyderFrames.tres")
var bucketHeadAnim = preload("res://Assets/Zombies/Animations/Spriteframes/BucketHead.tres")

var dimensionTutorial = "res://Assets/Text/TextFiles/DimensionTutorial.txt"

var bloodBuffTutorial2 = "res://Assets/Text/TextFiles/BloodBuffTutorial12.txt"


var hive_egg_buff_scene = preload("res://Scenes/Tutorials/egg_spine_buff.tscn")
var dimension_scene = preload("res://Scenes/Tutorials/dimension_visual.tscn")


var showNextTutuorial : bool = false
var sunflowerPlaced := false
var spyderPlaced := false
var walnutPlaced := false 

var count : int = 1


var dimensionalNode 
var isReady := false

@onready var waveManager = $GameLayer/WaveManager
@onready var plantManager = $PlantManager

var tuturoial_text1 = "res://Assets/Text/TextFiles/NewTutorials/Tutorial0-1_1.txt"



#Sets up Tilemap 
func _ready():
	dimensionalNode = get_parent().get_node("Level0-1_Alternate")
	print("Other Dimension is ", dimensionalNode,get_parent().get_child(0),get_parent().get_child(1) )
	attach_script_to_coral_children("res://Scripts/Environment/sway.gd")
	Global.resetSunflowerCount()
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	#Sets the first tutorial popup
	##FIRST TEXT PROMPT HERE 
	toolTips.set_text(tuturoial_text1)
	#TODO Camera???
	make_camera_current()
	
	isReady = true

	
	
func _process(delta: float) -> void:
	if !isReady:
		_ready()
	if showNextTutuorial && count < 2:
		print("UCount is ", count)
		toolTips.set_text(sunFlowerText)
		$PlantSelectionMenu.showEyeSummon()
		count = count + 1
		toolTips.noButtonShow()
	elif showNextTutuorial && count > 3 && count < 5:
		print("TCount is ", count)
		toolTips.setComplexSceneText(bloodBuffTutorial2)
		toolTips.setComplexScene(hive_egg_buff_scene)
		count = count + 1
		toolTips.noButtonShow()
		
	elif showNextTutuorial && count > 5 && count < 7:
		print("PCount is ", count)
		toolTips.setComplexSceneText(dimensionTutorial)
		toolTips.setComplexScene(dimension_scene)
		count = count + 1
		toolTips.noButtonShow()
		
func _on_tool_tips_tool_tip_hid() -> void:
	print("Hid Count is ", count)
	if count == 5:
		count+=1
	if showNextTutuorial && count < 4:
		print("OOCount is ", count)
		count = count + 1
	if showNextTutuorial && count > 5:
		print("OCount is ", count)
		$GameLayer/WaveManager.canStartGame = true 
		$PlantSelectionMenu.canSwapScenes = true 
		dimensionalNode.finish_setup_and_start()
		#print("Let the games begin")
	showNextTutuorial = true 
	


func _on_plant_selection_menu_clicked_eye() -> void:
	
	if count < 3:
		print("CCount is ", count)
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
		print("SCount is ", count)
		toolTips.set_text(basicOffenseDefenseText)
		toolTips.showButton()
		spyderPlaced = true 
		#count = count + 1


func _on_wave_manager_wave_2_almost_start() -> void:
	toolTips.set_text(walnutTutorial)
	toolTips.setAnim(walnutAnim)
	toolTips.noButtonShow()
	pass


func _on_plant_manager_walnut_placed() -> void:
	if !walnutPlaced:
		toolTips.hide()
		print("Walnut Placed")
		if dimensionalNode:
			dimensionalNode.startWave2()
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

func make_camera_current():
	$Camera2D.make_current()

func attach_script_to_coral_children(script_path: String) -> void:

	# Find the Coral node
	var coral_node = get_node("Environment/Coral")
	
	if coral_node == null:
		push_error("Coral node not found at Environment/Coral")
		return
	
	
	# Load the script to attach
	var script_to_attach = load(script_path)
	
	if script_to_attach == null:
		push_error("Failed to load script at: " + script_path)
		return
	
	# Iterate through all children and attach the script
	for child in coral_node.get_children():
		child.set_script(script_to_attach)
		if child.is_inside_tree() and child.has_method("_ready"):
			if make_green:
				child.make_green()
			child._ready()
		print("Script attached to: ", child.name)


func place_empty_blocker_plant(grid_pos):
	plantManager.place_empty_blocker_plant(grid_pos)
