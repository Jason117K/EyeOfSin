extends Area2D
#DemonProjectile.gd


@export var speed = 300  # Speed of the projectile
@export var damage = 20 #2   # Damage dealt to zombies
@export var lightning_damage = 10 #2   # Damage dealt to zombies
var blood_scene = preload("res://_Entities/Demons/Blood/Sun.tscn")  # Adjust the path to your sun sprite scene

var walnutBuff := false 
var sunBuff := false 
var wyrmBuff := false

var piercing := false 
var is_slowing := true 
var canGenBlood := false 


func _ready() -> void:
	pass

func _process(delta):
	position.x += speed * delta  # Move the projectile to the right

	# Remove the projectile if it goes off-screen
	if position.x > get_viewport_rect().size.x:
		queue_free()  # Remove projectile if off-screen

func setup_lightning_zone():
	$LightningZone.visible = true 
	$LightningZone.monitoring = true 
	$AnimatedSprite2D.visible = true 
	$LightningZone/CollisionShape2D.disabled = false

# Handles projectile collison and damage application 
func _on_PeaProjectile_area_entered(area):

	if area.is_in_group("Zombie"):
		if area.get_parent().get_parent() != self.get_parent().get_parent():
			return
		var compManager = area.getCompManager()
		var healthComp = compManager.getHealthComponent()
		if is_slowing:
			compManager.slow()
		compManager.take_damage(damage)  # Call take_damage() on the zombie
		if walnutBuff:
			compManager.knockBack()
		if sunBuff:
			var plant_manager = get_parent().get_parent().get_node("PlantManager")
			if plant_manager:  # If the PlantManager or GameManager is set
				#$CollectAudioPlayer.play()
				plant_manager.add_sun(2.0)  # Add 25 sun points (or whatever amount)
				plant_manager.play_sun_collect()
			#compManager.increaseBloodWorth()
		if damage < 18.5 && canGenBlood:
			generate_blood()
			canGenBlood = false
		if piercing == false:
			queue_free() 
		else:
			damage = damage - 0.5


func _on_lightning_zone_area_entered(area: Area2D) -> void:
	if area.is_in_group("Zombie"):
		print(area, " is INDEED in Zombie Group")
		if area.get_parent().get_parent() != self.get_parent().get_parent():
			#print("Early Return Rr")
			pass
			return
		var compManager = area.getCompManager()
		var healthComp = compManager.getHealthComponent()
		compManager.slow()
		compManager.take_damage(lightning_damage)  # Call take_damage() on the zombie
	else:
		print(area, " is not in Zombie Group")
		
# Function to handle sun generation
func generate_blood():
	var blood_instance = blood_scene.instantiate()  # Create a new instance of the sun
	get_parent().add_child(blood_instance)  # Add the sun to the scene as a child of gamelayer
	#Set the sun pos to above the sunflower
	blood_instance.global_position = self.global_position + Vector2(0,-40)
