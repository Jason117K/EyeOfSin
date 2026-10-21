extends AnimatedTextureRect

#Button References
# Codex entries by discovery name (Global.unlock_zombie), in codex order:
# [clickable card frame, art drawn over it (ignores the mouse), its pressed handler].
const ZOMBIE_FRAME_ROWS := "../../AllZombieButtonsContainer/MarginContainer/AllZombieRows/"
const ZOMBIE_ART_ROWS := "../../AllZombieSpritesContainer/MarginContainer/AllZombieRows/"
const ZOMBIE_ENTRIES := {
	"Reborn": ["Row1/RebornButton", "Row1/BaseZombie", &"_on_base_zombie_pressed"],
	"Severed": ["Row1/SeveredButton", "Row1/ConeHeadZombie", &"_on_cone_head_zombie_pressed"],
	"Unhallower": ["Row1/UnhallowerButton", "Row1/BucketHeadZombie", &"_on_bucket_head_zombie_pressed"],
	"Erupter": ["Row2/ErupterButton", "Row2/TickerZombie", &"_on_ticker_zombie_pressed"],
	"Reanimator": ["Row2/ReanimatorButton", "Row2/DancerZombie", &"_on_dancer_zombie_pressed"],
	"Wretch": ["Row2/WretchButton", "Row2/BackUpDancerZombie", &"_on_back_up_dancer_zombie_pressed"],
	"Amalgam": ["Row3/AmalgamButton", "Row3/ScreenDoorZombie", &"_on_screen_door_zombie_pressed"],
	"Sundered": ["Row3/LeaperButton", "Row3/PoleVaultZombie", &"_on_pole_vault_zombie_pressed"],
	"Flesheater": ["Row3/FleshEaterButton", "Row3/FootballZombie", &"_on_football_zombie_pressed"],
}

@onready var currentZombieLabel := $"../../CurrentZombieLabel"
@onready var currentZombieTitle := $"../../CurrentZombieTitle"

@onready var tempFleshEaterAnimSprite := $"../../TEMPFlesheater"

@onready var current_zombie_animation := $"../../CurrentZombieAnim"

var baseZombieDescription := "res://_Assets/Text/TextFiles/ZombieDescriptions/BaseZombieDescription.txt"
var coneheadZombieDescription := "res://_Assets/Text/TextFiles/ZombieDescriptions/ConeHeadZombieDescription.txt"
var bucketHeadZombieDescription := "res://_Assets/Text/TextFiles/ZombieDescriptions/bucketHeadZombieDescription.txt"
var dancerZombieDescription := "res://_Assets/Text/TextFiles/ZombieDescriptions/dancerZombieDescription.txt"
var backUpDancerZombieDescription := "res://_Assets/Text/TextFiles/ZombieDescriptions/backUpDancerDescription.txt"
var tickerZombieDescription := "res://_Assets/Text/TextFiles/ZombieDescriptions/tickerZombieDescription.txt"
var screennDoorZombieDescription := "res://_Assets/Text/TextFiles/ZombieDescriptions/ScreenDoorZombieDescription.txt"
var footBallZombieDescription := "res://_Assets/Text/TextFiles/ZombieDescriptions/footBallZombieDescription.txt"
var poleVaultZombieDescription := "res://_Assets/Text/TextFiles/ZombieDescriptions/poleVaultZombieDescription.txt"

var baseZombieTitle := "NAME_REBORN"
var coneHeadZombieTitle := "NAME_SEVERED"
var bucketHeadZombieTitle := "NAME_UNHALLOWER"
var dancerZombieTitle := "NAME_REANIMATOR"
var backUpDancerZombieTitle := "NAME_WRETCH"
var tickerZombieTitle := "NAME_ERUPTER"
var screenDoorZombieTitle := "NAME_AMALGAMS"
var footballZombieTitle := "NAME_FLESHEATER"
var poleVaultZombieTitle := "NAME_SUNDERED"

var current_zobmie_texture : Texture2D

@onready var zombieBookVisual := $"../../InteractiveBook2D"
var current_page := 2

func _ready() -> void:
	##print("Zombie AnimatedTextureRect: _ready() called")
	zombieBookVisual.go_to_page(current_page)
	current_page = current_page + 1
	
		# Set default button textures based on current colors
	_update_button_textures()
	
	# Set initial sprites if none are set
	#if sprites == null:
	var zombie_type := GlobalResourceLoader.ZombieType.CONEHEAD
	sprites = GlobalResourceLoader.get_zombie_animation(zombie_type)
	
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
	_refresh_zombie_locks()
	_open_first_discovered()


