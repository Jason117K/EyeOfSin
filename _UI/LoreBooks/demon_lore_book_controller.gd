extends AnimatedTextureRect

#Button References
@onready var sunflowerButton = $"../AllDemonRows/Row1/Sunflower"
@onready var peashooterButton = $"../AllDemonRows/Row1/Peashooter"
@onready var walnutButton = $"../AllDemonRows/Row1/Walnut"
@onready var eyeBombButton = $"../AllDemonRows/Row2/EyeBomb"
@onready var eggWyrmButton = $"../AllDemonRows/Row2/EggWrym" 
@onready var hiveButton = $"../AllDemonRows/Row2/Hive" 
@onready var mawButton = $"../AllDemonRows/Row3/Maw"

@onready var currentDemonLabel = $"../../CurrentDemonLabel"
@onready var bgDarken = $"../../BGDarkEn"
@onready var synergyPanel = $"../../ToolTips"
@onready var backOutDetailsButton = $"../../BackOutDetails"
#@onready var moreInfoButton =$"../../HBoxContainer/AllDemonRows/HBoxContainer/MoreInfoButton"
@onready var staticPreview := $"../../StaticPreview"

@onready var alt1 = $"../../HBoxContainer/AllDemonRows/AltRow1/Alt1"
@onready var alt2 = $"../../HBoxContainer/AllDemonRows/AltRow1/Alt2"
@onready var alt3 = $"../../HBoxContainer/AllDemonRows/AltRow2/Alt3"
@onready var alt4 = $"../../HBoxContainer/AllDemonRows/AltRow2/Alt4"
@onready var alt5 = $"../../HBoxContainer/AllDemonRows/AltRow3/Alt5"
@onready var alt6 = $"../../HBoxContainer/AllDemonRows/AltRow3/Alt6"

var is_in_synergy = false

#Demon Text Descriptions
var sunflowerDescription := "res://_Assets/Text/TextFiles/DemonDescriptions/SunflowerDescription.txt"
var peashooterDescription := "res://_Assets/Text/TextFiles/DemonDescriptions/PeashooterDescription.txt"
var walnutDescription := "res://_Assets/Text/TextFiles/DemonDescriptions/WalnutDescription.txt"
var eyeBombDescription := "res://_Assets/Text/TextFiles/DemonDescriptions/EyeBombDescription.txt"
var eggWyrmDescription := "res://_Assets/Text/TextFiles/DemonDescriptions/EggWyrmDescription.txt"
var hiveDescription := "res://_Assets/Text/TextFiles/DemonDescriptions/HiveDescription.txt"
var mawDescription := "res://_Assets/Text/TextFiles/DemonDescriptions/MawDescription.txt"


var mawSpyderText =  "res://_Assets/Text/TextFiles/SpiderMawBuff.txt"
var mawEggText = "res://_Assets/Text/TextFiles/EggMawBuff.txt"
var spineMawText =  "res://_Assets/Text/TextFiles/SpineMawBuff.txt"
var hiveMawText = "res://_Assets/Text/TextFiles/HiveMawBuff.txt"
var hiveEggText = "res://_Assets/Text/TextFiles/WaspEggBuff.txt"
var hiveSpyderText = "res://_Assets/Text/TextFiles/hiveSpyderBuff.txt"
var eggSpineText = "res://_Assets/Text/TextFiles/eggSpineBuff.txt"
var sunSpyderText = "res://_Assets/Text/TextFiles/SunSpyderBuff.txt"
var sunEggText = "res://_Assets/Text/TextFiles/SunEggWyrmBuff.txt"
var sunMawText = "res://_Assets/Text/TextFiles/SunMawBuff.txt"
var sunSpineText = "res://_Assets/Text/TextFiles/SunSpineBuff.txt"
var sunHiveText = "res://_Assets/Text/TextFiles/SunHiveBuff.txt"


