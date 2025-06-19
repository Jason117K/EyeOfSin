extends Node

# Plant Types
enum PlantType {BOMBPLANT, SUNFLOWER,PEASHOOTER,HIVE,MAW,WALNUT,EGGWYRM}

# Zombie Types
enum ZombieType {BASEZOMBIE, CONEHEAD,BUCKETHEAD,DANCERZOMBIE,BACKUPDANCERZOMBIE,
FOOTBALLZOMBIE,POLEVAULTZOMBIE,SCREENDOORZOMBIE,TICKER}

# Resource Caches
var plant_images = {}
var plant_animations = {}

var zombie_images = {}
var zombie_animations = {}

# Called when the node enters the scene tree for the first time
func _ready():
	print("GlobalResourceManager: Initializing...")
	_initialize_resource_caches()
	_load_resources()
	print("GlobalResourceManager: Resources loaded and ready")
	
	
# Initialize the resource cache dictionaries
func _initialize_resource_caches():
	for this_plantType in PlantType.values():
		print("PP : ", this_plantType)
		plant_images[this_plantType] = {}
		plant_animations[this_plantType] = {}
		
	for this_zombieType in ZombieType.values():
		print("ZZ : ", this_zombieType)
		zombie_images[this_zombieType] = {}
		zombie_animations[this_zombieType] = {}		

# Load all Resources
func _load_resources():
							  		#PlantType         , FileName
	_load_plant_type_image_resource(PlantType.SUNFLOWER, "Sunflower.png")
	_load_plant_type_image_resource(PlantType.PEASHOOTER, "Spyder.png")
	_load_plant_type_image_resource(PlantType.WALNUT, "Walnut.png")
	_load_plant_type_image_resource(PlantType.EGGWYRM, "EggWyrm.png")
	_load_plant_type_image_resource(PlantType.HIVE, "Hive.png")
	_load_plant_type_image_resource(PlantType.MAW, "MawImage.png")
	_load_plant_type_image_resource(PlantType.BOMBPLANT, "EyeBomb.png")
	
	_load_zombie_type_image_resource(ZombieType.BASEZOMBIE,"BasicZombie.png")
	_load_zombie_type_image_resource(ZombieType.CONEHEAD,"ConeHeadZombie.png")
	_load_zombie_type_image_resource(ZombieType.BUCKETHEAD,"BucketHeadZombie.png")
	_load_zombie_type_image_resource(ZombieType.DANCERZOMBIE,"SummonerZombie.png")
	_load_zombie_type_image_resource(ZombieType.BACKUPDANCERZOMBIE,"BackUpDancer.png")
	_load_zombie_type_image_resource(ZombieType.FOOTBALLZOMBIE,"FootBallZombie.png")
	_load_zombie_type_image_resource(ZombieType.POLEVAULTZOMBIE,"PoleVaultZombie.png")
	_load_zombie_type_image_resource(ZombieType.SCREENDOORZOMBIE,"ScreenDoorZombie.png")
	_load_zombie_type_image_resource(ZombieType.TICKER,"TickerZombie.png")
	
	_load_plant_type_animation_resource(PlantType.SUNFLOWER, "Sunflower.tres")
	_load_plant_type_animation_resource(PlantType.PEASHOOTER, "Spyder.tres")
	_load_plant_type_animation_resource(PlantType.WALNUT, "Walnut.tres")
	_load_plant_type_animation_resource(PlantType.EGGWYRM, "EggWorm.tres")
	_load_plant_type_animation_resource(PlantType.HIVE, "Hive.tres")
	_load_plant_type_animation_resource(PlantType.MAW, "Maw.tres")
	_load_plant_type_animation_resource(PlantType.BOMBPLANT, "EyeBomb.tres")
	
	_load_zombie_type_animation_resource(ZombieType.BASEZOMBIE,"BaseZombie.tres")
	_load_zombie_type_animation_resource(ZombieType.CONEHEAD,"Severed.tres")
	_load_zombie_type_animation_resource(ZombieType.BUCKETHEAD,"BucketHead.tres")
	_load_zombie_type_animation_resource(ZombieType.DANCERZOMBIE,"DancerAnim.tres")
	_load_zombie_type_animation_resource(ZombieType.BACKUPDANCERZOMBIE,"BackUpDancer.tres")
	_load_zombie_type_animation_resource(ZombieType.FOOTBALLZOMBIE,"FootBall.tres")
	_load_zombie_type_animation_resource(ZombieType.POLEVAULTZOMBIE,"Leaper.tres")
	_load_zombie_type_animation_resource(ZombieType.SCREENDOORZOMBIE,"ScreenDoorZombie.tres")
	_load_zombie_type_animation_resource(ZombieType.TICKER,"TickerFrames.tres")
	
	
