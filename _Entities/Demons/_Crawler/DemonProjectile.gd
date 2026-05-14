extends Area2D
#DemonProjectile.gd


@export var speed = 300  # Speed of the projectile
@export var damage = 20 #2   # Damage dealt to zombies
@export var lightning_damage = 10 #2   # Damage dealt to zombies
var blood_scene = preload("res://_Entities/Demons/Blood/Blood.tscn") 

var spinalOcculumBuff := false 
var bloodBuff := false 
var wyrmBuff := false

var piercing := false 
var is_slowing := true 
var canGenBlood := false 

var collision 

func print_scene_tree(node: Node = self, indent: int = 0) -> void:
	var prefix := "\t".repeat(indent)
	print(prefix + node.name + "(" + node.get_class() + ")")
	for child in node.get_children():
		print_scene_tree(child, indent + 1)
		
func _ready() -> void:
	#print_scene_tree()
	self.area_entered.connect(on_hit)
	
func _physics_process(delta: float) -> void:
	var travel_distance = speed * delta
	
	# Raycast along travel path to prevent tunneling at high speeds
	var space_state = get_world_2d().direct_space_state
	var query = PhysicsRayQueryParameters2D.create(
		global_position,
		global_position + Vector2(travel_distance, 0)
		)
	query.collide_with_areas = true
	query.collide_with_bodies = false
	query.collision_mask = collision_mask
	query.exclude = [self.get_rid()]

	var result = space_state.intersect_ray(query)
	if result:
		# Clamp movement to the hit point — projectile arrives at its natural speed
		position.x += result.position.x - global_position.x
	else:
		position.x += travel_distance
	if position.x > get_viewport_rect().size.x:
		queue_free()
		
#func _physics_process(delta: float) -> void:
	### Code For CharacterBody2D
	##velocity = Vector2(speed,0)
	##collision = move_and_collide(velocity*delta)
	##if collision:
		##print("Collision Projectile DetectedDDDDDDDD")
		##on_hit(collision.get_collider())
		#
	#position.x += speed * delta  # Move the projectile to the right
#
	## Remove the projectile if it goes off-screen
	#if position.x > get_viewport_rect().size.x:
		#queue_free()  # Remove projectile if off-screen
		#
	

func setup_lightning_zone():
	$LightningZone.visible = true 
	$LightningZone.monitoring = true 
	$AnimatedSprite2D.visible = true 
	$LightningZone/CollisionShape2D.disabled = false

# Handles projectile collison and damage application 
func on_hit(area):

	if area.is_in_group("Zombie"):
		if area.get_parent().get_parent() != self.get_parent().get_parent():
			return
		var compManager = area.getCompManager()
		var healthComp = compManager.getHealthComponent()
		if is_slowing:
			compManager.slow()
		compManager.take_damage(damage)  # Call take_damage() on the zombie
		if spinalOcculumBuff:
			compManager.knockBack()
		if bloodBuff:
			var demon_manager = get_parent().get_parent().get_node("DemonManager")
			if demon_manager:  # If the DemonManager or GameManager is set
				#$CollectAudioPlayer.play()
				demon_manager.add_blood(2.0)  # Add 25 blood points (or whatever amount)
				demon_manager.play_blood_collect()
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
		
# Function to handle blood generation
func generate_blood():
	var blood_instance = blood_scene.instantiate()  
	get_parent().add_child(blood_instance)  
	#Set the blood pos to above the occulum
	blood_instance.global_position = self.global_position + Vector2(0,-40)
