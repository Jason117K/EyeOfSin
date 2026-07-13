extends AnimatedTextureRect

#Button References
@onready var occulumButton := $"../../DemonCardMarginContainer/DemonHboxContainer/AllDemonRows/Row1/Occulum"
@onready var crawlerButton := $"../../DemonCardMarginContainer/DemonHboxContainer/AllDemonRows/Row1/Crawler"
@onready var spinalOcculumButton := $"../../DemonCardMarginContainer/DemonHboxContainer/AllDemonRows/Row2/Walnut"
@onready var wyrmButton := $"../../DemonCardMarginContainer/DemonHboxContainer/AllDemonRows/Row3/Wyrm"
@onready var hiveButton := $"../../DemonCardMarginContainer/DemonHboxContainer/AllDemonRows/Row3/Hive"
@onready var mawButton := $"../../DemonCardMarginContainer/DemonHboxContainer/AllDemonRows/Row2/Maw"

@onready var synergy_preview_container := $"../../CurrentDemonVboxContainer/SynergyPreviewContainer"

@onready var currentDemonLabel := $"../../CurrentDemonLabel"
@onready var bgDarken := $"../../BGDarkEn"
@onready var backOutDetailsButton := $"../../BackOutDetails"
@onready var staticPreview := $"../../StaticPreviewPanelContainer/StaticPreview"
@onready var static_preview_container := $"../../StaticPreviewPanelContainer"

var current_synergy_preview: Node = null

@onready var alt1 := $"../../DemonCardMarginContainer/DemonHboxContainer/AllDemonRows/Row1MarginContainer/AltRow1/Alt1"
@onready var alt2 := $"../../DemonCardMarginContainer/DemonHboxContainer/AllDemonRows/Row1MarginContainer/AltRow1/Alt2"
@onready var alt3 :=$"../../DemonCardMarginContainer/DemonHboxContainer/AllDemonRows/Row2MarginContainer/AltRow2/Alt3"
@onready var alt4 := $"../../DemonCardMarginContainer/DemonHboxContainer/AllDemonRows/Row2MarginContainer/AltRow2/Alt4"
@onready var alt5 := $"../../DemonCardMarginContainer/DemonHboxContainer/AllDemonRows/Row3MarginContainer/AltRow3/Alt5"
@onready var alt6 := $"../../DemonCardMarginContainer/DemonHboxContainer/AllDemonRows/Row3MarginContainer/AltRow3/Alt6"

@onready var alt_row_1 := $"../../DemonCardMarginContainer/DemonHboxContainer/AllDemonRows/Row1MarginContainer/AltRow1"
@onready var alt_row_2 := $"../../DemonCardMarginContainer/DemonHboxContainer/AllDemonRows/Row2MarginContainer/AltRow2"
@onready var alt_row_3 := $"../../DemonCardMarginContainer/DemonHboxContainer/AllDemonRows/Row3MarginContainer/AltRow3"

@onready var row_1 := $"../../DemonCardMarginContainer/DemonHboxContainer/AllDemonRows/Row1"
@onready var row_2 := $"../../DemonCardMarginContainer/DemonHboxContainer/AllDemonRows/Row2"
@onready var row_3 := $"../../DemonCardMarginContainer/DemonHboxContainer/AllDemonRows/Row3"

@onready var preview := $"../../CurrentDemonVboxContainer/SynergyPreviewContainer/SynergyMarginContainer/SynergyPreview"

@onready var red_display_card := load("res://_Entities/Demons/_Maw/EmptyDisplayCard_RED.png")

@onready var red_occulum  := $"../../RedCardOutlineMarginContainer/DemonCardBacks/AllDemonRows/Row1/Occulum"
@onready var red_crawler := $"../../RedCardOutlineMarginContainer/DemonCardBacks/AllDemonRows/Row1/Crawler"
@onready var red_spinal_occulum := $"../../RedCardOutlineMarginContainer/DemonCardBacks/AllDemonRows/Row2/Walnut"
@onready var red_maw := $"../../RedCardOutlineMarginContainer/DemonCardBacks/AllDemonRows/Row2/Maw"
@onready var red_wyrm := $"../../RedCardOutlineMarginContainer/DemonCardBacks/AllDemonRows/Row3/Wyrm"
@onready var red_hive := $"../../RedCardOutlineMarginContainer/DemonCardBacks/AllDemonRows/Row3/Hive"

