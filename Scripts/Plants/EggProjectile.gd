extends Area2D
#EggProjectile.gd


@export var speed = 1  # Speed of the projectile
@export var damage = 20.0 #2   # Damage dealt to zombies
var SunScene = preload("res://Scenes/PlantScenes/Sun.tscn")  # Adjust the path to your sun sprite scene

var canMove := false 
var isSlow := false 
var canGenSun := false


func _ready() -> void:
	print("ppp Spawned Egg p")
func _process(delta):
	if canMove:
		position.x += speed * delta  # Move the projectile to the right

	# Remove the projectile if it goes off-screen
	if position.x > get_viewport_rect().size.x:
		queue_free()  # Remove projectile if off-screen


# Handles projectile collison and damage application 
func _on_PeaProjectile_area_entered(area):
	print("Just Entered " , area )
	if area.is_in_group("Zombie"):
		if area.get_parent().get_parent() != self.get_parent().get_parent():
			print("Early Return, Wrong Layer")
			return
		print("No Return, Right Layer")
		var compManager = area.getCompManager()
		var healthComp = compManager.getHealthComponent()
		compManager.take_damage(damage)  # Call take_damage() on the zombie
		if isSlow:
			compManager.slow()
		#queue_free()  # Remove the projectile # Replace with function body.
		
		#Reduce Damage Every Time 
		damage = damage - 0.5
		
		if damage < 18.5 && canGenSun:
			generate_sun()
			canGenSun = false
	else:
		print("NOT A ZOMBIE")

func set_damage(new_damage):
	damage = new_damage

func _on_timer_timeout() -> void:
	canMove = true 


# Function to handle sun generation
func generate_sun():
	var sun_instance = SunScene.instantiate()  # Create a new instance of the sun
	get_parent().add_child(sun_instance)  # Add the sun to the scene as a child of gamelayer
	#Set the sun pos to above the sunflower
	sun_instance.global_position = self.global_position + Vector2(0,-40)