var occulumBase = "res://_Assets/Text/TextFiles/Synergies/EyeBase.txt"
var occulumHive = "res://_Assets/Text/TextFiles/Synergies/EyeHive.txt"
var occulumMaw = "res://_Assets/Text/TextFiles/Synergies/EyeMaw.txt"
var occulumSpyder = "res://_Assets/Text/TextFiles/Synergies/EyeSpyder.txt"
var occulumWalnut = "res://_Assets/Text/TextFiles/Synergies/EyeWalnut.txt"
var occulumWyrm = "res://_Assets/Text/TextFiles/Synergies/EyeWyrm.txt"

var spyderBase = "res://_Assets/Text/TextFiles/Synergies/SpyderBase.txt"
var spyderEye = "res://_Assets/Text/TextFiles/Synergies/SpyderEye.txt"
var spyderHive = "res://_Assets/Text/TextFiles/Synergies/SpyderHive.txt"
var spyderMaw = "res://_Assets/Text/TextFiles/Synergies/SpyderMaw.txt"
var spyderWalnut = "res://_Assets/Text/TextFiles/Synergies/SpyderWalnut.txt"
var spyderWyrm = "res://_Assets/Text/TextFiles/Synergies/SpyderWyrm.txt"

var hiveBase = "res://_Assets/Text/TextFiles/Synergies/HiveBase.txt"
var hiveEye = "res://_Assets/Text/TextFiles/Synergies/HiveEye.txt"
var hiveMaw = "res://_Assets/Text/TextFiles/Synergies/HiveMaw.txt"
var hiveSpyder = "res://_Assets/Text/TextFiles/Synergies/HiveSpyder.txt"
var hiveWalnut = "res://_Assets/Text/TextFiles/Synergies/HiveWalnut.txt"
var hiveWyrm = "res://_Assets/Text/TextFiles/Synergies/HiveWyrm.txt"

var walnutBase = "res://_Assets/Text/TextFiles/Synergies/WalnutBase.txt"
var walnutEye = "res://_Assets/Text/TextFiles/Synergies/WalnutEye.txt"
var walnutHive = "res://_Assets/Text/TextFiles/Synergies/WalnutHive.txt"
var walnutMaw = "res://_Assets/Text/TextFiles/Synergies/WalnutMaw.txt"
var walnutSpyder = "res://_Assets/Text/TextFiles/Synergies/WalnutSpyder.txt"
var walnutWyrm = "res://_Assets/Text/TextFiles/Synergies/WalnutWyrm.txt"

var mawBase = "res://_Assets/Text/TextFiles/Synergies/MawBase.txt"
var mawEye = "res://_Assetss/Text/TextFiles/Synergies/MawEye.txt"
var mawHive = "res://_Assets/Text/TextFiles/Synergies/MawHive.txt"
var mawSpyder = "res://_Assets/Text/TextFiles/Synergies/MawSpyder.txt"
var mawWalnut = "res://_Assets/Text/TextFiles/Synergies/MawWalnut.txt"
var mawWyrm = "res://_Assets/Text/TextFiles/Synergies/MawWyrm.txt"

var wyrmBase = "res://_Assets/Text/TextFiles/Synergies/WyrmBase.txt"
var wyrmEye ="res://_Assets/Text/TextFiles/Synergies/WyrmEye.txt"
var wyrmHive ="res://_Assets/Text/TextFiles/Synergies/WyrmHive.txt"
var wyrmMaw ="res://_Assets/Text/TextFiles/Synergies/WyrmMaw.txt"
var wyrmSpyder ="res://_Assets/Text/TextFiles/Synergies/WyrmSpyder.txt"
var wyrmWalnut ="res://_Assets/Text/TextFiles/Synergies/WyrmWalnut.txt"



