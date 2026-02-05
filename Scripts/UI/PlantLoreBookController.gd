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
#@onready var moreInfoButton =$"../../HBoxContainer/AllPlantRows/HBoxContainer/MoreInfoButton"
@onready var staticPreview := $"../../StaticPreview"

@onready var alt1 = $"../../HBoxContainer/AllPlantRows/AltRow1/Alt1"
@onready var alt2 = $"../../HBoxContainer/AllPlantRows/AltRow1/Alt2"
@onready var alt3 = $"../../HBoxContainer/AllPlantRows/AltRow2/Alt3"
@onready var alt4 = $"../../HBoxContainer/AllPlantRows/AltRow2/Alt4"
@onready var alt5 = $"../../HBoxContainer/AllPlantRows/AltRow3/Alt5"
@onready var alt6 = $"../../HBoxContainer/AllPlantRows/AltRow3/Alt6"

var is_in_synergy = false

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


var occulumBase = "res://Assets/Text/TextFiles/Synergies/EyeBase.txt"
var occulumHive = "res://Assets/Text/TextFiles/Synergies/EyeHive.txt"
var occulumMaw = "res://Assets/Text/TextFiles/Synergies/EyeMaw.txt"
var occulumSpyder = "res://Assets/Text/TextFiles/Synergies/EyeSpyder.txt"
var occulumWalnut = "res://Assets/Text/TextFiles/Synergies/EyeWalnut.txt"
var occulumWyrm = "res://Assets/Text/TextFiles/Synergies/EyeWyrm.txt"

var spyderBase = "res://Assets/Text/TextFiles/Synergies/SpyderBase.txt"
var spyderEye = "res://Assets/Text/TextFiles/Synergies/SpyderEye.txt"
var spyderHive = "res://Assets/Text/TextFiles/Synergies/SpyderHive.txt"
var spyderMaw = "res://Assets/Text/TextFiles/Synergies/SpyderMaw.txt"
var spyderWalnut = "res://Assets/Text/TextFiles/Synergies/SpyderWalnut.txt"
var spyderWyrm = "res://Assets/Text/TextFiles/Synergies/SpyderWyrm.txt"

var hiveBase = "res://Assets/Text/TextFiles/Synergies/HiveBase.txt"
var hiveEye = "res://Assets/Text/TextFiles/Synergies/HiveEye.txt"
var hiveMaw = "res://Assets/Text/TextFiles/Synergies/HiveMaw.txt"
var hiveSpyder = "res://Assets/Text/TextFiles/Synergies/HiveSpyder.txt"
var hiveWalnut = "res://Assets/Text/TextFiles/Synergies/HiveWalnut.txt"
var hiveWyrm = "res://Assets/Text/TextFiles/Synergies/HiveWyrm.txt"

var walnutBase = "res://Assets/Text/TextFiles/Synergies/WalnutBase.txt"
var walnutEye = "res://Assets/Text/TextFiles/Synergies/WalnutEye.txt"
var walnutHive = "res://Assets/Text/TextFiles/Synergies/WalnutHive.txt"
var walnutMaw = "res://Assets/Text/TextFiles/Synergies/WalnutMaw.txt"
var walnutSpyder = "res://Assets/Text/TextFiles/Synergies/WalnutSpyder.txt"
var walnutWyrm = "res://Assets/Text/TextFiles/Synergies/WalnutWyrm.txt"

var mawBase = "res://Assets/Text/TextFiles/Synergies/MawBase.txt"
var mawEye = "res://Assets/Text/TextFiles/Synergies/MawEye.txt"
var mawHive = "res://Assets/Text/TextFiles/Synergies/MawHive.txt"
var mawSpyder = "res://Assets/Text/TextFiles/Synergies/MawSpyder.txt"
var mawWalnut = "res://Assets/Text/TextFiles/Synergies/MawWalnut.txt"
var mawWyrm = "res://Assets/Text/TextFiles/Synergies/MawWyrm.txt"

