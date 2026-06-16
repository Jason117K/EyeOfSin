extends Node

# Demon Types
enum DemonType {OCCULUM,CRAWLER,HIVE,MAW,SPINALOCCULUM,WYRM}

# Zombie Types
enum ZombieType {BASEZOMBIE, CONEHEAD,BUCKETHEAD,DANCERZOMBIE,BACKUPDANCERZOMBIE,
FOOTBALLZOMBIE,POLEVAULTZOMBIE,SCREENDOORZOMBIE,TICKER}

# Resource Caches
var demon_images: Dictionary = {}
var demon_variation_images: Dictionary = {}

var demon_animations: Dictionary = {}

var zombie_images: Dictionary = {}
var zombie_animations: Dictionary = {}

@onready var empty_animation := ResourceLoader.load("res://_Entities/Zombies/ImgAnimationResources/empty.tres", "", ResourceLoader.CACHE_MODE_REPLACE)

# Called when the node enters the scene tree for the first time
func _ready() -> void:
	print("GlobalResourceManager: Initializing...")
	_initialize_resource_caches()
	_load_resources()
	print("GlobalResourceManager: Resources loaded and ready")


# Initialize the resource cache dictionaries
func _initialize_resource_caches() -> void:
	for this_demonType : int in DemonType.values():
		print("PP : ", this_demonType)
		demon_images[this_demonType] = {}
		demon_animations[this_demonType] = {}
		demon_variation_images[this_demonType] = []
		#for this_demonType2 in DemonType.values():
			#demon_variation_images[this_demonType2] = {}
		
	for this_zombieType : int in ZombieType.values():
		print("ZZ : ", this_zombieType)
		zombie_images[this_zombieType] = {}
		zombie_animations[this_zombieType] = {}		