var mawSpyderScene = preload("res://_UI/GameDemonstrations/DemonTutorials/maw_spider_buff.tscn")
var mawEggScene = preload("res://_UI/GameDemonstrations/DemonTutorials/maw_egg_buff.tscn")
var spineMawScene = preload("res://_UI/GameDemonstrations/DemonTutorials/spine_maw_buff.tscn")
var hiveMawScene  = preload("res://_UI/GameDemonstrations/DemonTutorials/maw_hive_buff.tscn")
var spineEggScene = preload("res://_UI/GameDemonstrations/DemonTutorials/egg_spine_buff.tscn")
var hiveEggScene = preload("res://_UI/GameDemonstrations/DemonTutorials/hive_egg_buff.tscn")
var hiveSpyderScene = preload("res://_UI/GameDemonstrations/DemonTutorials/hive_spyder_buff.tscn")
var sunSpyderScene = preload("res://_UI/GameDemonstrations/DemonTutorials/sunflower_spyder_buff.tscn")
var sunEggScene = preload("res://_UI/GameDemonstrations/DemonTutorials/sun_egg_buff.tscn")
var sunHiveScene = preload("res://_UI/GameDemonstrations/DemonTutorials/sun_hive_buff.tscn")
var sunSpineScene = preload("res://_UI/GameDemonstrations/DemonTutorials/sun_spine_buff.tscn")
var sunMawScene = preload("res://_UI/GameDemonstrations/DemonTutorials/sun_maw_buff.tscn")

var count := 0
var current_page := 2

enum DEMON {
	OCCULUM,
	CRAWLER,
	SPINALOCCULUM,
	WYRM,
	HIVE,
	MAW,
}

var current_demon = DEMON.OCCULUM

func _ready() -> void:
	pass
	$"../../Camera2D".make_current()
	print("Demon AnimatedTextureRect: _ready() called")
	$"../../InteractiveBook2D".go_to_page(current_page)
	current_page = current_page + 1
		# Set default button textures based on current colors
	_update_button_textures()
	
	# Set initial sprites if none are set
	#if sprites == null:
	var demon_type = GlobalResourceLoader.DemonType.OCCULUM
	sprites = GlobalResourceLoader.get_demon_animation(demon_type)
	
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
		sunflowerButton.texture_normal = GlobalResourceLoader.get_demon_image(
			GlobalResourceLoader.DemonType.OCCULUM)
	if peashooterButton != null:
		peashooterButton.texture_normal = GlobalResourceLoader.get_demon_image(
			GlobalResourceLoader.DemonType.CRAWLER)
	if walnutButton != null:
		walnutButton.texture_normal = GlobalResourceLoader.get_demon_image(
			GlobalResourceLoader.DemonType.SPINALOCCULUM)
	

	if eggWyrmButton != null:
		eggWyrmButton.texture_normal = GlobalResourceLoader.get_demon_image(
			GlobalResourceLoader.DemonType.WYRM)
	if hiveButton != null:
		hiveButton.texture_normal = GlobalResourceLoader.get_demon_image(
			GlobalResourceLoader.DemonType.HIVE)
			
	if mawButton != null:
		mawButton.texture_normal = GlobalResourceLoader.get_demon_image(
			GlobalResourceLoader.DemonType.MAW)
			
			
			
			
			
#Sets the current Demon Description Text
func set_text(newFile : String):
	var file = FileAccess.open(newFile, FileAccess.READ)
	var newText = file.get_as_text()
	file.close()
	currentDemonLabel.text = newText

