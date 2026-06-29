extends Area2D
#DemonProjectile.gd

@onready var lightning_detection_zone : Area2D = $LightningZone
@onready var lightning_zone_visual := $LightningZoneAnimSprite
@onready var projectile_anim_sprite := $ProjectileAnimSprite

var bleed_damage := 0

var speed := 325  # Speed of the projectile
var damage :float= 20 #2   # Damage dealt to zombies
var lightning_damage := 15 #2   # Damage dealt to zombies
var max_distance_can_travel :float= 0
var blood_worth_to_add := 0


var blood_scene := preload("res://_Entities/Demons/Blood/Blood.tscn")
var num_zombies_hit := 0
var spinalOcculumBuff := false 
var give_blood_on_death := false 
var spawn_drone_on_zombie_death := false 
var wyrmBuff := false

var piercing := false 
var is_slowing := true 
var canGenBlood := false 
var bleed := false 
var column_explode := false
var silencing := false 
var is_on_fire := false 

var collision : Node
var distance_traveled :float= 0
var _spawn_initialized := false
var spawn_position: Vector2

var hit_once := false 

func print_scene_tree(node: Node = self, indent: int = 0) -> void:
	var prefix := "\t".repeat(indent)
	print(prefix + node.name + "(" + node.get_class() + ")")
	for child in node.get_children():
		print_scene_tree(child, indent + 1)
	
func _wyrmBuff()->void:
	wyrmBuff = true
	modulate = Color("ff0000")
	
func _ready() -> void:
	#print(self, " Projectile Ready Position Is ", self.position)
	#print_scene_tree()
	if max_distance_can_travel == 0:
		max_distance_can_travel = get_viewport_rect().size.x

	self.area_entered.connect(on_hit)
	if wyrmBuff:
		#print("SETUP LIGHTNING ZONE")
		setup_lightning_zone()
	else:
		lightning_detection_zone.monitoring = false
		lightning_detection_zone.get_child(0).disabled = true
		lightning_zone_visual.hide()
	if self.is_in_group("Green"):
		self.set_collision_mask_value(1,false)
		self.set_collision_mask_value(2,false)
		self.set_collision_mask_value(3,false)
		self.set_collision_mask_value(4,false)
		self.set_collision_mask_value(5,true)
		
		self.set_collision_layer_value(2,false)
		self.set_collision_layer_value(3,true)
	else:
		self.set_collision_mask_value(1,false)
		self.set_collision_mask_value(2,false)
		self.set_collision_mask_value(3,false)
		self.set_collision_mask_value(4,true)	
		
		self.set_collision_layer_value(2,true)
		self.set_collision_layer_value(3,false)
	#print(get_world_2d().direct_space_state , " area_entered connections: ", self.area_entered.get_connections())
	#print("AREA OVERLAPP", get_overlapping_areas() )
				
func _physics_process(delta: float) -> void:
	if not _spawn_initialized:
		spawn_position = position
		_spawn_initialized = true
	#print("AREA OVERLAPP", get_overlapping_areas() )
	#print(self, " Projectile 4Position Is ", self.position)
	var travel_distance := speed * delta
	distance_traveled = position.x - spawn_position.x
	
	# Raycast along travel path to prevent tunneling at high speeds
	var _space_state :PhysicsDirectSpaceState2D = get_world_2d().direct_space_state
	var query := PhysicsRayQueryParameters2D.create(
		global_position,
		global_position + Vector2(travel_distance, 0)
		)
	query.collide_with_areas = true
	query.collide_with_bodies = false
	query.collision_mask = collision_mask
	query.exclude = [self.get_rid()]

	position.x += travel_distance
	distance_traveled = position.x - spawn_position.x
	#print(self, " Projectile 6Position Is ", self.position)
	if distance_traveled > max_distance_can_travel:
		if max_distance_can_travel > 0:
			#print(self, " Traveled Too Far, ", distance_traveled , " is greater than ", max_distance_can_travel, " Time to Die ")
			queue_free()
		

func setup_lightning_zone() -> void:
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
func on_hit(area: Area2D) -> void:
	if hit_once:
		if !piercing:
			return
	else:
		hit_once = true 
	#print("Area Hit Is ", area)
	if area.is_in_group("Zombie"):
		#if area.get_parent().get_parent() != self.get_parent().get_parent():
			#return
		print(self,"Zombie Hit Is ", area)
		var healthComp :ZombieHealthRefCountedComponent = area.getHealthComponent()
		if healthComp.health < 1:
			return 
		if is_slowing:
			area.slow()
		if spinalOcculumBuff:
			area.knockBack()
		if give_blood_on_death:
			print("Adding Blood Worth of ", blood_worth_to_add)
			healthComp.add_blood_worth(blood_worth_to_add)
		if spawn_drone_on_zombie_death:
			area.spawn_drone_on_zombie_death()
		if num_zombies_hit > 3 && canGenBlood:
			generate_blood()
			canGenBlood = false
		if bleed:
			area.bleed(bleed_damage)
		if column_explode:
			area.column_explode()
			column_explode = false
		if silencing:
			area.silence()
		#print("Calling Take Damage On ", area, " damage is ", damage)
		if is_on_fire:
			pass
			area.set_on_fire()
		area.take_damage(false,damage,piercing)
		if piercing == false:
			
			queue_free() 
		else:
			damage = damage - 0.5
			num_zombies_hit += 1 

func increase_bleed_damage(bleed_damage_increase: int) -> void:
	bleed_damage = bleed_damage + bleed_damage_increase

func enflame(enflame_damage_mult : float)->void:
	if self.is_in_group("Green"):
		projectile_anim_sprite.play("GreenFlame")
	else:
		projectile_anim_sprite.play("PurpleFlame")
	damage = damage * enflame_damage_mult
	is_on_fire = true 
		

func _on_lightning_zone_area_entered(area: Area2D) -> void:
	if area.is_in_group("Zombie"):
		#print(area, " is INDEED in Zombie Group")

		#area.slow()
		area.take_damage(false,lightning_damage,false)
	else:
		pass
		#print(area, " is not in Zombie Group")
		
# Function to handle blood generation
func generate_blood() -> void:
	print("Generating Blood From Proj")
	var blood_instance := blood_scene.instantiate()
	get_parent().add_child(blood_instance) 
	blood_instance.set_fast_pickup_time() 
	blood_instance.global_position = self.global_position + Vector2(0,-9)
