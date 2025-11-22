extends AnimatedTextureRect

#Button References
@onready var sunflowerButton = $"../AllPlantRows/Row1/Sunflower"
@onready var peashooterButton = $"../AllPlantRows/Row1/Peashooter"
@onready var walnutButton = $"../AllPlantRows/Row1/Walnut"
@onready var eyeBombButton = $"../AllPlantRows/Row2/EyeBomb"
@onready var eggWyrmButton = $"../AllPlantRows/Row2/EggWrym" 
@onready var hiveButton = $"../AllPlantRows/Row2/Hive" 
@onready var mawButton = $"../AllPlantRows/Row3/Maw"

@onready var currentPlantLabel = $"../../CurrentPlantLabel"
@onready var bgDarken = $"../../BGDarkEn"
@onready var synergyPanel = $"../../ToolTips"
@onready var backOutDetailsButton = $"../../BackOutDetails"
@onready var moreInfoButton =$"../../HBoxContainer/AllPlantRows/HBoxContainer/MoreInfoButton"

#Plant Text Descriptions
var sunflowerDescription := "res://Assets/Text/TextFiles/PlantDescriptions/SunflowerDescription.txt"
var peashooterDescription := "res://Assets/Text/TextFiles/PlantDescriptions/PeashooterDescription.txt"
var walnutDescription := "res://Assets/Text/TextFiles/PlantDescriptions/WalnutDescription.txt"
var eyeBombDescription := "res://Assets/Text/TextFiles/PlantDescriptions/EyeBombDescription.txt"
var eggWyrmDescription := "res://Assets/Text/TextFiles/PlantDescriptions/EggWyrmDescription.txt"
var hiveDescription := "res://Assets/Text/TextFiles/PlantDescriptions/HiveDescription.txt"
var mawDescription := "res://Assets/Text/TextFiles/PlantDescriptions/MawDescription.txt"

var mawSpyderText =  "res://Assets/Text/TextFiles/SpiderMawBuff.txt"
var mawEggText = "res://Assets/Text/TextFiles/EggMawBuff.txt"
var spineMawText =  "res://Assets/Text/TextFiles/SpineMawBuff.txt"
var hiveMawText = "res://Assets/Text/TextFiles/HiveMawBuff.txt"
var hiveEggText = "res://Assets/Text/TextFiles/WaspEggBuff.txt"
var hiveSpyderText = "res://Assets/Text/TextFiles/hiveSpyderBuff.txt"
var eggSpineText = "res://Assets/Text/TextFiles/eggSpineBuff.txt"
var sunSpyderText = "res://Assets/Text/TextFiles/SunSpyderBuff.txt"
var sunEggText = "res://Assets/Text/TextFiles/SunEggWyrmBuff.txt"
var sunMawText = "res://Assets/Text/TextFiles/SunMawBuff.txt"
var sunSpineText = "res://Assets/Text/TextFiles/SunSpineBuff.txt"
var sunHiveText = "res://Assets/Text/TextFiles/SunHiveBuff.txt"


var mawSpyderScene = preload("res://Scenes/Tutorials/maw_spider_buff.tscn")
var mawEggScene = preload("res://Scenes/Tutorials/maw_egg_buff.tscn")
var spineMawScene = preload("res://Scenes/Tutorials/spine_maw_buff.tscn")
var hiveMawScene  = preload("res://Scenes/Tutorials/maw_hive_buff.tscn")
var spineEggScene = preload("res://Scenes/Tutorials/egg_spine_buff.tscn")
var hiveEggScene = preload("res://Scenes/Tutorials/hive_egg_buff.tscn")
var hiveSpyderScene = preload("res://Scenes/Tutorials/hive_spyder_buff.tscn")
var sunSpyderScene = preload("res://Scenes/Tutorials/sun_spyder_buff.tscn")
var sunEggScene = preload("res://Scenes/Tutorials/sun_egg_buff.tscn")
var sunHiveScene = preload("res://Scenes/Tutorials/sun_hive_buff.tscn")
var sunSpineScene = preload("res://Scenes/Tutorials/sun_spine_buff.tscn")
var sunMawScene = preload("res://Scenes/Tutorials/sun_maw_buff.tscn")

var count := 0

enum PLANT {
	SUNFLOWER,
	SPYDER,
	OCCULAR_SPINE,
	EYE_BOMB,
	EGG_WYRM,
	HIVE,
	MAW,
}

var current_plant = PLANT.SUNFLOWER