func set_demon_variations(newDemon : GlobalResourceLoader.DemonType):
	is_in_synergy = true 
	var new_images = []
	new_images = GlobalResourceLoader.get_demon_image_variations(newDemon)
	$"../../HBoxContainer/AllDemonRows/Row1".visible = false
	$"../../HBoxContainer/AllDemonRows/Row2".visible = false
	$"../../HBoxContainer/AllDemonRows/Row3".visible = false
	
	$"../../HBoxContainer/AllDemonRows/AltRow1".visible = true 
	$"../../HBoxContainer/AllDemonRows/AltRow2".visible = true 
	$"../../HBoxContainer/AllDemonRows/AltRow3".visible = true 
	
	var count = 0 
	for this_image in new_images:
		match count:
			0:
				$"../../HBoxContainer/AllDemonRows/AltRow1/Alt1".texture_normal = this_image
			1:
				$"../../HBoxContainer/AllDemonRows/AltRow1/Alt2".texture_normal= this_image
			2:
				$"../../HBoxContainer/AllDemonRows/AltRow2/Alt3".texture_normal= this_image
			3:
				$"../../HBoxContainer/AllDemonRows/AltRow2/Alt4".texture_normal= this_image
			4:
				$"../../HBoxContainer/AllDemonRows/AltRow3/Alt5".texture_normal= this_image
			5:
				$"../../HBoxContainer/AllDemonRows/AltRow3/Alt6".texture_normal= this_image
				
		count+=1
	
	pass
	
func _on_sunflower_pressed() -> void:
	current_page = current_page + 1
	$"../../InteractiveBook2D".go_to_page(current_page)
	
	visible = true
	staticPreview.visible = false 
	current_demon = DEMON.OCCULUM
	sprites = GlobalResourceLoader.get_demon_animation(
		GlobalResourceLoader.DemonType.OCCULUM)
	play()
	set_text(sunflowerDescription)
	set_demon_variations(GlobalResourceLoader.DemonType.OCCULUM)

func _on_peashooter_pressed() -> void:
	visible = true
	current_page = current_page + 1
	$"../../InteractiveBook2D".go_to_page(current_page)
	staticPreview.visible = false 
	current_demon = DEMON.CRAWLER
	sprites = GlobalResourceLoader.get_demon_animation(
		GlobalResourceLoader.DemonType.CRAWLER)
	play()
	set_text(peashooterDescription)
	set_demon_variations(GlobalResourceLoader.DemonType.CRAWLER)


func _on_walnut_pressed() -> void:
	current_page = current_page + 1
	$"../../InteractiveBook2D".go_to_page(current_page)
	visible = true
	staticPreview.visible = false 
	current_demon = DEMON.SPINALOCCULUM
	sprites = GlobalResourceLoader.get_demon_animation(
		GlobalResourceLoader.DemonType.SPINALOCCULUM)
	play()
	set_text(walnutDescription)
	set_demon_variations(GlobalResourceLoader.DemonType.SPINALOCCULUM)



func _on_egg_wrym_pressed() -> void:
	current_page = current_page + 1
	$"../../InteractiveBook2D".go_to_page(current_page)
	visible = true
	staticPreview.visible = false 
	current_demon = DEMON.WYRM
	sprites = GlobalResourceLoader.get_demon_animation(
		GlobalResourceLoader.DemonType.WYRM)
	play()
	set_text(eggWyrmDescription)
	set_demon_variations(GlobalResourceLoader.DemonType.WYRM)

func _on_hive_pressed() -> void:
	current_page = current_page + 1
	$"../../InteractiveBook2D".go_to_page(current_page)
	visible = true
	staticPreview.visible = false 
	current_demon = DEMON.HIVE
	sprites = GlobalResourceLoader.get_demon_animation(
		GlobalResourceLoader.DemonType.HIVE)
	play()
	set_text(hiveDescription)
	set_demon_variations(GlobalResourceLoader.DemonType.HIVE)


func _on_maw_pressed() -> void:
	current_page = current_page + 1
	$"../../InteractiveBook2D".go_to_page(current_page)
	visible = true
	staticPreview.visible = false 
	current_demon = DEMON.MAW
	sprites = GlobalResourceLoader.get_demon_animation(
		GlobalResourceLoader.DemonType.MAW)
	play()
	set_text(mawDescription)
	set_demon_variations(GlobalResourceLoader.DemonType.MAW)
	