# Undiscovered zombies (Discovery): art silhouetted, card frame darkened and unclickable.
# The codex scene is rebuilt on each open, so this always reads live state.
func _refresh_zombie_locks() -> void:
	for zombie_name: String in ZOMBIE_ENTRIES:
		var entry: Array = ZOMBIE_ENTRIES[zombie_name]
		var locked := not Discovery.is_zombie_discovered(zombie_name)
		var frame := get_node_or_null(ZOMBIE_FRAME_ROWS + entry[0]) as BaseButton
		if frame != null:
			UiFx.set_locked(frame, frame, locked)
		UiFx.set_silhouette(get_node_or_null(ZOMBIE_ART_ROWS + entry[1]) as BaseButton, locked)


# Opens the first discovered zombie's page; with none discovered, the page stays blank.
func _open_first_discovered() -> void:
	for zombie_name: String in ZOMBIE_ENTRIES:
		if Discovery.is_zombie_discovered(zombie_name):
			call(ZOMBIE_ENTRIES[zombie_name][2])
			return
	current_zombie_animation.hide()
	currentZombieLabel.text = ""
	currentZombieTitle.text = ""


# The codex art textures come from the scene; only the hue shift is applied here.
func _update_button_textures() -> void:
	_apply_hue_shift()

#Sets the current Zombie Description Text
func set_text(newFile: String) -> void:
	currentZombieLabel.text = Loc.text(newFile)

func set_title(newTitle: String) -> void:
	currentZombieTitle.text = tr(newTitle)

func _on_base_zombie_pressed() -> void:
	current_zombie_animation.show()
	#current_zombie_animation.hide()
	tempFleshEaterAnimSprite.visible = false
	get_parent().visible = false
	#get_parent().position = Vector2(431,-25)
	get_parent().show()
	current_page = current_page + 1
	zombieBookVisual.go_to_page(current_page)
	
	sprites = GlobalResourceLoader.get_zombie_animation(
		GlobalResourceLoader.ZombieType.BASEZOMBIE)
	current_zombie_animation.flip_h = true 
	play()


	current_zombie_animation.sprite_frames = GlobalResourceLoader.get_zombie_animation(
		GlobalResourceLoader.ZombieType.BASEZOMBIE)
	current_zombie_animation.play()
	
	
	set_text(baseZombieDescription)
	set_title(baseZombieTitle)
	self.flip_h = true


func _on_cone_head_zombie_pressed() -> void:
	current_zombie_animation.show()
	
	tempFleshEaterAnimSprite.visible = false
	#get_parent().position = Vector2(431,-25)
	#
	current_page = current_page + 1
	zombieBookVisual.go_to_page(current_page)
	sprites = GlobalResourceLoader.get_zombie_animation(
		GlobalResourceLoader.ZombieType.CONEHEAD)
	#print("Sprites was ",sprites )
	sprites = load("res://_Entities/Zombies/_Severed/Severed.tres")
	play("Attack")
	
	current_zombie_animation.sprite_frames = GlobalResourceLoader.get_zombie_animation(
		GlobalResourceLoader.ZombieType.CONEHEAD)
	current_zombie_animation.play()
	current_zombie_animation.flip_h = true 
	
	set_text(coneheadZombieDescription)
	set_title(coneHeadZombieTitle)
	self.flip_h = true

func _on_bucket_head_zombie_pressed() -> void:
	current_zombie_animation.show()
	tempFleshEaterAnimSprite.visible = false
	#get_parent().position = Vector2(431,-25)
	current_page = current_page + 1
	zombieBookVisual.go_to_page(current_page)
	sprites = GlobalResourceLoader.get_zombie_animation(
		GlobalResourceLoader.ZombieType.BUCKETHEAD)
	play()
	
	current_zombie_animation.sprite_frames = GlobalResourceLoader.get_zombie_animation(
		GlobalResourceLoader.ZombieType.BUCKETHEAD)
	current_zombie_animation.play()
	current_zombie_animation.flip_h = true 
	
	set_text(bucketHeadZombieDescription)
	set_title(bucketHeadZombieTitle)
	_apply_hue_shift()
	self.flip_h = true

#was 431.0
func _on_dancer_zombie_pressed() -> void:
	current_zombie_animation.show()
	tempFleshEaterAnimSprite.visible = false
	#get_parent().position = Vector2(475,-25)
	current_page = current_page + 1
	zombieBookVisual.go_to_page(current_page)
	sprites = GlobalResourceLoader.get_zombie_animation(
		GlobalResourceLoader.ZombieType.DANCERZOMBIE)
	play()

	current_zombie_animation.sprite_frames = GlobalResourceLoader.get_zombie_animation(
		GlobalResourceLoader.ZombieType.DANCERZOMBIE)
	current_zombie_animation.play()
	current_zombie_animation.flip_h = true 
	
	
	set_text(dancerZombieDescription)
	set_title(dancerZombieTitle)
	self.flip_h = true

