extends AnimatedTextureRect

#Button References
@onready var baseZombieButton = $"../../AllZombieRows/Row1/BaseZombie"
@onready var coneHeadZombieButton = $"../../AllZombieRows/Row1/ConeHeadZombie"
@onready var bucketHeadZombieButton = $"../../AllZombieRows/Row1/BucketHeadZombie"
@onready var dancerZombieButton = $"../../AllZombieRows/Row2/DancerZombie" 
@onready var backUpDanceerZombieButton = $"../../AllZombieRows/Row2/BackUpDancerZombie"
@onready var tickerZombieButton = $"../../AllZombieRows/Row2/TickerZombie"
@onready var screenDoorZombieButton = $"../../AllZombieRows/Row3/ScreenDoorZombie"
@onready var footBallZombieButton = $"../../AllZombieRows/Row3/FootballZombie"
@onready var poleVaultZombieButton = $"../../AllZombieRows/Row3/PoleVaultZombie"

@onready var currentZombieLabel = $"../../CurrentZombieLabel"
@onready var currentZombieTitle = $"../../CurrentZombieTitle"

var baseZombieDescription := "res://Assets/Text/TextFiles/ZombieDescriptions/BaseZombieDescription.txt"
var coneheadZombieDescription := "res://Assets/Text/TextFiles/ZombieDescriptions/ConeHeadZombieDescription.txt"
var bucketHeadZombieDescription := "res://Assets/Text/TextFiles/ZombieDescriptions/bucketHeadZombieDescription.txt"
var dancerZombieDescription := "res://Assets/Text/TextFiles/ZombieDescriptions/dancerZombieDescription.txt"
var backUpDancerZombieDescription := "res://Assets/Text/TextFiles/ZombieDescriptions/backUpDancerDescription.txt"
var tickerZombieDescription := "res://Assets/Text/TextFiles/ZombieDescriptions/tickerZombieDescription.txt"
var screennDoorZombieDescription := "res://Assets/Text/TextFiles/ZombieDescriptions/ScreenDoorZombieDescription.txt"
var footBallZombieDescription := "res://Assets/Text/TextFiles/ZombieDescriptions/footBallZombieDescription.txt"
var poleVaultZombieDescription := "res://Assets/Text/TextFiles/ZombieDescriptions/poleVaultZombieDescription.txt"

var baseZombieTitle := "Basic Zombie"
var coneHeadZombieTitle := "Severed Zombie"
var bucketHeadZombieTitle := "Warrior Zombie"
var dancerZombieTitle := "Summoner Zombie"
var backUpDancerZombieTitle := "Wretch Zombie"
var tickerZombieTitle := "Ticker Zombie"
var screenDoorZombieTitle := "Phalanx Zombie"
var footballZombieTitle := "Chimera Zombie"
var poleVaultZombieTitle := "Leaper Zombie"

func _ready() -> void:
	print("Zombie AnimatedTextureRect: _ready() called")
	
		# Set default button textures based on current colors
	_update_button_textures()
	
	# Set initial sprites if none are set
	if sprites == null:
		var zombie_type = GlobalResourceLoader.PlantType.SUNFLOWER
		sprites = GlobalResourceLoader.get_plant_animation(zombie_type)
	
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
	
	# Set
	if baseZombieButton != null:
		baseZombieButton.texture_normal = GlobalResourceLoader.get_zombie_image(
			GlobalResourceLoader.ZombieType.BASEZOMBIE)
	if coneHeadZombieButton != null:
		coneHeadZombieButton.texture_normal = GlobalResourceLoader.get_zombie_image(
			GlobalResourceLoader.ZombieType.CONEHEAD)
	if bucketHeadZombieButton != null:
		bucketHeadZombieButton.texture_normal = GlobalResourceLoader.get_zombie_image(
			GlobalResourceLoader.ZombieType.BUCKETHEAD)
	
	# Set 
	if dancerZombieButton != null:
		dancerZombieButton.texture_normal = GlobalResourceLoader.get_zombie_image(
			GlobalResourceLoader.ZombieType.DANCERZOMBIE)
	if backUpDanceerZombieButton != null:
		backUpDanceerZombieButton.texture_normal = GlobalResourceLoader.get_zombie_image(
			GlobalResourceLoader.ZombieType.BACKUPDANCERZOMBIE)
	if tickerZombieButton != null:
		tickerZombieButton.texture_normal = GlobalResourceLoader.get_zombie_image(
			GlobalResourceLoader.ZombieType.TICKER)
			
	if screenDoorZombieButton != null:
		screenDoorZombieButton.texture_normal = GlobalResourceLoader.get_zombie_image(
			GlobalResourceLoader.ZombieType.SCREENDOORZOMBIE)
			
	if footBallZombieButton != null:
		footBallZombieButton.texture_normal = GlobalResourceLoader.get_zombie_image(
			GlobalResourceLoader.ZombieType.FOOTBALLZOMBIE)
			
	if poleVaultZombieButton != null:
		poleVaultZombieButton.texture_normal = GlobalResourceLoader.get_zombie_image(
			GlobalResourceLoader.ZombieType.POLEVAULTZOMBIE)
			