# Load all Resources
func _load_resources() -> void:
							  		#DemonType         , FileName
	_load_demon_type_image_resource(DemonType.OCCULUM, "Occulum.png")
	_load_demon_type_image_resource(DemonType.CRAWLER, "Crawler.png")
	_load_demon_type_image_resource(DemonType.SPINALOCCULUM, "SpinalOcculum.png")
	_load_demon_type_image_resource(DemonType.WYRM, "Wyrm.png")
	_load_demon_type_image_resource(DemonType.HIVE, "Hive.png")
	_load_demon_type_image_resource(DemonType.MAW, "MawImage.png")
	
	_load_demon_type_image_resource_variation(DemonType.OCCULUM, "OcculumTowerIdle_MAW.png")
	_load_demon_type_image_resource_variation(DemonType.OCCULUM, "OcculumTowerIdle_HIVE.png")
	_load_demon_type_image_resource_variation(DemonType.OCCULUM, "OcculumTowerIdle_CRAWLER.png")
	_load_demon_type_image_resource_variation(DemonType.OCCULUM, "OcculumTowerIdle_SPINALOCCULUM.png")
	_load_demon_type_image_resource_variation(DemonType.OCCULUM, "OcculumTowerIdle_WYRM.png")
	
	_load_demon_type_image_resource_variation(DemonType.CRAWLER, "CrawlerIdle_Hive.png")
	_load_demon_type_image_resource_variation(DemonType.CRAWLER, "CrawlerIdle_MAW.png")
	_load_demon_type_image_resource_variation(DemonType.CRAWLER, "CrawlerIdle_OCCULUM.png")
	_load_demon_type_image_resource_variation(DemonType.CRAWLER, "CrawlerIdle_SpinalOcculum.png")
	_load_demon_type_image_resource_variation(DemonType.CRAWLER, "CrawlerIdle_Wyrm.png")
	
	_load_demon_type_image_resource_variation(DemonType.SPINALOCCULUM, "OccularSpineIdle_OCCULUM.png")
	_load_demon_type_image_resource_variation(DemonType.SPINALOCCULUM, "OccularSpineIdle_HIVE.png")
	_load_demon_type_image_resource_variation(DemonType.SPINALOCCULUM, "OccularSpineIdle_MAW.png")
	_load_demon_type_image_resource_variation(DemonType.SPINALOCCULUM, "OccularSpineIdle_CRAWLER.png")
	_load_demon_type_image_resource_variation(DemonType.SPINALOCCULUM, "OccularSpineIdle_WYRM.png")
	
	
	_load_demon_type_image_resource_variation(DemonType.WYRM, "Wyrm_Occulum.png")
	_load_demon_type_image_resource_variation(DemonType.WYRM, "Wyrm_Hive.png")
	_load_demon_type_image_resource_variation(DemonType.WYRM, "Wyrm_Maw.png")
	_load_demon_type_image_resource_variation(DemonType.WYRM, "Wyrm_Crawler.png")
	_load_demon_type_image_resource_variation(DemonType.WYRM, "Wyrm_SpinalOcculum.png")
	
		
	_load_demon_type_image_resource_variation(DemonType.HIVE,"Hive_Maw.png" )
	_load_demon_type_image_resource_variation(DemonType.HIVE, "Hive_Crawler.png")
	_load_demon_type_image_resource_variation(DemonType.HIVE, "Hive_Occulum.png")
	_load_demon_type_image_resource_variation(DemonType.HIVE, "Hive_SpinalOcculum.png")
	_load_demon_type_image_resource_variation(DemonType.HIVE, "Hive_Wyrm.png")
	
	_load_demon_type_image_resource_variation(DemonType.MAW, "Maw_Hive.png")
	_load_demon_type_image_resource_variation(DemonType.MAW, "Maw_Crawler.png")
	_load_demon_type_image_resource_variation(DemonType.MAW, "Maw_Occulum.png")
	_load_demon_type_image_resource_variation(DemonType.MAW, "Maw_SpinalOcculum.png")
	_load_demon_type_image_resource_variation(DemonType.MAW, "Maw_Wyrm.png")
		
	
	_load_zombie_type_image_resource(ZombieType.BASEZOMBIE,"BasicZombie.png")
	_load_zombie_type_image_resource(ZombieType.CONEHEAD,"ConeHeadZombie.png")
	_load_zombie_type_image_resource(ZombieType.BUCKETHEAD,"BucketHeadZombie.png")
	_load_zombie_type_image_resource(ZombieType.DANCERZOMBIE,"SummonerZombie.png")
	_load_zombie_type_image_resource(ZombieType.BACKUPDANCERZOMBIE,"BackUpDancer.png")
	_load_zombie_type_image_resource(ZombieType.FOOTBALLZOMBIE,"FootBallZombie.png")
	_load_zombie_type_image_resource(ZombieType.POLEVAULTZOMBIE,"PoleVaultZombie.png")
	_load_zombie_type_image_resource(ZombieType.SCREENDOORZOMBIE,"ScreenDoorZombie.png")
	_load_zombie_type_image_resource(ZombieType.TICKER,"TickerZombie.png")
	
	
	
	_load_demon_type_animation_resource(DemonType.OCCULUM, "Occulum.tres")
	_load_demon_type_animation_resource(DemonType.CRAWLER, "Crawler.tres")
	_load_demon_type_animation_resource(DemonType.SPINALOCCULUM, "SpinalOcculum.tres")
	_load_demon_type_animation_resource(DemonType.WYRM, "Wyrm.tres")
	_load_demon_type_animation_resource(DemonType.HIVE, "Hive.tres")
	_load_demon_type_animation_resource(DemonType.MAW, "Maw.tres")
	
	_load_zombie_type_animation_resource(ZombieType.BASEZOMBIE,"BaseZombie.tres")
	_load_zombie_type_animation_resource(ZombieType.CONEHEAD,"Severed.tres")
	_load_zombie_type_animation_resource(ZombieType.BUCKETHEAD,"BucketHead.tres")
	_load_zombie_type_animation_resource(ZombieType.DANCERZOMBIE,"DancerAnim.tres")
	_load_zombie_type_animation_resource(ZombieType.BACKUPDANCERZOMBIE,"BackUpDancer.tres")
	_load_zombie_type_animation_resource(ZombieType.FOOTBALLZOMBIE,"FootBall.tres")
	_load_zombie_type_animation_resource(ZombieType.POLEVAULTZOMBIE,"Leaper.tres")
	_load_zombie_type_animation_resource(ZombieType.SCREENDOORZOMBIE,"ScreenDoorZombie.tres")
	_load_zombie_type_animation_resource(ZombieType.TICKER,"TickerFrames.tres")
	
	#print("Demon Variation Images 1 is ", demon_variation_images[1])
	
	
# Helper function to load resources for a specific tower type
func _load_demon_type_image_resource(demon_type : int, file_name : String) -> void:
	var img_base_path := "res://_Assets/Sprites/"
	var img_path: String = img_base_path + file_name

	# Force immediate loading with ResourceLoader
	print("ResourceLoader: Loading image from " + img_path)
	var img_resource := ResourceLoader.load(img_path, "", ResourceLoader.CACHE_MODE_REPLACE)
	demon_images[demon_type] = img_resource
	demon_variation_images[demon_type].append(img_resource)
	
