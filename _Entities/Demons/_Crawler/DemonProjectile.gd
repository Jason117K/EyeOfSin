extends Area2D
#DemonProjectile.gd

@onready var lightning_detection_zone : Area2D = $LightningZone
@onready var lightning_zone_visual := $LightningZoneAnimSprite

@export var speed = 300  # Speed of the projectile
@export var damage = 20 #2   # Damage dealt to zombies
@export var lightning_damage = 10 #2   # Damage dealt to zombies
@export var blood_worth_to_add = 1
@export var bleed_damage := 1

var blood_scene = preload("res://_Entities/Demons/Blood/Blood.tscn") 
var num_zombies_hit = 0 
var spinalOcculumBuff := false 
var give_blood_on_death := false 
var spawn_drone_on_zombie_death := false 
var wyrmBuff := false

var piercing := false 
var is_slowing := true 
var canGenBlood := false 
var bleed := false 
var column_explode := false

var collision 

func print_scene_tree(node: Node = self, indent: int = 0) -> void:
	var prefix := "\t".repeat(indent)
	print(prefix + node.name + "(" + node.get_class() + ")")
	for child in node.get_children():
		print_scene_tree(child, indent + 1)
		
func _ready() -> void:
	#print_scene_tree()
	self.area_entered.connect(on_hit)
	if wyrmBuff:
		print("SETUP LIGHTNING ZONE")
		setup_lightning_zone()
	if self.is_in_group("Green"):
		self.set_collision_mask_value(1,false)
		self.set_collision_mask_value(2,false)
		self.set_collision_mask_value(3,false)
		self.set_collision_mask_value(4,false)
		self.set_collision_mask_value(5,true)
	else:
		self.set_collision_mask_value(1,false)
		self.set_collision_mask_value(2,false)
		self.set_collision_mask_value(3,false)
		self.set_collision_mask_value(4,true)	
		
				
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
	if self.is_in_group("Green"):
		lightning_detection_zone.set_collision_mask_value(1,false)
		lightning_detection_zone.set_collision_mask_value(2,false)
		lightning_detection_zone.set_collision_mask_value(3,false)
		lightning_detection_zone.set_collision_mask_value(4,false)
		lightning_detection_zone.set_collision_mask_value(5,true)
	else:
		lightning_detection_zone.set_collision_mask_value(1,false)
		lightning_detection_zone.set_collision_mask_value(2,false)
		lightning_detection_zone.set_collision_mask_value(3,false)
		lightning_detection_zone.set_collision_mask_value(4,true)		
	lightning_zone_visual.show()
	lightning_zone_visual.play()
	lightning_detection_zone.show()
	lightning_detection_zone.monitoring = true 
	lightning_detection_zone.get_child(0).disabled = false 


# Handles projectile collison and damage application 
func on_hit(area):
	if area.is_in_group("Zombie"):
		if area.get_parent().get_parent() != self.get_parent().get_parent():
			return
		var compManager = area.getCompManager()
		var healthComp = compManager.getHealthComponent()
		if is_slowing:
			compManager.slow()
		if spinalOcculumBuff:
			compManager.knockBack()
		if give_blood_on_death:
			healthComp.add_blood_worth(blood_worth_to_add)
		if spawn_drone_on_zombie_death:
			compManager.spawn_drone_on_zombie_death()
		if num_zombies_hit > 3 && canGenBlood:
			generate_blood()
			canGenBlood = false
		if bleed:
			compManager.bleed(bleed_damage)
		if column_explode:
			compManager.column_explode()
			column_explode = false
			
		compManager.take_damage(damage)  # Call take_damage() on the zombie
		if piercing == false:
			queue_free() 
		else:
			damage = damage - 0.5
			num_zombies_hit += 1 

func increase_bleed_damage(bleed_damage_increase):
	bleed_damage = bleed_damage + bleed_damage_increase
	

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
	print("Generating Blood")
	var blood_instance = blood_scene.instantiate()  
	
	get_parent().add_child(blood_instance) 
	blood_instance.set_fast_pickup_time() 
	#Set the blood pos to above the occulum
	blood_instance.global_position = self.global_position + Vector2(0,-9)