var is_in_synergy := false

#Demon Text Descriptions
var occulumDescription := "res://_Assets/Text/TextFiles/DemonDescriptions/OcculumDescription.txt"
var crawlerDescription := "res://_Assets/Text/TextFiles/DemonDescriptions/CrawlerDescription.txt"
var spinalOcculumDescription := "res://_Assets/Text/TextFiles/DemonDescriptions/SpinalOcculumDescription.txt"
var wyrmDescription := "res://_Assets/Text/TextFiles/DemonDescriptions/WyrmDescription.txt"
var hiveDescription := "res://_Assets/Text/TextFiles/DemonDescriptions/HiveDescription.txt"
var mawDescription := "res://_Assets/Text/TextFiles/DemonDescriptions/MawDescription.txt"


var mawCrawlerText := "res://_Assets/Text/TextFiles/CrawlerMawBuff.txt"
var mawWyrmText := "res://_Assets/Text/TextFiles/MawBuff.txt"
var spineMawText := "res://_Assets/Text/TextFiles/SpineMawBuff.txt"
var hiveMawText := "res://_Assets/Text/TextFiles/HiveMawBuff.txt"
var hiveWyrmText := "res://_Assets/Text/TextFiles/WaspWyrmBuff.txt"
var hiveCrawlerText := "res://_Assets/Text/TextFiles/hiveCrawlerBuff.txt"
var wyrmSpineText := "res://_Assets/Text/TextFiles/wyrmSpineBuff.txt"
var occulumCrawlerText := "res://_Assets/Text/TextFiles/OcculumCrawlerBuff.txt"
var occulumWyrmText := "res://_Assets/Text/TextFiles/OcculumWyrmBuff.txt"
var occulumMawText := "res://_Assets/Text/TextFiles/OcculumMawBuff.txt"
var occulumSpineText := "res://_Assets/Text/TextFiles/OcculumSpineBuff.txt"
var occulumHiveText := "res://_Assets/Text/TextFiles/OcculumHiveBuff.txt"


var occulumBase := "res://_Assets/Text/TextFiles/Synergies/OcculumBase.txt"
var occulumHive := "res://_Assets/Text/TextFiles/Synergies/OcculumHive.txt"
var occulumMaw := "res://_Assets/Text/TextFiles/Synergies/OcculumMaw.txt"
var occulumCrawler := "res://_Assets/Text/TextFiles/Synergies/OcculumCrawler.txt"
var occulumSpinalOcculum := "res://_Assets/Text/TextFiles/Synergies/OcculumSpinalOcculum.txt"
var occulumWyrm := "res://_Assets/Text/TextFiles/Synergies/OcculumWyrm.txt"

var crawlerBase := "res://_Assets/Text/TextFiles/Synergies/CrawlerBase.txt"
var crawlerOcculum := "res://_Assets/Text/TextFiles/Synergies/CrawlerOcculum.txt"
var crawlerHive := "res://_Assets/Text/TextFiles/Synergies/CrawlerHive.txt"
var crawlerMaw := "res://_Assets/Text/TextFiles/Synergies/CrawlerMaw.txt"
var crawlerSpinalOcculum := "res://_Assets/Text/TextFiles/Synergies/CrawlerSpinalOcculum.txt"
var crawlerWyrm := "res://_Assets/Text/TextFiles/Synergies/CrawlerWyrm.txt"

var hiveBase := "res://_Assets/Text/TextFiles/Synergies/HiveBase.txt"
var hiveOcculum := "res://_Assets/Text/TextFiles/Synergies/HiveOcculum.txt"
var hiveMaw := "res://_Assets/Text/TextFiles/Synergies/HiveMaw.txt"
var hiveCrawler := "res://_Assets/Text/TextFiles/Synergies/HiveCrawler.txt"
var hiveSpinalOcculum := "res://_Assets/Text/TextFiles/Synergies/HiveSpinalOcculum.txt"
var hiveWyrm := "res://_Assets/Text/TextFiles/Synergies/HiveWyrm.txt"