func _on_back_button_pressed() -> void:
	if is_in_synergy == false:
		get_parent().get_parent().visible = false 

		print("BBack Button Pressed")
		self.visible = false 
		
		#Global.unHideDemonSelectionMenu()
		#Global.game_controller.restore_dual_scenes()
		Global.game_controller.restore_previous_scene()
	else:
		is_in_synergy = false
		$"../../HBoxContainer/AllDemonRows/Row1".visible = true
		$"../../HBoxContainer/AllDemonRows/Row2".visible = true
		$"../../HBoxContainer/AllDemonRows/Row3".visible = true
	
		$"../../HBoxContainer/AllDemonRows/AltRow1".visible = false 
		$"../../HBoxContainer/AllDemonRows/AltRow2".visible = false 
		$"../../HBoxContainer/AllDemonRows/AltRow3".visible = false 
		current_page = current_page - 1
		$"../../InteractiveBook2D".go_to_page(current_page)
	
	
	




func _on_more_info_button_pressed() -> void:
	bgDarken.visible = true 
	backOutDetailsButton.visible = true 
	synergyPanel.visible = true 
	
	match current_demon:
		DEMON.OCCULUM:
			synergyPanel.set_visual_tutorial_text(sunSpyderText)
			synergyPanel.set_visual_tutorial_visual(sunSpyderScene.instantiate())
		DEMON.CRAWLER:
			synergyPanel.set_visual_tutorial_text(mawSpyderText)
			synergyPanel.set_visual_tutorial_visual(mawSpyderScene.instantiate())
		DEMON.SPINALOCCULUM:
			synergyPanel.set_visual_tutorial_text(eggSpineText)
			synergyPanel.set_visual_tutorial_visual(spineEggScene.instantiate())	
		DEMON.WYRM:
			synergyPanel.set_visual_tutorial_text(mawEggText)
			synergyPanel.set_visual_tutorial_visual(mawEggScene.instantiate())
		DEMON.HIVE:
			synergyPanel.set_visual_tutorial_text(hiveMawText)
			synergyPanel.set_visual_tutorial_visual(hiveMawScene.instantiate())
		DEMON.MAW:
			synergyPanel.set_visual_tutorial_text(mawSpyderText)
			synergyPanel.set_visual_tutorial_visual(mawSpyderScene.instantiate())


func _on_back_out_details_pressed() -> void:
	if is_in_synergy == false:
		bgDarken.visible = false 
		backOutDetailsButton.visible = false 
		synergyPanel.visible = false 

		


func _on_button_2_pressed() -> void:
	#print("CCount is ", count)
	count += 1
	setNextSynergyScene(current_demon,count)