func _ready() -> void:
	$"../../Camera2D".make_current()
	print("Plant AnimatedTextureRect: _ready() called")
	
		# Set default button textures based on current colors
	_update_button_textures()
	
	# Set initial sprites if none are set
	if sprites == null:
		var plant_type = GlobalResourceLoader.PlantType.SUNFLOWER
		sprites = GlobalResourceLoader.get_plant_animation(plant_type)
	
	# Initialize animation data
	if sprites != null:
		if not sprites.has_animation(current_animation):
			var animations = sprites.get_animation_names()
			if animations.size() > 0:
				current_animation = animations[0]
		
		fps = sprites.get_animation_speed(current_animation)
		refresh_rate = sprites.get_frame_duration(current_animation, frame_index)
		if auto_play:
			play()

# Update all button textures based on current color settings
func _update_button_textures():
	
	# Set Melee Alien buttons
	if sunflowerButton != null:
		sunflowerButton.texture_normal = GlobalResourceLoader.get_plant_image(
			GlobalResourceLoader.PlantType.SUNFLOWER)
	if peashooterButton != null:
		peashooterButton.texture_normal = GlobalResourceLoader.get_plant_image(
			GlobalResourceLoader.PlantType.PEASHOOTER)
	if walnutButton != null:
		walnutButton.texture_normal = GlobalResourceLoader.get_plant_image(
			GlobalResourceLoader.PlantType.WALNUT)
	
	# Set Ranged Alien buttons
	if eyeBombButton != null:
		eyeBombButton.texture_normal = GlobalResourceLoader.get_plant_image(
			GlobalResourceLoader.PlantType.BOMBPLANT)
	if eggWyrmButton != null:
		eggWyrmButton.texture_normal = GlobalResourceLoader.get_plant_image(
			GlobalResourceLoader.PlantType.EGGWYRM)
	if hiveButton != null:
		hiveButton.texture_normal = GlobalResourceLoader.get_plant_image(
			GlobalResourceLoader.PlantType.HIVE)
			
	if mawButton != null:
		mawButton.texture_normal = GlobalResourceLoader.get_plant_image(
			GlobalResourceLoader.PlantType.MAW)
			
			
			
			
			
#Sets the current Plant Description Text
func set_text(newFile : String):
	var file = FileAccess.open(newFile, FileAccess.READ)
	var newText = file.get_as_text()
	file.close()
	currentPlantLabel.text = newText

func _on_sunflower_pressed() -> void:
	moreInfoButton.visible = true
	current_plant = PLANT.SUNFLOWER
	sprites = GlobalResourceLoader.get_plant_animation(
		GlobalResourceLoader.PlantType.SUNFLOWER)
	play()
	set_text(sunflowerDescription)



func _on_peashooter_pressed() -> void:
	moreInfoButton.visible = true
	current_plant = PLANT.SPYDER
	sprites = GlobalResourceLoader.get_plant_animation(
		GlobalResourceLoader.PlantType.PEASHOOTER)
	play()
	set_text(peashooterDescription)


func _on_walnut_pressed() -> void:
	moreInfoButton.visible = true
	current_plant = PLANT.OCCULAR_SPINE
	sprites = GlobalResourceLoader.get_plant_animation(
		GlobalResourceLoader.PlantType.WALNUT)
	play()
	set_text(walnutDescription)


func _on_eye_bomb_pressed() -> void:
	moreInfoButton.visible = false
	current_plant = PLANT.EYE_BOMB
	sprites = GlobalResourceLoader.get_plant_animation(
		GlobalResourceLoader.PlantType.BOMBPLANT)
	play()
	set_text(eyeBombDescription)


func _on_egg_wrym_pressed() -> void:
	moreInfoButton.visible = true
	current_plant = PLANT.EGG_WYRM
	sprites = GlobalResourceLoader.get_plant_animation(
		GlobalResourceLoader.PlantType.EGGWYRM)
	play()
	set_text(eggWyrmDescription)


func _on_hive_pressed() -> void:
	moreInfoButton.visible = true
	current_plant = PLANT.HIVE
	sprites = GlobalResourceLoader.get_plant_animation(
		GlobalResourceLoader.PlantType.HIVE)
	play()
	set_text(hiveDescription)


func _on_maw_pressed() -> void:
	moreInfoButton.visible = true
	current_plant = PLANT.MAW
	sprites = GlobalResourceLoader.get_plant_animation(
		GlobalResourceLoader.PlantType.MAW)
	play()
	set_text(mawDescription)
	


func _on_back_button_pressed() -> void:
	get_parent().get_parent().visible = false 
	print("BBack Button Pressed")
	Global.game_controller.restore_previous_scene()
	
	
	