var spinalOcculumBase := "res://_Assets/Text/TextFiles/Synergies/SpinalOcculumBase.txt"
var spinalOcculumOcculum := "res://_Assets/Text/TextFiles/Synergies/SpinalOcculumOcculum.txt"
var spinalOcculumHive := "res://_Assets/Text/TextFiles/Synergies/SpinalOcculumHive.txt"
var spinalOcculumMaw := "res://_Assets/Text/TextFiles/Synergies/SpinalOcculumMaw.txt"
var spinalOcculumCrawler := "res://_Assets/Text/TextFiles/Synergies/SpinalOcculumCrawler.txt"
var spinalOcculumWyrm := "res://_Assets/Text/TextFiles/Synergies/SpinalOcculumWyrm.txt"

var mawBase := "res://_Assets/Text/TextFiles/Synergies/MawBase.txt"
var mawOcculum := "res://_Assets/Text/TextFiles/Synergies/MawOcculum.txt"
var mawHive := "res://_Assets/Text/TextFiles/Synergies/MawHive.txt"
var mawCrawler := "res://_Assets/Text/TextFiles/Synergies/MawCrawler.txt"
var mawSpinalOcculum := "res://_Assets/Text/TextFiles/Synergies/MawSpinalOcculum.txt"
var mawWyrm := "res://_Assets/Text/TextFiles/Synergies/MawWyrm.txt"

var wyrmQueen := "res://_Assets/Text/TextFiles/Synergies/WyrmHive.txt"

var wyrmBase := "res://_Assets/Text/TextFiles/Synergies/WyrmBase.txt"
var wyrmOcculum := "res://_Assets/Text/TextFiles/Synergies/WyrmOcculum.txt"
var wyrmHive := "res://_Assets/Text/TextFiles/Synergies/WyrmHive.txt"
var wyrmMaw := "res://_Assets/Text/TextFiles/Synergies/WyrmMaw.txt"
var wyrmCrawler := "res://_Assets/Text/TextFiles/Synergies/WyrmCrawler.txt"
var wyrmSpinalOcculum := "res://_Assets/Text/TextFiles/Synergies/WyrmSpinalOcculum.txt"



var SynergyPreviewScene := preload("res://_UI/GameDemonstrations/SynergyPreview/synergy_preview.tscn")

var current_page := 2

var hover_target: float = 0.0

var tween_hover : Tween

enum DEMON {
	OCCULUM,
	CRAWLER,
	SPINALOCCULUM,
	WYRM,
	HIVE,
	MAW,
}

var current_demon := DEMON.OCCULUM

func _ready() -> void:
	pass
	Global.register_demon_codex(self)
	synergy_preview_container.hide()
	$"../../Camera2D".make_current()
	#print("Demon AnimatedTextureRect: _ready() called")
	$"../../InteractiveBook2D".go_to_page(current_page)
	current_page = current_page + 1
		# Set default button textures based on current colors
	_update_button_textures()
	
	# Set initial sprites if none are set
	#if sprites == null:
	var demon_type := GlobalResourceLoader.DemonType.OCCULUM
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
			
	occulumButton.pressed.connect(_on_occulum_pressed)
	wyrmButton.pressed.connect(_on_wrym_pressed)
	spinalOcculumButton.pressed.connect(_on_spinalOcculum_pressed)
	

# Update all button textures based on current color settings
func _update_button_textures() -> void:
	return
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
			
			
			
			
			
func _create_synergy_preview(demon_a: String, demon_b: String) -> CenterContainer:
	#var preview = SynergyPreviewScene.instantiate()
	preview.show()
	preview.setup(demon_a, demon_b)
	return preview

func _show_synergy_preview(demon_a: String, demon_b: String) -> void:
	_clear_synergy_preview()
	staticPreview.visible = false
	synergy_preview_container.show()
	current_synergy_preview = _create_synergy_preview(demon_a, demon_b)

func _clear_synergy_preview() -> void:
	if current_synergy_preview and is_instance_valid(current_synergy_preview):
		#current_synergy_preview.queue_free()
		#current_synergy_preview = null
		synergy_preview_container.hide()
		current_synergy_preview.hide()
		current_synergy_preview.clear_preview()

#Sets the current Demon Description Text
func set_text(newFile: String) -> void:
	currentDemonLabel.show()
	currentDemonLabel.text = Loc.text(newFile)

