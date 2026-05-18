extends Area2D
#BaseZombie.gd

class_name Zombie 
# Defines basic behavior for all zombie types

signal zombie_death

@onready var compManager = $ComponentManager
@onready var healthComp = $HealthComponent
@onready var speedComp = $SpeedComponent
@onready var attackComp = $AttackComponent

var column_explosion
var slow_field_scene = preload("res://_Entities/Demons/WebTile/web_tile_slow.tscn")
const DroneScene = preload("res://_Entities/Demons/Minion_Drone.tscn")
var silence_field
var is_silenced := false
@export var silence_field_position : Vector2

@export var charge_cost := 1

func _ready() -> void:
	
	Global.register_zombie(self)
	if self.is_in_group("Green"):
	#	print("SET TO GTREEEEEEEN SO CAN ATTTACK GREEEN")
		self.set_collision_layer_value(1,false)
		self.set_collision_layer_value(2,false)
		self.set_collision_layer_value(3,false)
		self.set_collision_layer_value(3,false)
		self.set_collision_layer_value(5,true)
	else:
		self.set_collision_layer_value(1,false)
		self.set_collision_layer_value(2,false)
		self.set_collision_layer_value(3,false)
		self.set_collision_layer_value(4,true)
	#set_hue_shift
	
func freeze():
	speedComp.freeze()
	
# Component Manager Getter
func getCompManager():
	return compManager

# Tells Comp Manager the Zombie is Fighting a Hive Drone 
func fightDrone():
	compManager.fightDrone()

func make_spawn_slow_on_death():
	compManager.spawn_slow_field = true 
	
	
# Tells Comp Manager the Zombie Stopped Fighting a Hive Drone 
func reset_speed():
	compManager.reset_speed()

#Tells Comp Manager This Zombie Will Explode When Killed 
func fightDroneExplode():
	compManager.fightDroneExplode()
	
#Tells Comp Manager to execute this Zombie's special move
func special_move():
	compManager.special_move()

#TODO Pick Up Here Left Off Here 
func set_hue_shift(hue_shift_degrees):
	compManager.set_hue_shift(hue_shift_degrees)
	
func silence():
	if !is_silenced:
		silence_field = (Global.get_silence_field()).instantiate()
		add_child(silence_field)
		silence_field.play()
		is_silenced = true
	else:
		return 
	

#Kills the Zombie 
func die():
	Global.deregister_zombie(self)
	print(self, " dying")
	if compManager.spawn_slow_field == true :
		spawn_slow_field_on_death()
	if compManager.spawn_drone_on_death == true :
		print("Should Spawn Drone")
		spawn_drone_on_death()
	if compManager.should_column_explode:
		print(self, "Should MAKE AN EXPLOSION")
		column_explosion = Global.get_column_death_explosion().instantiate()
		column_explosion.global_position = global_position
		get_parent().add_child(column_explosion)
	#if compMana
#	print("Should die")
	zombie_death.emit()

	if $AnimatedSprite2D.sprite_frames.has_animation("death"):
		$AnimatedSprite2D.isDead = true 
		$AnimatedSprite2D.play("death")
	queue_free()
	
	
	
func spawn_slow_field_on_death():
	var slow_field
	slow_field = slow_field_scene.instantiate()
	slow_field.global_position = self.global_position
	#slow_field.position = position + Vector2(32, 8)  # Adjust starting position
	get_parent().add_child(slow_field)  # Add the projectile to the game layer DOUBLE CHECK
	
	
	
func change_dimensions(new_position):
	self.reparent(Global.get_game_controller().get_alt_dimension().get_node("GameLayer"))
	if self.is_in_group("Green"):
		self.remove_from_group("Green")
		self.add_to_group("Purple")
		self.set_collision_layer_value(2,true)
		set_hue_shift(-86)
	else:
		self.remove_from_group("Purple")
		self.add_to_group("Green")
		self.set_collision_layer_value(3,true)
		set_hue_shift(125)
	self.global_position = new_position
	
func blood_slow():
	compManager.blood_slow()
	
	
func undoBloodSlow():
	compManager.undoBloodSlow()

func get_charge_cost():
	return charge_cost
		
	
func _on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		#print(self, " was clicked ")
		Global.set_zombie_info_bar(self)
		pass

func get_health():
	return healthComp.health
	
func get_max_health():
	return healthComp.maxHealth
	
func get_speed():
	return speedComp.speed
	
func get_damage():
	return attackComp.attack_power
	
func spawn_drone_on_death():
	var drone = DroneScene.instantiate()
	drone.is_stationary = true 
	get_parent().add_child(drone)
	if self.is_in_group("Green"):
		drone.add_to_group("Green")
	else:
		drone.add_to_group("Purple")
		
		
	drone.global_position = global_position

			
			
			
			
			