func _on_back_up_dancer_zombie_pressed() -> void:
	current_zombie_animation.show()
	tempFleshEaterAnimSprite.visible = false
	#get_parent().position = Vector2(431,-25)
	current_page = current_page + 1
	zombieBookVisual.go_to_page(current_page)
	sprites = GlobalResourceLoader.get_zombie_animation(
		GlobalResourceLoader.ZombieType.BACKUPDANCERZOMBIE)
	play()

	current_zombie_animation.sprite_frames = GlobalResourceLoader.get_zombie_animation(
		GlobalResourceLoader.ZombieType.BACKUPDANCERZOMBIE)
	current_zombie_animation.play()
	
	current_zombie_animation.flip_h = true 
	
	set_text(backUpDancerZombieDescription)
	set_title(backUpDancerZombieTitle)
	self.flip_h = true


func _on_ticker_zombie_pressed() -> void:
	current_zombie_animation.show()
	tempFleshEaterAnimSprite.visible = false
	#get_parent().position = Vector2(450,1)

	current_page = current_page + 1
	zombieBookVisual.go_to_page(current_page)
	sprites = GlobalResourceLoader.get_zombie_animation(
		GlobalResourceLoader.ZombieType.TICKER)
	play()
	
	current_zombie_animation.sprite_frames = GlobalResourceLoader.get_zombie_animation(
		GlobalResourceLoader.ZombieType.TICKER)
	current_zombie_animation.play()
	current_zombie_animation.flip_h = true 
	
	
	set_text(tickerZombieDescription)
	set_title(tickerZombieTitle)
	self.flip_h = true


func _on_screen_door_zombie_pressed() -> void:
	current_zombie_animation.show()
	tempFleshEaterAnimSprite.visible = false
	#get_parent().position = Vector2(431,-25)
	
	current_page = current_page + 1
	zombieBookVisual.go_to_page(current_page)
	sprites = GlobalResourceLoader.get_zombie_animation(
		GlobalResourceLoader.ZombieType.SCREENDOORZOMBIE)
	current_zombie_animation.sprite_frames = GlobalResourceLoader.get_zombie_animation(
		GlobalResourceLoader.ZombieType.SCREENDOORZOMBIE)
	current_zombie_animation.play()
	current_zombie_animation.flip_h = false
	#current_zobmie_texture = GlobalResourceLoader.
	play()
	set_text(screennDoorZombieDescription)
	set_title(screenDoorZombieTitle)
	self.flip_h = false


func _on_football_zombie_pressed() -> void:
	current_zombie_animation.show()
	#get_parent().position = Vector2(431,-25)
	#tempFleshEaterAnimSprite.visible = true
	current_page = current_page + 1
	zombieBookVisual.go_to_page(current_page)
	#sprites = GlobalResourceLoader.get_zombie_animation(
		#GlobalResourceLoader.ZombieType.FOOTBALLZOMBIE)
	sprites = GlobalResourceLoader.get_empty()
	play()
	
	current_zombie_animation.sprite_frames = GlobalResourceLoader.get_zombie_animation(
		GlobalResourceLoader.ZombieType.FOOTBALLZOMBIE)
	current_zombie_animation.play()
	current_zombie_animation.flip_h = false 
	
	
	set_text(footBallZombieDescription)
	set_title(footballZombieTitle)
	self.flip_h = false


func _on_pole_vault_zombie_pressed() -> void:
	current_zombie_animation.show()
	current_zombie_animation.show()
	tempFleshEaterAnimSprite.visible = false
	#get_parent().position = Vector2(431,-25)
	#
	current_page = current_page + 1
	zombieBookVisual.go_to_page(current_page)
	#sprites = GlobalResourceLoader.get_zombie_animation(
		#GlobalResourceLoader.ZombieType.POLEVAULTZOMBIE)
	sprites = GlobalResourceLoader.get_empty()
	play()
	
	current_zombie_animation.sprite_frames = GlobalResourceLoader.get_zombie_animation(
		GlobalResourceLoader.ZombieType.POLEVAULTZOMBIE)
	current_zombie_animation.play()
	current_zombie_animation.flip_h = true 
	
	
	set_text(poleVaultZombieDescription)
	set_title(poleVaultZombieTitle)
	self.flip_h = true


func _on_back_button_pressed() -> void:
	tempFleshEaterAnimSprite.visible = false
	current_page = current_page - 1
	zombieBookVisual.go_to_page(current_page)
	get_parent().get_parent().visible = false
	#print("BBack Button Pressed")
	Global.game_controller.restore_previous_scene()