func set_demon_variations(newDemon: GlobalResourceLoader.DemonType) -> void:
	is_in_synergy = true
	var new_images := []
	new_images = GlobalResourceLoader.get_demon_image_variations(newDemon)
	row_1.visible = false
	row_2.visible = false
	row_3.visible = false
	
	alt_row_1.visible = true
	alt_row_2.visible = true
	alt_row_3.visible = true

	var count := 0
	
	for this_image in new_images:
		
		match count:
			0:
				alt1.texture_normal = this_image
			1:
				alt2.texture_normal= this_image
			2:
				alt3.texture_normal= this_image
			3:
				alt4.texture_normal= this_image
			4:
				alt5.texture_normal= this_image
			5:
				alt6.texture_normal= this_image
				
		count+=1
	
	pass
	
func _on_occulum_pressed() -> void:
	clear_all_focus()
	print("Occulum Pressed")
	current_page = current_page + 1
	$"../../InteractiveBook2D".go_to_page(current_page)
	_clear_synergy_preview()
	visible = true
	staticPreview.visible = false
	current_demon = DEMON.OCCULUM
	sprites = GlobalResourceLoader.get_demon_animation(
		GlobalResourceLoader.DemonType.OCCULUM)
	play()
	set_text(occulumDescription)
	set_demon_variations(GlobalResourceLoader.DemonType.OCCULUM)
	_on_alt_1_pressed()

func _on_crawler_pressed() -> void:
	clear_all_focus()
	visible = true
	current_page = current_page + 1
	$"../../InteractiveBook2D".go_to_page(current_page)
	_clear_synergy_preview()
	staticPreview.visible = false
	current_demon = DEMON.CRAWLER
	sprites = GlobalResourceLoader.get_demon_animation(
		GlobalResourceLoader.DemonType.CRAWLER)
	play()
	set_text(crawlerDescription)
	set_demon_variations(GlobalResourceLoader.DemonType.CRAWLER)
	_on_alt_1_pressed()



func _on_spinalOcculum_pressed() -> void:
	clear_all_focus()
	current_page = current_page + 1
	$"../../InteractiveBook2D".go_to_page(current_page)
	_clear_synergy_preview()
	visible = true
	staticPreview.visible = false
	current_demon = DEMON.SPINALOCCULUM
	sprites = GlobalResourceLoader.get_demon_animation(
		GlobalResourceLoader.DemonType.SPINALOCCULUM)
	play()
	set_text(spinalOcculumDescription)
	set_demon_variations(GlobalResourceLoader.DemonType.SPINALOCCULUM)
	_on_alt_1_pressed()



func _on_wrym_pressed() -> void:
	clear_all_focus()
	current_page = current_page + 1
	$"../../InteractiveBook2D".go_to_page(current_page)
	_clear_synergy_preview()
	visible = true
	staticPreview.visible = false
	current_demon = DEMON.WYRM
	sprites = GlobalResourceLoader.get_demon_animation(
		GlobalResourceLoader.DemonType.WYRM)
	play()
	set_text(wyrmDescription)
	set_demon_variations(GlobalResourceLoader.DemonType.WYRM)
	_on_alt_1_pressed()

func _on_hive_pressed() -> void:
	clear_all_focus()
	current_page = current_page + 1
	$"../../InteractiveBook2D".go_to_page(current_page)
	_clear_synergy_preview()
	visible = true
	staticPreview.visible = false
	current_demon = DEMON.HIVE
	sprites = GlobalResourceLoader.get_demon_animation(
		GlobalResourceLoader.DemonType.HIVE)
	play()
	set_text(hiveDescription)
	set_demon_variations(GlobalResourceLoader.DemonType.HIVE)
	_on_alt_1_pressed()


func _on_maw_pressed() -> void:
	clear_all_focus()
	current_page = current_page + 1
	$"../../InteractiveBook2D".go_to_page(current_page)
	_clear_synergy_preview()
	visible = true
	staticPreview.visible = false
	current_demon = DEMON.MAW
	sprites = GlobalResourceLoader.get_demon_animation(
		GlobalResourceLoader.DemonType.MAW)
	play()
	set_text(mawDescription)
	set_demon_variations(GlobalResourceLoader.DemonType.MAW)
	_on_alt_1_pressed()
	






