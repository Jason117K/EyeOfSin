extends Area2D
#Sunflower.gd


# Adjustable health and cost 
@export var health = 100
@export var maw_health = 500 
@export var cost = 50
#Keep a reference to our sun scene 
var SunScene = preload("res://Scenes/PlantScenes/Sun.tscn")  # Adjust the path to your sun sprite scene
var PlantManager
@onready var animSpriteComp = $AnimatedSprite2D
@onready var sunTimer = $SunTimer
@onready var resetEatingTimer = $ResetEatingSpeed
@export var sunWaitTime := 40.0
@export var wyrmSunWaitTime :=  60.0
@export var hiveSunWaitTime := 28.0
@export var buffedSunWaitTime := 24.0 
@onready var buffNodes = $BuffNodesComponent
@onready var healTimer = $HealTimer
@onready var healInvisTimer = $HealInvisTimer
@onready var webbing_aoe_sprite = $Webs

var tween
var isBuffed = false 
var wyrmBuff = false
var hiveBuff = false 
var isWalnutBuffed = false
var mawBuff = false
var highlight_active = false
var highlight_material = null
var original_material = null
var plants_to_heal = []
var max_alpha = 0.2
var lerp_duration = 2.5
var can_eat_zombie = false 
var gridPos = Vector2(0,0)
var laneNumber = 0 

#Assign PlantManager and connect the apprioprate timers 
func _ready():
	calc_laneNumber()
	sunTimer.wait_time = sunWaitTime
	PlantManager = get_parent().get_parent().get_node("PlantManager") 
	$SunTimer.start()  # Start the timer
	assert($SunTimer.connect("timeout", Callable(self, "_on_SunTimer_timeout")) == OK)
	animSpriteComp.animation = "spawn"
	healTimer.wait_time = lerp_duration

	
	## Store the original material
	#original_material = animSpriteComp.material
	#
	## Create the highlight material (shader)
	#highlight_material = ShaderMaterial.new()
	#highlight_material.shader = load("res://Scripts/Shaders/outline_shader.gdshader")
	#highlight_material.set_shader_parameter("outline_width", 5.0)
	#highlight_material.set_shader_parameter("outline_color", Color(1.0, 0.7, 0.0, 1.0)) # Golden highlight	
	
func calc_laneNumber():
	gridPos = Vector2(self.global_position.x / 32, self.global_position.y /32)
	gridPos = Vector2(gridPos.x+0.5,gridPos.y + 0.5)
	laneNumber = gridPos.y
	#print("I, the Sunflower, am located at ",self.global_position, " gridPos is ", gridPos)

func get_laneNumber():
	return laneNumber
	
	
func toggle_highlight():
	print("Highlight Toggled")
	highlight_active = !highlight_active
	
	if highlight_active:
		animSpriteComp.material = highlight_material
	else:
		animSpriteComp.material = original_material	

# Called every time the sun timer reaches timeout
func _on_SunTimer_timeout():
	generate_sun()

# Function to handle sun generation
func generate_sun():
	if mawBuff:
		can_eat_zombie = true
	var sun_instance = SunScene.instantiate()  # Create a new instance of the sun
	if wyrmBuff:
		sun_instance.wyrm_buff()
	if hiveBuff:
		sun_instance.hive_buff()
	get_parent().add_child(sun_instance)  # Add the sun to the scene as a child of gamelayer
	#Set the sun pos to above the sunflower
	sun_instance.global_position = self.global_position + Vector2(0,-40)


# TODO Implement sunflower buff 
# Handles all pontential sunflower buffs 
func receiveBuff(newPlant):
	#print("Buff Name is ", newPlant.name)
	var plantName = truncate_string(newPlant.name)
	
	if !isBuffed :
		print("Sunflower Buff Received from ", plantName)
		match plantName:
			"Sunflower":
				
				animSpriteComp.change_form("Sunflower")
				
			"Peashooter":
				print("Change to SPIDERRR")
				$Webs.visible = true 
				webbing_aoe_sprite.visible = true 
				$SlowField.monitoring = true 
				animSpriteComp.change_form("Peashooter")
			"WalnutTree" :
				animSpriteComp.change_form("Walnut")
				$HealZone.visible = true 
				healTimer.start()
				start_alpha_pulse()
				tween.play()
				isWalnutBuffed = true
			"EggWorm":
				animSpriteComp.change_form("Wyrm")
				wyrmBuff = true
				sunTimer.wait_time = wyrmSunWaitTime
				$SunTimer.start()
			"Hive":
				animSpriteComp.change_form("Wasp")
				hiveBuff = true
				sunTimer.wait_time = hiveSunWaitTime
				$SunTimer.start()
			"Maw":
				animSpriteComp.change_form("Maw")
				health = maw_health
				can_eat_zombie = true
				mawBuff = true 
				
		#sunTimer.wait_time = buffedSunWaitTime
		
		isBuffed = true 
			
		animSpriteComp.make_buff_glow()