#Sets the current Zombie Description Text
func set_text(newFile : String):
	var file = FileAccess.open(newFile, FileAccess.READ)
	var newText = file.get_as_text()
	file.close()
	currentZombieLabel.text = newText

func set_title(newTitle : String):
	currentZombieTitle.text = newTitle

func _on_base_zombie_pressed() -> void:
	sprites = GlobalResourceLoader.get_zombie_animation(
		GlobalResourceLoader.ZombieType.BASEZOMBIE)
	play()
	set_text(baseZombieDescription)
	set_title(baseZombieTitle)


func _on_cone_head_zombie_pressed() -> void:
	sprites = GlobalResourceLoader.get_zombie_animation(
		GlobalResourceLoader.ZombieType.CONEHEAD)
	play()
	set_text(coneheadZombieDescription)
	set_title(coneHeadZombieTitle)

func _on_bucket_head_zombie_pressed() -> void:
	sprites = GlobalResourceLoader.get_zombie_animation(
		GlobalResourceLoader.ZombieType.BUCKETHEAD)
	play()
	set_text(bucketHeadZombieDescription)
	set_title(bucketHeadZombieTitle)


func _on_dancer_zombie_pressed() -> void:
	sprites = GlobalResourceLoader.get_zombie_animation(
		GlobalResourceLoader.ZombieType.DANCERZOMBIE)
	play()
	set_text(dancerZombieDescription)
	set_title(dancerZombieTitle)


func _on_back_up_dancer_zombie_pressed() -> void:
	sprites = GlobalResourceLoader.get_zombie_animation(
		GlobalResourceLoader.ZombieType.BACKUPDANCERZOMBIE)
	play()
	set_text(backUpDancerZombieDescription)
	set_title(backUpDancerZombieTitle)


func _on_ticker_zombie_pressed() -> void:
	sprites = GlobalResourceLoader.get_zombie_animation(
		GlobalResourceLoader.ZombieType.TICKER)
	play()
	set_text(tickerZombieDescription)
	set_title(tickerZombieTitle)


func _on_screen_door_zombie_pressed() -> void:
	sprites = GlobalResourceLoader.get_zombie_animation(
		GlobalResourceLoader.ZombieType.SCREENDOORZOMBIE)
	play()
	set_text(screennDoorZombieDescription)
	set_title(screenDoorZombieTitle)


func _on_football_zombie_pressed() -> void:
	sprites = GlobalResourceLoader.get_zombie_animation(
		GlobalResourceLoader.ZombieType.FOOTBALLZOMBIE)
	play()
	set_text(footBallZombieDescription)
	set_title(footballZombieTitle)


func _on_pole_vault_zombie_pressed() -> void:
	sprites = GlobalResourceLoader.get_zombie_animation(
		GlobalResourceLoader.ZombieType.POLEVAULTZOMBIE)
	play()
	set_text(poleVaultZombieDescription)
	set_title(poleVaultZombieTitle)


func _on_back_button_pressed() -> void:
	get_parent().get_parent().visible = false 
	print("BBack Button Pressed")
	Global.game_controller.restore_previous_scene()