func _on_back_button_pressed() -> void:
	_clear_synergy_preview()
	if is_in_synergy == false:
		get_parent().get_parent().visible = false

		print("BBack Button Pressed")
		self.visible = false

		#Global.unHideDemonSelectionMenu()
		#Global.game_controller.restore_dual_scenes()
		Global.game_controller.restore_previous_scene()
	else:
		is_in_synergy = false
		row_1.visible = true
		row_2.visible = true
		row_3.visible = true
		clear_all_focus()
		alt_row_1.visible = false
		alt_row_2.visible = false
		alt_row_3.visible = false
		current_page = current_page - 1
		staticPreview.show()
		static_preview_container.show()
		$"../../InteractiveBook2D".go_to_page(current_page)
	
	

func _on_back_out_details_pressed() -> void:
	if is_in_synergy == false:
		bgDarken.visible = false
		backOutDetailsButton.visible = false


func _on_alt_1_pressed() -> void:
	clear_all_focus()
	red_occulum.modulate = Color(1,1,1,1)
	current_page = current_page + 1
	$"../../InteractiveBook2D".go_to_page(current_page)
	_clear_synergy_preview()
	visible = false
	staticPreview.visible = true
	static_preview_container.show()
	match current_demon:
		DEMON.OCCULUM:
			staticPreview.texture = alt1.texture_normal
			set_text(occulumBase)
		DEMON.CRAWLER:
			staticPreview.texture = alt1.texture_normal
			set_text(crawlerBase)
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
	clear_all_focus()
	red_crawler.modulate = Color(1,1,1,1)
	current_page = current_page + 1
	$"../../InteractiveBook2D".go_to_page(current_page)
	visible = false
	static_preview_container.hide()
	match current_demon:
		DEMON.OCCULUM:
			set_text(occulumMaw)
			_show_synergy_preview("Occulum", "Maw")
		DEMON.CRAWLER:
			set_text(crawlerHive)
			_show_synergy_preview("Crawler", "Hive")
		DEMON.SPINALOCCULUM:
			set_text(spinalOcculumOcculum)
			_show_synergy_preview("SpinalOcculum", "Occulum")
		DEMON.WYRM:
			set_text(wyrmOcculum)
			_show_synergy_preview("Wyrm", "Occulum")
		DEMON.HIVE:
			set_text(hiveMaw)
			_show_synergy_preview("Hive", "Maw")
		DEMON.MAW:
			set_text(mawHive)
			_show_synergy_preview("Maw", "Hive")


func _on_alt_3_pressed() -> void:
	clear_all_focus()
	red_spinal_occulum.modulate = Color(1,1,1,1)
	current_page = current_page + 1
	$"../../InteractiveBook2D".go_to_page(current_page)
	visible = false
	static_preview_container.hide()
	match current_demon:
		DEMON.OCCULUM:
			set_text(occulumHive)
			_show_synergy_preview("Occulum", "Hive")
		DEMON.CRAWLER:
			set_text(crawlerMaw)
			_show_synergy_preview("Crawler", "Maw")
		DEMON.SPINALOCCULUM:
			set_text(spinalOcculumHive)
			_show_synergy_preview("SpinalOcculum", "Hive")
		DEMON.WYRM:
			set_text(wyrmHive)
			_show_synergy_preview("Wyrm", "Hive")
		DEMON.HIVE:
			set_text(hiveCrawler)
			_show_synergy_preview("Hive", "Crawler")
		DEMON.MAW:
			set_text(mawCrawler)
			_show_synergy_preview("Maw", "Crawler")


func _on_alt_4_pressed() -> void:
	clear_all_focus()
	red_maw.modulate = Color(1,1,1,1)
	current_page = current_page + 1
	$"../../InteractiveBook2D".go_to_page(current_page)
	visible = false
	static_preview_container.hide()
	match current_demon:
		DEMON.OCCULUM:
			set_text(occulumCrawler)
			_show_synergy_preview("Occulum", "Crawler")
		DEMON.CRAWLER:
			set_text(crawlerOcculum)
			_show_synergy_preview("Crawler", "Occulum")
		DEMON.SPINALOCCULUM:
			set_text(spinalOcculumMaw)
			_show_synergy_preview("SpinalOcculum", "Maw")
		DEMON.WYRM:
			set_text(wyrmMaw)
			_show_synergy_preview("Wyrm", "Maw")
		DEMON.HIVE:
			set_text(hiveOcculum)
			_show_synergy_preview("Hive", "Occulum")
		DEMON.MAW:
			set_text(mawOcculum)
			_show_synergy_preview("Maw", "Occulum")