var wyrmBase = "res://Assets/Text/TextFiles/Synergies/WyrmBase.txt"
var wyrmEye ="res://Assets/Text/TextFiles/Synergies/WyrmEye.txt"
var wyrmHive ="res://Assets/Text/TextFiles/Synergies/WyrmHive.txt"
var wyrmMaw ="res://Assets/Text/TextFiles/Synergies/WyrmMaw.txt"
var wyrmSpyder ="res://Assets/Text/TextFiles/Synergies/WyrmSpyder.txt"
var wyrmWalnut ="res://Assets/Text/TextFiles/Synergies/WyrmWalnut.txt"



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
var current_page := 2

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
	pass
	$"../../Camera2D".make_current()
	print("Plant AnimatedTextureRect: _ready() called")
	$"../../InteractiveBook2D".go_to_page(current_page)
	current_page = current_page + 1
		# Set default button textures based on current colors
	_update_button_textures()
	
	# Set initial sprites if none are set
	#if sprites == null:
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

func set_demon_variations(newDemon : GlobalResourceLoader.PlantType):
	is_in_synergy = true 
	var new_images = []
	new_images = GlobalResourceLoader.get_demon_image_variations(newDemon)
	$"../../HBoxContainer/AllPlantRows/Row1".visible = false
	$"../../HBoxContainer/AllPlantRows/Row2".visible = false
	$"../../HBoxContainer/AllPlantRows/Row3".visible = false
	
	$"../../HBoxContainer/AllPlantRows/AltRow1".visible = true 
	$"../../HBoxContainer/AllPlantRows/AltRow2".visible = true 
	$"../../HBoxContainer/AllPlantRows/AltRow3".visible = true 
	
	var count = 0 
	for this_image in new_images:
		match count:
			0:
				$"../../HBoxContainer/AllPlantRows/AltRow1/Alt1".texture_normal = this_image
			1:
				$"../../HBoxContainer/AllPlantRows/AltRow1/Alt2".texture_normal= this_image
			2:
				$"../../HBoxContainer/AllPlantRows/AltRow2/Alt3".texture_normal= this_image
			3:
				$"../../HBoxContainer/AllPlantRows/AltRow2/Alt4".texture_normal= this_image
			4:
				$"../../HBoxContainer/AllPlantRows/AltRow3/Alt5".texture_normal= this_image
			5:
				$"../../HBoxContainer/AllPlantRows/AltRow3/Alt6".texture_normal= this_image
				
		count+=1
	
	pass
	
func _on_sunflower_pressed() -> void:
	current_page = current_page + 1
	$"../../InteractiveBook2D".go_to_page(current_page)
	
	visible = true
	staticPreview.visible = false 
	current_plant = PLANT.SUNFLOWER
	sprites = GlobalResourceLoader.get_plant_animation(
		GlobalResourceLoader.PlantType.SUNFLOWER)
	play()
	set_text(sunflowerDescription)
	set_demon_variations(GlobalResourceLoader.PlantType.SUNFLOWER)

func _on_peashooter_pressed() -> void:
	visible = true
	current_page = current_page + 1
	$"../../InteractiveBook2D".go_to_page(current_page)
	staticPreview.visible = false 
	current_plant = PLANT.SPYDER
	sprites = GlobalResourceLoader.get_plant_animation(
		GlobalResourceLoader.PlantType.PEASHOOTER)
	play()
	set_text(peashooterDescription)
	set_demon_variations(GlobalResourceLoader.PlantType.PEASHOOTER)


func _on_walnut_pressed() -> void:
	current_page = current_page + 1
	$"../../InteractiveBook2D".go_to_page(current_page)
	visible = true
	staticPreview.visible = false 
	current_plant = PLANT.OCCULAR_SPINE
	sprites = GlobalResourceLoader.get_plant_animation(
		GlobalResourceLoader.PlantType.WALNUT)
	play()
	set_text(walnutDescription)
	set_demon_variations(GlobalResourceLoader.PlantType.WALNUT)


func _on_eye_bomb_pressed() -> void:
	visible = true
	staticPreview.visible = false 
	current_plant = PLANT.EYE_BOMB
	sprites = GlobalResourceLoader.get_plant_animation(
		GlobalResourceLoader.PlantType.BOMBPLANT)
	play()
	set_text(eyeBombDescription)