func _load_demon_type_image_resource_variation(demon_type : int, file_name : String) -> void:
	#var img_base_path =  "res://Assets/Demons/Icons/"
	var img_base_path := "res://_Entities/Demons/Icons/"
	var img_path: String = img_base_path + file_name

	# Force immediate loading with ResourceLoader
	print("ResourceLoader: Loading image from " + img_path)
	var img_resource := ResourceLoader.load(img_path, "", ResourceLoader.CACHE_MODE_REPLACE)
	demon_variation_images[demon_type].append(img_resource)

# Helper function to load resources for a specific tower type
func _load_demon_type_animation_resource(demon_type : int, file_name : String) -> void:
	var anim_base_path := "res://_Entities/Demons/AnimationResources/"
	var anim_path: String = anim_base_path + file_name

	# Force immediate loading with ResourceLoader
	print("ResourceLoader: Loading animation from " + anim_path)
	var anim_resource := ResourceLoader.load(anim_path, "", ResourceLoader.CACHE_MODE_REPLACE)
	print("Added : ", anim_resource)
	demon_animations[demon_type]= anim_resource


# Get a alien image by type, 
func get_demon_image(demon_type : int)->CompressedTexture2D:
	if not demon_images.has(demon_type):
		print("ResourceManager: Error - Resource not found for image:",demon_type)
		return null
	return demon_images[demon_type]
	
func get_demon_image_variations(demon_type:int) -> Array:
	#print("Demon Varation Images is ", demon_variation_images[demon_type])
	return demon_variation_images[demon_type]
	
# Get a alien animation by type,
func get_demon_animation(demon_type:int)->Resource:
	if not demon_animations.has(demon_type):
		print("ResourceManager: Error - Resource not found for animation:", demon_type)
		return null
	#print("This Demon Type : ", demon_type, " has animation : ", demon_animations[demon_type])
	return demon_animations[demon_type]

func get_demon_synergy_icon(demon_a:String,demon_b:String, demon_type:int)->CompressedTexture2D:
	print("Demon A is ",demon_a)
	print("Demon B is ", demon_b)
	if demon_b == "Spinalocculum":
		demon_b = "OccularSpine"
		
	for demon_image:CompressedTexture2D in get_demon_image_variations(demon_type):
		print("Load Path is ", demon_image.load_path)
		if demon_image.load_path.containsn(demon_a) && demon_image.load_path.containsn(demon_b):
			#print("Found D Image ")
			#print(demon_image)
			return demon_image
			pass
	
	return null
	
	


# Helper function to load resources for a specific zombie type
func _load_zombie_type_image_resource(zombie_type:int, file_name:String) -> void:
	var img_base_path := "res://_Entities/Zombies/ImgAnimationResources/"
	var img_path: String = img_base_path + file_name

	# Force immediate loading with ResourceLoader
	print("ResourceLoader: Loading image from " + img_path)
	var img_resource := ResourceLoader.load(img_path, "", ResourceLoader.CACHE_MODE_REPLACE)
	zombie_images[zombie_type] = img_resource
	


# Helper function to load resources for a specific tower type
func _load_zombie_type_animation_resource(zombie_type:int, file_name:String) -> void:
	var anim_base_path := "res://_Entities/Zombies/ImgAnimationResources/"
	var anim_path: String = anim_base_path + file_name

	# Force immediate loading with ResourceLoader
	print("ResourceLoader: Loading animation from " + anim_path)
	var anim_resource := ResourceLoader.load(anim_path, "", ResourceLoader.CACHE_MODE_REPLACE)
	print("Added : ", anim_resource)
	zombie_animations[zombie_type]= anim_resource



func get_zombie_image(zombie_type:int)-> CompressedTexture2D:
	if not zombie_images.has(zombie_type):
		print("ResourceManager: Error - Resource not found for image:",zombie_type)
		print(zombie_images)
		return null
	return zombie_images[zombie_type]
	
# Get a alien animation by type,
func get_zombie_animation(zombie_type:int)->SpriteFrames:
	if not zombie_animations.has(zombie_type):
		print("ResourceManager: Error - Resource not found for animation:", zombie_type)
		return null
	print("This ", zombie_animations[zombie_type])
	return zombie_animations[zombie_type]
	
	
func get_empty()->Resource:
	return empty_animation
	
	
	
		
	
	