func _on_alt_5_pressed() -> void:
	clear_all_focus()
	red_wyrm.modulate = Color(1,1,1,1) 
	current_page = current_page + 1
	$"../../InteractiveBook2D".go_to_page(current_page)
	visible = false
	static_preview_container.hide()
	match current_demon:
		DEMON.OCCULUM:
			set_text(occulumSpinalOcculum)
			_show_synergy_preview("Occulum", "SpinalOcculum")
		DEMON.CRAWLER:
			set_text(crawlerSpinalOcculum)
			_show_synergy_preview("Crawler", "SpinalOcculum")
		DEMON.SPINALOCCULUM:
			set_text(spinalOcculumCrawler)
			_show_synergy_preview("SpinalOcculum", "Crawler")
		DEMON.WYRM:
			set_text(wyrmCrawler)
			_show_synergy_preview("Wyrm", "Crawler")
		DEMON.HIVE:
			set_text(hiveSpinalOcculum)
			_show_synergy_preview("Hive", "SpinalOcculum")
		DEMON.MAW:
			set_text(mawSpinalOcculum)
			_show_synergy_preview("Maw", "SpinalOcculum")


func _on_alt_6_pressed() -> void:
	clear_all_focus()
	red_hive.modulate = Color(1,1,1,1)
	current_page = current_page + 1
	$"../../InteractiveBook2D".go_to_page(current_page)
	visible = false
	static_preview_container.hide()
	match current_demon:
		DEMON.OCCULUM:
			set_text(occulumWyrm)
			_show_synergy_preview("Occulum", "Wyrm")
		DEMON.CRAWLER:
			set_text(crawlerWyrm)
			_show_synergy_preview("Crawler", "Wyrm")
		DEMON.SPINALOCCULUM:
			set_text(spinalOcculumWyrm)
			_show_synergy_preview("SpinalOcculum", "Wyrm")
		DEMON.WYRM:
			set_text(wyrmSpinalOcculum)
			_show_synergy_preview("Wyrm", "SpinalOcculum")
		DEMON.HIVE:
			set_text(hiveWyrm)
			_show_synergy_preview("Hive", "Wyrm")
		DEMON.MAW:
			set_text(mawWyrm)
			_show_synergy_preview("Maw", "Wyrm")

#Tween On Hover
func _on_alt_1_mouse_entered() -> void:
	_on_mouse_entered(alt1)
	#red_occulum.modulate = Color(1,1,1,1)

func _on_alt_1_mouse_exited() -> void:
	pass
	_on_mouse_exited(alt1)
	#red_occulum.modulate = Color(1,1,1,0)


func _on_alt_2_mouse_entered() -> void:
	_on_mouse_entered(alt2)
	#red_crawler.modulate = Color(1,1,1,1)


func _on_alt_2_mouse_exited() -> void:
	pass
	_on_mouse_exited(alt2)
	#red_crawler.modulate = Color(1,1,1,0)


func _on_alt_3_mouse_entered() -> void:
	_on_mouse_entered(alt3)
	#red_spinal_occulum.modulate = Color(1,1,1,1)
	pass


func _on_alt_3_mouse_exited() -> void:
	pass
	_on_mouse_exited(alt3)
	#red_spinal_occulum.modulate = Color(1,1,1,0)


func _on_alt_4_mouse_entered() -> void:
	_on_mouse_entered(alt4)
	#red_maw.modulate = Color(1,1,1,1)


func _on_alt_4_mouse_exited() -> void:
	pass
	_on_mouse_exited(alt4)
	#red_maw.modulate = Color(1,1,1,0)


func _on_alt_5_mouse_entered() -> void:
	_on_mouse_entered(alt5)
	#red_wyrm.modulate = Color(1,1,1,1)


func _on_alt_5_mouse_exited() -> void:
	pass
	_on_mouse_exited(alt5)
	#red_wyrm.modulate = Color(1,1,1,0)


func _on_alt_6_mouse_entered() -> void:
	_on_mouse_entered(alt6)
	#print("Alt 6 Area Entered")
	#red_hive.modulate = Color(1,1,1,1)


