extends AnimatedTextureRect

#Button References
@onready var occulumButton = $"../AllDemonRows/Row1/Occulum"
@onready var crawlerButton = $"../AllDemonRows/Row1/Crawler"
@onready var spinalOcculumButton = $"../AllDemonRows/Row1/SpinalOcculum"
@onready var wyrmButton = $"../AllDemonRows/Row2/Wrym" 
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
var occulumDescription := "res://_Assets/Text/TextFiles/DemonDescriptions/OcculumDescription.txt"
var crawlerDescription := "res://_Assets/Text/TextFiles/DemonDescriptions/PeashooterDescription.txt"
var spinalOcculumDescription := "res://_Assets/Text/TextFiles/DemonDescriptions/SpinalOcculumDescription.txt"
var wyrmDescription := "res://_Assets/Text/TextFiles/DemonDescriptions/WyrmDescription.txt"
var hiveDescription := "res://_Assets/Text/TextFiles/DemonDescriptions/HiveDescription.txt"
var mawDescription := "res://_Assets/Text/TextFiles/DemonDescriptions/MawDescription.txt"


var mawCrawlerText =  "res://_Assets/Text/TextFiles/SpiderMawBuff.txt"
var mawWyrmText = "res://_Assets/Text/TextFiles/MawBuff.txt"
var spineMawText =  "res://_Assets/Text/TextFiles/SpineMawBuff.txt"
var hiveMawText = "res://_Assets/Text/TextFiles/HiveMawBuff.txt"
var hiveWyrmText = "res://_Assets/Text/TextFiles/WaspWyrmBuff.txt"
var hiveSpyderText = "res://_Assets/Text/TextFiles/hiveSpyderBuff.txt"
var wyrmSpineText = "res://_Assets/Text/TextFiles/wyrmSpineBuff.txt"
var sunSpyderText = "res://_Assets/Text/TextFiles/SunSpyderBuff.txt"
var sunWyrmText = "res://_Assets/Text/TextFiles/SunWyrmBuff.txt"
var sunMawText = "res://_Assets/Text/TextFiles/SunMawBuff.txt"
var sunSpineText = "res://_Assets/Text/TextFiles/SunSpineBuff.txt"
var sunHiveText = "res://_Assets/Text/TextFiles/SunHiveBuff.txt"


var occulumBase = "res://_Assets/Text/TextFiles/Synergies/EyeBase.txt"
var occulumHive = "res://_Assets/Text/TextFiles/Synergies/EyeHive.txt"
var occulumMaw = "res://_Assets/Text/TextFiles/Synergies/EyeMaw.txt"
var occulumSpyder = "res://_Assets/Text/TextFiles/Synergies/EyeSpyder.txt"
var occulumSpinalOcculum = "res://_Assets/Text/TextFiles/Synergies/EyeSpinalOcculum.txt"
var occulumWyrm = "res://_Assets/Text/TextFiles/Synergies/EyeWyrm.txt"

var spyderBase = "res://_Assets/Text/TextFiles/Synergies/SpyderBase.txt"
var spyderEye = "res://_Assets/Text/TextFiles/Synergies/SpyderEye.txt"
var spyderHive = "res://_Assets/Text/TextFiles/Synergies/SpyderHive.txt"
var spyderMaw = "res://_Assets/Text/TextFiles/Synergies/SpyderMaw.txt"
var spyderSpinalOcculum = "res://_Assets/Text/TextFiles/Synergies/SpyderSpinalOcculum.txt"
var spyderWyrm = "res://_Assets/Text/TextFiles/Synergies/SpyderWyrm.txt"

var hiveBase = "res://_Assets/Text/TextFiles/Synergies/HiveBase.txt"
var hiveEye = "res://_Assets/Text/TextFiles/Synergies/HiveEye.txt"
var hiveMaw = "res://_Assets/Text/TextFiles/Synergies/HiveMaw.txt"
var hiveSpyder = "res://_Assets/Text/TextFiles/Synergies/HiveSpyder.txt"
var hiveSpinalOcculum = "res://_Assets/Text/TextFiles/Synergies/HiveSpinalOcculum.txt"
var hiveWyrm = "res://_Assets/Text/TextFiles/Synergies/HiveWyrm.txt"

var spinalOcculumBase = "res://_Assets/Text/TextFiles/Synergies/SpinalOcculumBase.txt"
var spinalOcculumEye = "res://_Assets/Text/TextFiles/Synergies/SpinalOcculumEye.txt"
var spinalOcculumHive = "res://_Assets/Text/TextFiles/Synergies/SpinalOcculumHive.txt"
var spinalOcculumMaw = "res://_Assets/Text/TextFiles/Synergies/SpinalOcculumMaw.txt"
var spinalOcculumSpyder = "res://_Assets/Text/TextFiles/Synergies/SpinalOcculumSpyder.txt"
var spinalOcculumWyrm = "res://_Assets/Text/TextFiles/Synergies/SpinalOcculumWyrm.txt"