func _on_egg_wrym_pressed() -> void:
	current_page = current_page + 1
	$"../../InteractiveBook2D".go_to_page(current_page)
	visible = true
	staticPreview.visible = false 
	current_plant = PLANT.EGG_WYRM
	sprites = GlobalResourceLoader.get_plant_animation(
		GlobalResourceLoader.PlantType.EGGWYRM)
	play()
	set_text(eggWyrmDescription)
	set_demon_variations(GlobalResourceLoader.PlantType.EGGWYRM)

func _on_hive_pressed() -> void:
	current_page = current_page + 1
	$"../../InteractiveBook2D".go_to_page(current_page)
	visible = true
	staticPreview.visible = false 
	current_plant = PLANT.HIVE
	sprites = GlobalResourceLoader.get_plant_animation(
		GlobalResourceLoader.PlantType.HIVE)
	play()
	set_text(hiveDescription)
	set_demon_variations(GlobalResourceLoader.PlantType.HIVE)


func _on_maw_pressed() -> void:
	current_page = current_page + 1
	$"../../InteractiveBook2D".go_to_page(current_page)
	visible = true
	staticPreview.visible = false 
	current_plant = PLANT.MAW
	sprites = GlobalResourceLoader.get_plant_animation(
		GlobalResourceLoader.PlantType.MAW)
	play()
	set_text(mawDescription)
	set_demon_variations(GlobalResourceLoader.PlantType.MAW)
	


func _on_back_button_pressed() -> void:
	if is_in_synergy == false:
		get_parent().get_parent().visible = false 

		print("BBack Button Pressed")
		self.visible = false 
		
		#Global.unHidePlantSelectionMenu()
		#Global.game_controller.restore_dual_scenes()
		Global.game_controller.restore_previous_scene()
	else:
		is_in_synergy = false
		$"../../HBoxContainer/AllPlantRows/Row1".visible = true
		$"../../HBoxContainer/AllPlantRows/Row2".visible = true
		$"../../HBoxContainer/AllPlantRows/Row3".visible = true
	
		$"../../HBoxContainer/AllPlantRows/AltRow1".visible = false 
		$"../../HBoxContainer/AllPlantRows/AltRow2".visible = false 
		$"../../HBoxContainer/AllPlantRows/AltRow3".visible = false 
		current_page = current_page - 1
		$"../../InteractiveBook2D".go_to_page(current_page)
	
	
	




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
	if is_in_synergy == false:
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


func _on_alt_1_pressed() -> void:
	current_page = current_page + 1
	$"../../InteractiveBook2D".go_to_page(current_page)
	
	visible = false
	staticPreview.visible = true
	match current_plant:
		PLANT.SUNFLOWER:
			staticPreview.texture = alt1.texture_normal
			set_text(occulumBase)
		PLANT.SPYDER:
			staticPreview.texture = alt1.texture_normal
			set_text(spyderBase)
		PLANT.OCCULAR_SPINE:
			staticPreview.texture = alt1.texture_normal
			set_text(walnutBase)
		PLANT.EGG_WYRM:
			staticPreview.texture = alt1.texture_normal
			set_text(wyrmBase)
		PLANT.HIVE:
			staticPreview.texture = alt1.texture_normal
			set_text(hiveBase)
		PLANT.MAW:
			staticPreview.texture = alt1.texture_normal
			set_text(mawBase)


func _on_alt_2_pressed() -> void:
	current_page = current_page + 1
	$"../../InteractiveBook2D".go_to_page(current_page)
	staticPreview.visible = true
	visible = false
	match current_plant:
		PLANT.SUNFLOWER:
			staticPreview.texture = alt2.texture_normal
			set_text(occulumMaw)
		PLANT.SPYDER:
			staticPreview.texture = alt2.texture_normal
			set_text(spyderHive)
		PLANT.OCCULAR_SPINE:
			staticPreview.texture = alt2.texture_normal
			set_text(walnutEye)
		PLANT.EGG_WYRM:
			staticPreview.texture = alt2.texture_normal
			set_text(wyrmEye)
		PLANT.HIVE:
			staticPreview.texture = alt2.texture_normal
			set_text(hiveMaw)
		PLANT.MAW:
			staticPreview.texture = alt2.texture_normal
			set_text(mawHive)