func _on_alt_6_mouse_exited() -> void:
	pass
	_on_mouse_exited(alt6)
	#red_hive.modulate = Color(1,1,1,0)


func _on_occulum_mouse_entered() -> void:
	_on_mouse_entered(occulumButton)
	#red_occulum.modulate = Color(1,1,1,1)


func _on_occulum_mouse_exited() -> void:
	pass
	_on_mouse_exited(occulumButton)
	#red_occulum.modulate = Color(1,1,1,0)


func _on_crawler_mouse_entered() -> void:
	_on_mouse_entered(crawlerButton)
	#red_crawler.modulate = Color(1,1,1,1)


func _on_crawler_mouse_exited() -> void:
	pass
	_on_mouse_exited(crawlerButton)
	#red_crawler.modulate = Color(1,1,1,0)


func _on_walnut_mouse_entered() -> void:
	_on_mouse_entered(spinalOcculumButton)
	#red_spinal_occulum.modulate = Color(1,1,1,1)


func _on_walnut_mouse_exited() -> void:
	pass
	_on_mouse_exited(spinalOcculumButton)
	#red_spinal_occulum.modulate = Color(1,1,1,0)


func _on_maw_mouse_entered() -> void:
	_on_mouse_entered(mawButton)
	#red_maw.modulate = Color(1,1,1,1)
	

func _on_maw_mouse_exited() -> void:
	pass
	_on_mouse_exited(mawButton)
	#red_maw.modulate = Color(1,1,1,0)


func _on_wyrm_mouse_entered() -> void:
	_on_mouse_entered(wyrmButton)
	#red_wyrm.modulate = Color(1,1,1,1)


func _on_wyrm_mouse_exited() -> void:
	pass
	_on_mouse_exited(wyrmButton)
	#red_wyrm.modulate = Color(1,1,1,0)


func _on_hive_mouse_entered() -> void:
	_on_mouse_entered(hiveButton)
	#red_hive.modulate = Color(1,1,1,1)


func _on_hive_mouse_exited() -> void:
	pass
	_on_mouse_exited(hiveButton)
	#red_hive.modulate = Color(1,1,1,0)

func clear_all_focus()->void:
	red_occulum.modulate = Color(1,1,1,0)
	red_crawler.modulate = Color(1,1,1,0)
	red_spinal_occulum.modulate = Color(1,1,1,0)
	red_maw.modulate = Color(1,1,1,0)
	red_wyrm.modulate = Color(1,1,1,0)
	red_hive.modulate = Color(1,1,1,0)

func _on_mouse_entered(button_to_tween) -> void: 
	hover_target = 1.0
	if tween_hover and tween_hover.is_running():
		tween_hover.kill()
		
	tween_hover = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)
	tween_hover.tween_property(button_to_tween,"scale",Vector2(1.05,1.05),0.5)
	
func _on_mouse_exited(button_to_tween) -> void:  
	hover_target = 0.0
	if tween_hover and tween_hover.is_running():
		tween_hover.kill()	
	tween_hover = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)
	tween_hover.tween_property(button_to_tween,"scale",Vector2.ONE,0.55)	
	
		
	


#region Codex navigation from a synergy unlock (data-driven via SynergyCatalog)
# Called by Global.register_demon_codex after this scene loads.
func navigate_to_synergy(synergy : String) -> void:
	var def : SynergyDefinition = Global.synergy_catalog.get_by_id(StringName(synergy))
	if def == null:
		push_warning("Codex: unknown synergy id '" + synergy + "'")
		return
	match def.codex_page:
		&"Crawler":
			_on_crawler_pressed()
		&"Occulum":
			_on_occulum_pressed()
		&"Hive":
			_on_hive_pressed()
		&"SpinalOcculum":
			_on_spinalOcculum_pressed()
		&"Maw":
			_on_maw_pressed()
		&"Wyrm":
			_on_wrym_pressed()
	await get_tree().physics_frame
	await get_tree().physics_frame
	_press_codex_alt_tab(def.codex_alt_index)

func _press_codex_alt_tab(index : int) -> void:
	match index:
		2: _on_alt_2_pressed()
		3: _on_alt_3_pressed()
		4: _on_alt_4_pressed()
		5: _on_alt_5_pressed()
		6: _on_alt_6_pressed()
#endregion