func _on_more_info_button_pressed() -> void:
	bgDarken.visible = true 
	backOutDetailsButton.visible = true 
	synergyPanel.visible = true 
	
	match current_plant:
		PLANT.SUNFLOWER:
			synergyPanel.setComplexSceneText(sunSpyderText)
			synergyPanel.setComplexScene(sunSpyderScene)
		PLANT.SPYDER:
			synergyPanel.setComplexSceneText(mawSpyderText)
			synergyPanel.setComplexScene(mawSpyderScene)
		PLANT.OCCULAR_SPINE:
			synergyPanel.setComplexSceneText(eggSpineText)
			synergyPanel.setComplexScene(spineEggScene)	
		PLANT.EYE_BOMB:
			pass
		PLANT.EGG_WYRM:
			synergyPanel.setComplexSceneText(mawEggText)
			synergyPanel.setComplexScene(mawEggScene)
		PLANT.HIVE:
			synergyPanel.setComplexSceneText(hiveMawText)
			synergyPanel.setComplexScene(hiveMawScene)
		PLANT.MAW:
			synergyPanel.setComplexSceneText(mawSpyderText)
			synergyPanel.setComplexScene(mawSpyderScene)


func _on_back_out_details_pressed() -> void:
	bgDarken.visible = false 
	backOutDetailsButton.visible = false 
	synergyPanel.visible = false 


func _on_button_2_pressed() -> void:
	#print("CCount is ", count)
	count += 1
	setNextSynergyScene(current_plant,count)

func setNextSynergyScene(current_plant,this_count):
	match current_plant:
		PLANT.SUNFLOWER:
			match this_count:
				0:
					synergyPanel.setComplexSceneText(sunSpyderText)
					synergyPanel.setComplexScene(sunSpyderScene)
				1:
					synergyPanel.setComplexSceneText(sunEggText)
					synergyPanel.setComplexScene(sunEggScene)
				2:
					synergyPanel.setComplexSceneText(sunHiveText)
					synergyPanel.setComplexScene(sunHiveScene)
				3:
					synergyPanel.setComplexSceneText(sunSpineText)
					synergyPanel.setComplexScene(sunSpineScene)
				4:
					synergyPanel.setComplexSceneText(sunMawText)
					synergyPanel.setComplexScene(sunMawScene)
					count = -1
			
		PLANT.SPYDER:
			match this_count:
				0:
					synergyPanel.setComplexSceneText(mawSpyderText)
					synergyPanel.setComplexScene(mawSpyderScene)
				1:
					synergyPanel.setComplexSceneText(hiveSpyderText)
					synergyPanel.setComplexScene(hiveSpyderScene)
					count = -1
		PLANT.OCCULAR_SPINE:
			match this_count:
				0:
					synergyPanel.setComplexSceneText(eggSpineText)
					synergyPanel.setComplexScene(spineEggScene)	
				1:
					synergyPanel.setComplexSceneText(spineMawText)
					synergyPanel.setComplexScene(spineMawScene)
					count = -1
		PLANT.EYE_BOMB:
			match this_count:
				0:
					pass
		PLANT.EGG_WYRM:
			match this_count:
				0:
					synergyPanel.setComplexSceneText(mawEggText)
					synergyPanel.setComplexScene(mawEggScene)
				1:
					synergyPanel.setComplexSceneText(eggSpineText)
					synergyPanel.setComplexScene(spineEggScene)
				2:
					synergyPanel.setComplexSceneText(hiveEggText)
					synergyPanel.setComplexScene(hiveEggScene)
					count = -1
		PLANT.HIVE:
			match this_count:
				0:
					synergyPanel.setComplexSceneText(hiveMawText)
					synergyPanel.setComplexScene(hiveMawScene)
				1:
					synergyPanel.setComplexSceneText(hiveSpyderText)
					synergyPanel.setComplexScene(hiveSpyderScene)
					
				2:
					synergyPanel.setComplexSceneText(hiveEggText)
					synergyPanel.setComplexScene(hiveEggScene)
					count = -1
		PLANT.MAW:
			match this_count:
				0:
					synergyPanel.setComplexSceneText(mawSpyderText)
					synergyPanel.setComplexScene(mawSpyderScene)	
				1:
					synergyPanel.setComplexSceneText(mawEggText)
					synergyPanel.setComplexScene(mawEggScene)
				2:
					synergyPanel.setComplexSceneText(spineMawText)
					synergyPanel.setComplexScene(spineMawScene)
				3:
					synergyPanel.setComplexSceneText(hiveMawText)
					synergyPanel.setComplexScene(hiveMawScene)
					count = -1
					#print("CCCCC Count is ", count)
