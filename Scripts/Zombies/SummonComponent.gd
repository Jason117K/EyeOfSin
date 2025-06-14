extends Node2D
#SummonComponent.gd

#Various node references 
@onready var summonTimer = $SummonTimer
@onready var dancerZombie = get_parent()
@onready var animatedSpriteComp = get_parent().get_node("AnimatedSprite2D")
@onready var attackComp = $"../AttackComponent"

#Summon Points for BackUp Dancers 
@onready var point1 = $SummonPoint1
@onready var point2 = $SummonPoint2
@onready var point3 = $SummonPoint3
@onready var point4 = $SummonPoint4
@onready var point6 = $SummonPoint6
@onready var point7 = $SummonPoint7
@onready var point8 = $SummonPoint8
@onready var point9 = $SummonPoint9
@onready var points = [point1,point2,point3,point4,point6,point7,point8,point9]

#Load the zombie we will summon
var BackUpDancerScene = preload("res://Scenes/ZombieScenes/BackUpDancerZombie.tscn")

var is_attacking #Whether or not we are attacking 

#Summon the Floating Tentacle head backup dancers 
func summon_backup():
	print("Summoning",dancerZombie.position.y)
	# Get reference to GameLayer
	var game_layer = get_parent().get_parent()
	var root = get_tree().current_scene
	var level = root.get_name()
	
	#TODO double check these postions 
	
	
	# Don't spawn them in unreachable areas 
	if(dancerZombie.position.y < 99):
		points.erase(point1)
		points.erase(point2)
		points.erase(point3)
		
	if level == "Main" && (dancerZombie.position.y < 112):
		points.erase(point1)
		points.erase(point2)
		points.erase(point3)
		
	if(dancerZombie.position.y > 203):
		points.erase(point7)
		points.erase(point8)
		points.erase(point9)
		
	if level == "Main" && (dancerZombie.position.y > 163):
		points.erase(point7)
		points.erase(point8)
		points.erase(point9)

	#Spawn a backUp dancer at every available point 
	for point in points:
		#print("Adding Zombie to ", point.name)
		var zombie_instance = BackUpDancerScene.instantiate()
		
		# Convert spawn point's position to global coordinates
		var global_spawn_pos = point.global_position
		
		# Add zombie to GameLayer
		game_layer.add_child(zombie_instance)
		
		# Set the zombie's global position
		zombie_instance.global_position = global_spawn_pos

#Start the summon again by setting the animation 
func _on_SummonTimer_timeout():
	animatedSpriteComp.animation = "Summon"
	animatedSpriteComp.setSpecialMoveTrue()

# Start the actual summon at a certain point in the animation 
func _on_AnimatedSprite_animation_finished():
	#print(animatedSpriteComp.animation, " just finished playing")
	if(animatedSpriteComp.animation == "Summon"):
		#print(animatedSpriteComp.animation)
		#print("AnimPlayed")
		summon_backup()
		animatedSpriteComp.setSpecialMoveFalse()
		is_attacking = attackComp.getAttackState()
		if is_attacking:
			animatedSpriteComp.animation = "Attack"
		else:
			animatedSpriteComp.animation = "Walk"
		
		
		
		