func setNextSynergyScene(current_demon,this_count):
	match current_demon:
		DEMON.OCCULUM:
			match this_count:
				0:
					synergyPanel.set_visual_tutorial_text(sunSpyderText)
					synergyPanel.set_visual_tutorial_visual(sunSpyderScene.instantiate())
				1:
					synergyPanel.set_visual_tutorial_text(sunEggText)
					synergyPanel.set_visual_tutorial_visual(sunEggScene.instantiate())
				2:
					synergyPanel.set_visual_tutorial_text(sunHiveText)
					synergyPanel.set_visual_tutorial_visual(sunHiveScene.instantiate())
				3:
					synergyPanel.set_visual_tutorial_text(sunSpineText)
					synergyPanel.set_visual_tutorial_visual(sunSpineScene.instantiate())
				4:
					synergyPanel.set_visual_tutorial_text(sunMawText)
					synergyPanel.set_visual_tutorial_visual(sunMawScene.instantiate())
					count = -1
			
		DEMON.CRAWLER:
			match this_count:
				0:
					synergyPanel.set_visual_tutorial_text(mawSpyderText)
					synergyPanel.set_visual_tutorial_visual(mawSpyderScene.instantiate())
				1:
					synergyPanel.set_visual_tutorial_text(hiveSpyderText)
					synergyPanel.set_visual_tutorial_visual(hiveSpyderScene.instantiate())
					count = -1
		DEMON.SPINALOCCULUM:
			match this_count:
				0:
					synergyPanel.set_visual_tutorial_text(eggSpineText)
					synergyPanel.set_visual_tutorial_visual(spineEggScene.instantiate())	
				1:
					synergyPanel.set_visual_tutorial_text(spineMawText)
					synergyPanel.set_visual_tutorial_visual(spineMawScene.instantiate())
					count = -1
		DEMON.WYRM:
			match this_count:
				0:
					synergyPanel.set_visual_tutorial_text(mawEggText)
					synergyPanel.set_visual_tutorial_visual(mawEggScene.instantiate())
				1:
					synergyPanel.set_visual_tutorial_text(eggSpineText)
					synergyPanel.set_visual_tutorial_visual(spineEggScene.instantiate())
				2:
					synergyPanel.set_visual_tutorial_text(hiveEggText)
					synergyPanel.set_visual_tutorial_visual(hiveEggScene.instantiate())
					count = -1
		DEMON.HIVE:
			match this_count:
				0:
					synergyPanel.set_visual_tutorial_text(hiveMawText)
					synergyPanel.set_visual_tutorial_visual(hiveMawScene.instantiate())
				1:
					synergyPanel.set_visual_tutorial_text(hiveSpyderText)
					synergyPanel.set_visual_tutorial_visual(hiveSpyderScene.instantiate())
					
				2:
					synergyPanel.set_visual_tutorial_text(hiveEggText)
					synergyPanel.set_visual_tutorial_visual(hiveEggScene.instantiate())
					count = -1
		DEMON.MAW:
			match this_count:
				0:
					synergyPanel.set_visual_tutorial_text(mawSpyderText)
					synergyPanel.set_visual_tutorial_visual(mawSpyderScene.instantiate())	
				1:
					synergyPanel.set_visual_tutorial_text(mawEggText)
					synergyPanel.set_visual_tutorial_visual(mawEggScene.instantiate())
				2:
					synergyPanel.set_visual_tutorial_text(spineMawText)
					synergyPanel.set_visual_tutorial_visual(spineMawScene.instantiate())
				3:
					synergyPanel.set_visual_tutorial_text(hiveMawText)
					synergyPanel.set_visual_tutorial_visual(hiveMawScene.instantiate())
					count = -1
					#print("CCCCC Count is ", count)


func _on_alt_1_pressed() -> void:
	current_page = current_page + 1
	$"../../InteractiveBook2D".go_to_page(current_page)
	
	visible = false
	staticPreview.visible = true
	match current_demon:
		DEMON.OCCULUM:
			staticPreview.texture = alt1.texture_normal
			set_text(occulumBase)
		DEMON.CRAWLER:
			staticPreview.texture = alt1.texture_normal
			set_text(spyderBase)
		DEMON.SPINALOCCULUM:
			staticPreview.texture = alt1.texture_normal
			set_text(walnutBase)
		DEMON.WYRM:
			staticPreview.texture = alt1.texture_normal
			set_text(wyrmBase)
		DEMON.HIVE:
			staticPreview.texture = alt1.texture_normal
			set_text(hiveBase)
		DEMON.MAW:
			staticPreview.texture = alt1.texture_normal
			set_text(mawBase)


func _on_alt_2_pressed() -> void:
	current_page = current_page + 1
	$"../../InteractiveBook2D".go_to_page(current_page)
	staticPreview.visible = true
	visible = false
	match current_demon:
		DEMON.OCCULUM:
			staticPreview.texture = alt2.texture_normal
			set_text(occulumMaw)
		DEMON.CRAWLER:
			staticPreview.texture = alt2.texture_normal
			set_text(spyderHive)
		DEMON.SPINALOCCULUM:
			staticPreview.texture = alt2.texture_normal
			set_text(walnutEye)
		DEMON.WYRM:
			staticPreview.texture = alt2.texture_normal
			set_text(wyrmEye)
		DEMON.HIVE:
			staticPreview.texture = alt2.texture_normal
			set_text(hiveMaw)
		DEMON.MAW:
			staticPreview.texture = alt2.texture_normal
			set_text(mawHive)