func _on_alt_3_pressed() -> void:
	current_page = current_page + 1
	$"../../InteractiveBook2D".go_to_page(current_page)
	staticPreview.visible = true
	visible = false
	match current_plant:
		PLANT.SUNFLOWER:
			staticPreview.texture = alt3.texture_normal
			set_text(occulumHive)
		PLANT.SPYDER:
			staticPreview.texture = alt3.texture_normal
			set_text(spyderMaw)
		PLANT.OCCULAR_SPINE:
			staticPreview.texture = alt3.texture_normal
			set_text(walnutHive)
		PLANT.EGG_WYRM:
			staticPreview.texture = alt3.texture_normal
			set_text(wyrmHive)
		PLANT.HIVE:
			staticPreview.texture = alt3.texture_normal
			set_text(hiveSpyder)
		PLANT.MAW:
			staticPreview.texture = alt3.texture_normal
			set_text(mawSpyder)


func _on_alt_4_pressed() -> void:
	current_page = current_page + 1
	$"../../InteractiveBook2D".go_to_page(current_page)
	staticPreview.visible = true
	visible = false
	match current_plant:
		PLANT.SUNFLOWER:
			staticPreview.texture = alt4.texture_normal
			set_text(occulumSpyder)
		PLANT.SPYDER:
			staticPreview.texture = alt4.texture_normal
			set_text(spyderEye)
		PLANT.OCCULAR_SPINE:
			staticPreview.texture = alt4.texture_normal
			set_text(walnutMaw)
		PLANT.EGG_WYRM:
			staticPreview.texture = alt4.texture_normal
			set_text(wyrmMaw)
		PLANT.HIVE:
			staticPreview.texture = alt4.texture_normal
			set_text(hiveEye)
		PLANT.MAW:
			staticPreview.texture = alt4.texture_normal
			set_text(mawEye)


func _on_alt_5_pressed() -> void:
	current_page = current_page + 1
	$"../../InteractiveBook2D".go_to_page(current_page)
	staticPreview.visible = true
	visible = false
	match current_plant:
		PLANT.SUNFLOWER:
			staticPreview.texture = alt5.texture_normal
			set_text(occulumWalnut)
		PLANT.SPYDER:
			staticPreview.texture = alt5.texture_normal
			set_text(spyderWalnut)
		PLANT.OCCULAR_SPINE:
			staticPreview.texture = alt5.texture_normal
			set_text(walnutSpyder)
		PLANT.EGG_WYRM:
			staticPreview.texture = alt5.texture_normal
			set_text(wyrmWalnut)
		PLANT.HIVE:
			staticPreview.texture = alt5.texture_normal
			set_text(hiveWalnut)
		PLANT.MAW:
			staticPreview.texture = alt5.texture_normal
			set_text(mawWalnut)


func _on_alt_6_pressed() -> void:
	current_page = current_page + 1
	$"../../InteractiveBook2D".go_to_page(current_page)
	staticPreview.visible = true
	visible = false
	match current_plant:
		PLANT.SUNFLOWER:
			staticPreview.texture = alt6.texture_normal
			set_text(occulumWyrm)
		PLANT.SPYDER:
			staticPreview.texture = alt6.texture_normal
			set_text(spyderWyrm)
		PLANT.OCCULAR_SPINE:
			staticPreview.texture = alt6.texture_normal
			set_text(walnutWyrm)
		PLANT.EGG_WYRM:
			staticPreview.texture = alt6.texture_normal
			set_text(wyrmWalnut)
		PLANT.HIVE:
			staticPreview.texture = alt6.texture_normal
			set_text(hiveWyrm)
		PLANT.MAW:
			staticPreview.texture = alt6.texture_normal
			set_text(mawWyrm)