# Helper function to load resources for a specific tower type
func _load_plant_type_image_resource(plant_type,file_name):
	var img_base_path = "res://Assets/Sprites/" 
	var img_path:String = img_base_path + file_name 
	
	# Force immediate loading with ResourceLoader
	print("ResourceLoader: Loading image from " + img_path)
	var img_resource = ResourceLoader.load(img_path, "", ResourceLoader.CACHE_MODE_REPLACE)
	plant_images[plant_type] = img_resource
	


# Helper function to load resources for a specific tower type
func _load_plant_type_animation_resource(plant_type,file_name):
	var anim_base_path = "res://Assets/Animations/"
	var anim_path:String = anim_base_path + file_name 
	
	# Force immediate loading with ResourceLoader
	print("ResourceLoader: Loading animation from " + anim_path)
	var anim_resource = ResourceLoader.load(anim_path, "", ResourceLoader.CACHE_MODE_REPLACE)
	print("Added : ", anim_resource)
	plant_animations[plant_type]= anim_resource


# Get a alien image by type, 
func get_plant_image(plant_type):
	if not plant_images.has(plant_type):
		print("ResourceManager: Error - Resource not found for image:",plant_type)
		return null
	return plant_images[plant_type]
	
# Get a alien animation by type,
func get_plant_animation(plant_type):
	if not plant_animations.has(plant_type):
		print("ResourceManager: Error - Resource not found for animation:", plant_type)
		return null
	print("This ", plant_animations[plant_type])
	return plant_animations[plant_type]
	


# Helper function to load resources for a specific zombie type
func _load_zombie_type_image_resource(zombie_type,file_name):
	var img_base_path = "res://Assets/Sprites/" 
	var img_path:String = img_base_path + file_name 
	
	# Force immediate loading with ResourceLoader
	print("ResourceLoader: Loading image from " + img_path)
	var img_resource = ResourceLoader.load(img_path, "", ResourceLoader.CACHE_MODE_REPLACE)
	zombie_images[zombie_type] = img_resource
	


# Helper function to load resources for a specific tower type
func _load_zombie_type_animation_resource(zombie_type,file_name):
	var anim_base_path = "res://Assets/Zombies/Animations/Spriteframes/"
	var anim_path:String = anim_base_path + file_name 
	
	# Force immediate loading with ResourceLoader
	print("ResourceLoader: Loading animation from " + anim_path)
	var anim_resource = ResourceLoader.load(anim_path, "", ResourceLoader.CACHE_MODE_REPLACE)
	print("Added : ", anim_resource)
	zombie_animations[zombie_type]= anim_resource


# Get a alien image by type, 
func get_zombie_image(zombie_type):
	if not zombie_images.has(zombie_type):
		print("ResourceManager: Error - Resource not found for image:",zombie_type)
		return null
	return zombie_images[zombie_type]
	
# Get a alien animation by type,
func get_zombie_animation(zombie_type):
	if not zombie_animations.has(zombie_type):
		print("ResourceManager: Error - Resource not found for animation:", zombie_type)
		return null
	print("This ", zombie_animations[zombie_type])
	return zombie_animations[zombie_type]
	
	
	
	
	
		
	
	