func truncate_string(input_string: String) -> String:
	for i in range(input_string.length()):
		var character = input_string[i]
		if character.is_valid_int():
			return input_string.substr(0, i)
	return input_string
	
	
func debuff():
	sunTimer.wait_time = sunWaitTime
	isBuffed = false
	pass

#Handles the sunflower taking damage 
func take_damage(damage):
	#print("taking damage, health is " , health)
	health = health - damage
	if(health <= 0):
		die()

# Plant Cost Getter
func get_cost():
	#print("1CCost is ", cost)
	cost = cost + (5 * Global.getSunflowerCount())
	#print("2CCost is ", cost)
	return cost
	#cost = cost + 5
	

# Stops Spawn Animation From Playing
func _on_AnimatedSprite_animation_finished():
	if animSpriteComp.animation == "spawn":
		animSpriteComp.animation = "idle"
		animSpriteComp.play()
	else:
		animSpriteComp.animation = animSpriteComp.currentAnim
		animSpriteComp.play()
		
		
		
func die():
	PlantManager.clear_space(self.global_position)
	buffNodes.clearBuffs()
	queue_free()	
		
func die_fromClearSpace():
	print("Should Clear the DDD Buffs")
	buffNodes.clearBuffs()
	queue_free()		
		

func highlight():
	print("Highlight Here")		
		

func adjust_position(new_form):
	match new_form:
		"Sunflower":
			pass

		"Peashooter":
			print("Self pos was ", self.global_position)
			self.global_position = self.global_position + Vector2(0,-2)
			print("Self pos IS ", self.global_position)
			
		"Walnut" :
			print("Self pos was ", self.global_position)
			self.global_position = self.global_position + Vector2(0,-2)
			print("Self pos IS ", self.global_position)
			
		"Wyrm":
			print("Self pos was ", self.global_position)
			self.global_position = self.global_position + Vector2(0,-2)
			print("Self pos IS ", self.global_position)
			
		"Wasp":
			print("Self pos was ", self.global_position)
			self.global_position = self.global_position + Vector2(0,-2)
			print("Self pos IS ", self.global_position)
			
		"Maw":
			print("Self pos was ", self.global_position)
			self.global_position = self.global_position + Vector2(0,-2)
			print("Self pos IS ", self.global_position)	


func _on_slow_field_area_entered(area: Area2D) -> void:
	#print(area , " just entered snow field")
	if area.is_in_group("Zombie"):
		#print("Zombie Entered Slow Field")
		#if area.get_parent().get_parent() != self.get_parent().get_parent():
			#return
		var compManager = area.getCompManager()
		var healthComp = compManager.getHealthComponent()
		#TODO Balance
		compManager.slow()


func _on_slow_field_body_entered(body: Node2D) -> void:
	#print(body , " just entered snow field b ")
	if body.is_in_group("Zombie"):
		#print("Zombie Entered Slow Field")
		#if area.get_parent().get_parent() != self.get_parent().get_parent():
			#return
		var compManager = body.getCompManager()
		var healthComp = compManager.getHealthComponent()
		#TODO Balance
		compManager.slow()


func _on_heal_zone_area_entered(area: Area2D) -> void:
	if area.is_in_group("Plants"):
		plants_to_heal.append(area)


func _on_heal_timer_timeout() -> void:
	#$HealZone.visible = true
	#healInvisTimer.start()
	for plant in plants_to_heal:
		plant.health = plant.health + 5


func _on_heal_invis_timer_timeout() -> void:
	pass
	#$HealZone.visible = false

func start_alpha_pulse():
	# Cancel any existing tween
	
	# Start with alpha at 0
	$HealZone.modulate.a = 0.0
	
	# Create infinite loop tween
	tween = create_tween().set_loops()
	
	# Lerp from 0 to max_alpha
	tween.tween_property($HealZone, "modulate:a", max_alpha, lerp_duration).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_IN)
	
	# Lerp back from max_alpha to 0
	tween.tween_property($HealZone, "modulate:a", 0.0, lerp_duration).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)


func mawBuffed():
	pass

func eat_zombie():
	animSpriteComp.speed_scale = 4
	#var resetSpeedEatingTimer = Timer.new()
	resetEatingTimer.start()
	can_eat_zombie = false
	pass


func _on_reset_eating_speed_timeout() -> void:
	animSpriteComp.speed_scale = 1
	generate_sun_alt()


func generate_sun_alt():
	var sun_instance = SunScene.instantiate()  # Create a new instance of the sun
	get_parent().add_child(sun_instance)  # Add the sun to the scene as a child of gamelayer
	#Set the sun pos to above the sunflower
	sun_instance.global_position = self.global_position + Vector2(0,-40)

#Register/Subscribe to Commander
func _on_area_entered(area: Area2D) -> void:
	pass
	#if area.is_in_group("Commander"):
		#area.register_plant(self, laneNumber)