var mawBase = "res://_Assets/Text/TextFiles/Synergies/MawBase.txt"
var mawEye = "res://_Assets/Text/TextFiles/Synergies/MawEye.txt"
var mawHive = "res://_Assets/Text/TextFiles/Synergies/MawHive.txt"
var mawSpyder = "res://_Assets/Text/TextFiles/Synergies/MawSpyder.txt"
var mawSpinalOcculum = "res://_Assets/Text/TextFiles/Synergies/MawSpinalOcculum.txt"
var mawWyrm = "res://_Assets/Text/TextFiles/Synergies/MawWyrm.txt"

var wyrmBase = "res://_Assets/Text/TextFiles/Synergies/WyrmBase.txt"
var wyrmEye ="res://_Assets/Text/TextFiles/Synergies/WyrmEye.txt"
var wyrmHive ="res://_Assets/Text/TextFiles/Synergies/WyrmHive.txt"
var wyrmMaw ="res://_Assets/Text/TextFiles/Synergies/WyrmMaw.txt"
var wyrmSpyder ="res://_Assets/Text/TextFiles/Synergies/WyrmSpyder.txt"
var wyrmSpinalOcculum ="res://_Assets/Text/TextFiles/Synergies/WyrmSpinalOcculum.txt"



var mawCrawlerScene = preload("res://_UI/GameDemonstrations/DemonTutorials/maw_spider_buff.tscn")
var mawWyrmScene = preload("res://_UI/GameDemonstrations/DemonTutorials/maw_wyrm_buff.tscn")
var spineMawScene = preload("res://_UI/GameDemonstrations/DemonTutorials/spine_maw_buff.tscn")
var hiveMawScene  = preload("res://_UI/GameDemonstrations/DemonTutorials/maw_hive_buff.tscn")
var spineWyrmScene = preload("res://_UI/GameDemonstrations/DemonTutorials/wyrm_spine_buff.tscn")
var hiveWyrmScene = preload("res://_UI/GameDemonstrations/DemonTutorials/hive_wyrm_buff.tscn")
var hiveSpyderScene = preload("res://_UI/GameDemonstrations/DemonTutorials/hive_spyder_buff.tscn")
var sunSpyderScene = preload("res://_UI/GameDemonstrations/DemonTutorials/occulum_spyder_buff.tscn")
var sunWyrmScene = preload("res://_UI/GameDemonstrations/DemonTutorials/sun_wyrm_buff.tscn")
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
	if occulumButton != null:
		occulumButton.texture_normal = GlobalResourceLoader.get_demon_image(
			GlobalResourceLoader.DemonType.OCCULUM)
	if crawlerButton != null:
		crawlerButton.texture_normal = GlobalResourceLoader.get_demon_image(
			GlobalResourceLoader.DemonType.CRAWLER)
	if spinalOcculumButton != null:
		spinalOcculumButton.texture_normal = GlobalResourceLoader.get_demon_image(
			GlobalResourceLoader.DemonType.SPINALOCCULUM)
	

	if wyrmButton != null:
		wyrmButton.texture_normal = GlobalResourceLoader.get_demon_image(
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
	
func _on_occulum_pressed() -> void:
	current_page = current_page + 1
	$"../../InteractiveBook2D".go_to_page(current_page)
	
	visible = true
	staticPreview.visible = false 
	current_demon = DEMON.OCCULUM
	sprites = GlobalResourceLoader.get_demon_animation(
		GlobalResourceLoader.DemonType.OCCULUM)
	play()
	set_text(occulumDescription)
	set_demon_variations(GlobalResourceLoader.DemonType.OCCULUM)

func _on_crawler_pressed() -> void:
	visible = true
	current_page = current_page + 1
	$"../../InteractiveBook2D".go_to_page(current_page)
	staticPreview.visible = false 
	current_demon = DEMON.CRAWLER
	sprites = GlobalResourceLoader.get_demon_animation(
		GlobalResourceLoader.DemonType.CRAWLER)
	play()
	set_text(crawlerDescription)
	set_demon_variations(GlobalResourceLoader.DemonType.CRAWLER)


func _on_spinalOcculum_pressed() -> void:
	current_page = current_page + 1
	$"../../InteractiveBook2D".go_to_page(current_page)
	visible = true
	staticPreview.visible = false 
	current_demon = DEMON.SPINALOCCULUM
	sprites = GlobalResourceLoader.get_demon_animation(
		GlobalResourceLoader.DemonType.SPINALOCCULUM)
	play()
	set_text(spinalOcculumDescription)
	set_demon_variations(GlobalResourceLoader.DemonType.SPINALOCCULUM)



func _on_wrym_pressed() -> void:
	current_page = current_page + 1
	$"../../InteractiveBook2D".go_to_page(current_page)
	visible = true
	staticPreview.visible = false 
	current_demon = DEMON.WYRM
	sprites = GlobalResourceLoader.get_demon_animation(
		GlobalResourceLoader.DemonType.WYRM)
	play()
	set_text(wyrmDescription)
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
			synergyPanel.set_visual_tutorial_text(mawCrawlerText)
			synergyPanel.set_visual_tutorial_visual(mawCrawlerScene.instantiate())
		DEMON.SPINALOCCULUM:
			synergyPanel.set_visual_tutorial_text(wyrmSpineText)
			synergyPanel.set_visual_tutorial_visual(spineWyrmScene.instantiate())	
		DEMON.WYRM:
			synergyPanel.set_visual_tutorial_text(mawWyrmText)
			synergyPanel.set_visual_tutorial_visual(mawWyrmScene.instantiate())
		DEMON.HIVE:
			synergyPanel.set_visual_tutorial_text(hiveMawText)
			synergyPanel.set_visual_tutorial_visual(hiveMawScene.instantiate())
		DEMON.MAW:
			synergyPanel.set_visual_tutorial_text(mawCrawlerText)
			synergyPanel.set_visual_tutorial_visual(mawCrawlerScene.instantiate())


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
					synergyPanel.set_visual_tutorial_text(sunWyrmText)
					synergyPanel.set_visual_tutorial_visual(sunWyrmScene.instantiate())
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
					synergyPanel.set_visual_tutorial_text(mawCrawlerText)
					synergyPanel.set_visual_tutorial_visual(mawCrawlerScene.instantiate())
				1:
					synergyPanel.set_visual_tutorial_text(hiveSpyderText)
					synergyPanel.set_visual_tutorial_visual(hiveSpyderScene.instantiate())
					count = -1
		DEMON.SPINALOCCULUM:
			match this_count:
				0:
					synergyPanel.set_visual_tutorial_text(wyrmSpineText)
					synergyPanel.set_visual_tutorial_visual(spineWyrmScene.instantiate())	
				1:
					synergyPanel.set_visual_tutorial_text(spineMawText)
					synergyPanel.set_visual_tutorial_visual(spineMawScene.instantiate())
					count = -1
		DEMON.WYRM:
			match this_count:
				0:
					synergyPanel.set_visual_tutorial_text(mawWyrmText)
					synergyPanel.set_visual_tutorial_visual(mawWyrmScene.instantiate())
				1:
					synergyPanel.set_visual_tutorial_text(wyrmSpineText)
					synergyPanel.set_visual_tutorial_visual(spineWyrmScene.instantiate())
				2:
					synergyPanel.set_visual_tutorial_text(hiveWyrmText)
					synergyPanel.set_visual_tutorial_visual(hiveWyrmScene.instantiate())
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
					synergyPanel.set_visual_tutorial_text(hiveWyrmText)
					synergyPanel.set_visual_tutorial_visual(hiveWyrmScene.instantiate())
					count = -1
		DEMON.MAW:
			match this_count:
				0:
					synergyPanel.set_visual_tutorial_text(mawCrawlerText)
					synergyPanel.set_visual_tutorial_visual(mawCrawlerScene.instantiate())	
				1:
					synergyPanel.set_visual_tutorial_text(mawWyrmText)
					synergyPanel.set_visual_tutorial_visual(mawWyrmScene.instantiate())
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
			set_text(spinalOcculumBase)
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
			set_text(spinalOcculumEye)
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
			set_text(spinalOcculumHive)
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
			set_text(spinalOcculumMaw)
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
			set_text(occulumSpinalOcculum)
		DEMON.CRAWLER:
			staticPreview.texture = alt5.texture_normal
			set_text(spyderSpinalOcculum)
		DEMON.SPINALOCCULUM:
			staticPreview.texture = alt5.texture_normal
			set_text(spinalOcculumSpyder)
		DEMON.WYRM:
			staticPreview.texture = alt5.texture_normal
			set_text(wyrmSpyder)
		DEMON.HIVE:
			staticPreview.texture = alt5.texture_normal
			set_text(hiveSpinalOcculum)
		DEMON.MAW:
			staticPreview.texture = alt5.texture_normal
			set_text(mawSpinalOcculum)


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
			set_text(spinalOcculumWyrm)
		DEMON.WYRM:
			staticPreview.texture = alt6.texture_normal
			set_text(wyrmSpinalOcculum)
		DEMON.HIVE:
			staticPreview.texture = alt6.texture_normal
			set_text(hiveWyrm)
		DEMON.MAW:
			staticPreview.texture = alt6.texture_normal
			set_text(mawWyrm)