func _on_alt_3_pressed() -> void:
	current_page = current_page + 1
	$"../../InteractiveBook2D".go_to_page(current_page)
	staticPreview.visible = true
	visible = false
	match current_demon:
		DEMON.OCCULUM:
			staticPreview.texture = alt3.texture_normal
			set_text(occulumHive)
		DEMON.CRAWLER:
			staticPreview.texture = alt3.texture_normal
			set_text(spyderMaw)
		DEMON.SPINALOCCULUM:
			staticPreview.texture = alt3.texture_normal
			set_text(walnutHive)
		DEMON.WYRM:
			staticPreview.texture = alt3.texture_normal
			set_text(wyrmHive)
		DEMON.HIVE:
			staticPreview.texture = alt3.texture_normal
			set_text(hiveSpyder)
		DEMON.MAW:
			staticPreview.texture = alt3.texture_normal
			set_text(mawSpyder)


func _on_alt_4_pressed() -> void:
	current_page = current_page + 1
	$"../../InteractiveBook2D".go_to_page(current_page)
	staticPreview.visible = true
	visible = false
	match current_demon:
		DEMON.OCCULUM:
			staticPreview.texture = alt4.texture_normal
			set_text(occulumSpyder)
		DEMON.CRAWLER:
			staticPreview.texture = alt4.texture_normal
			set_text(spyderEye)
		DEMON.SPINALOCCULUM:
			staticPreview.texture = alt4.texture_normal
			set_text(walnutMaw)
		DEMON.WYRM:
			staticPreview.texture = alt4.texture_normal
			set_text(wyrmMaw)
		DEMON.HIVE:
			staticPreview.texture = alt4.texture_normal
			set_text(hiveEye)
		DEMON.MAW:
			staticPreview.texture = alt4.texture_normal
			set_text(mawEye)


func _on_alt_5_pressed() -> void:
	current_page = current_page + 1
	$"../../InteractiveBook2D".go_to_page(current_page)
	staticPreview.visible = true
	visible = false
	match current_demon:
		DEMON.OCCULUM:
			staticPreview.texture = alt5.texture_normal
			set_text(occulumWalnut)
		DEMON.CRAWLER:
			staticPreview.texture = alt5.texture_normal
			set_text(spyderWalnut)
		DEMON.SPINALOCCULUM:
			staticPreview.texture = alt5.texture_normal
			set_text(walnutSpyder)
		DEMON.WYRM:
			staticPreview.texture = alt5.texture_normal
			set_text(wyrmSpyder)
		DEMON.HIVE:
			staticPreview.texture = alt5.texture_normal
			set_text(hiveWalnut)
		DEMON.MAW:
			staticPreview.texture = alt5.texture_normal
			set_text(mawWalnut)


func _on_alt_6_pressed() -> void:
	current_page = current_page + 1
	$"../../InteractiveBook2D".go_to_page(current_page)
	staticPreview.visible = true
	visible = false
	match current_demon:
		DEMON.OCCULUM:
			staticPreview.texture = alt6.texture_normal
			set_text(occulumWyrm)
		DEMON.CRAWLER:
			staticPreview.texture = alt6.texture_normal
			set_text(spyderWyrm)
		DEMON.SPINALOCCULUM:
			staticPreview.texture = alt6.texture_normal
			set_text(walnutWyrm)
		DEMON.WYRM:
			staticPreview.texture = alt6.texture_normal
			set_text(wyrmWalnut)
		DEMON.HIVE:
			staticPreview.texture = alt6.texture_normal
			set_text(hiveWyrm)
		DEMON.MAW:
			staticPreview.texture = alt6.texture_normal
			set_text(mawWyrm)
