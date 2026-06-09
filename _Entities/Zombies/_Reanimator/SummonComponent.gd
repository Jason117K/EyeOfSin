extends Node2D
#SummonComponent.gd

@export var slow_summon_wait_time := 17

#Various node references
@onready var summonTimer := $SummonTimer
@onready var dancerZombie :Zombie = get_parent()
@onready var animatedSpriteComp := get_parent().get_node("AnimatedSprite2D")
@onready var attackComp :ZombieAttackRefCountedComponent    #= dancerZombie.get_attack_comp() # $"../AttackComponent"

#Summon Points for BackUp Dancers
@onready var point1 := $SummonPoint1
@onready var point2 := $SummonPoint2
@onready var point3 := $SummonPoint3
@onready var point4 := $SummonPoint4
@onready var point6 := $SummonPoint6
@onready var point7 := $SummonPoint7
@onready var point8 := $SummonPoint8
@onready var point9 := $SummonPoint9
@onready var points := [point1,point2,point3,point4,point6,point7,point8,point9]

#Load the zombie we will summon
var BackUpDancerScene := preload("res://_Entities/Zombies/_Wretch/BackUpDancerZombie.tscn")
var is_silenced := false
var is_attacking:bool #Whether or not we are attacking

func _ready() -> void:
	pass

func silence() -> void:
	is_silenced = true

#Summon the Floating Tentacle head backup dancers
func summon_backup() -> void:
	if is_silenced:
		return
	#print("Summoning ",dancerZombie.position.y)

	var game_layer := get_parent().get_parent()
	var is_green := get_parent().is_in_group("Green")

	var spawn_points := points.duplicate()

	if dancerZombie.position.y < 128:
		spawn_points.erase(point1)
		spawn_points.erase(point2)
		spawn_points.erase(point3)

	if dancerZombie.position.y > 288:
		spawn_points.erase(point7)
		spawn_points.erase(point8)
		spawn_points.erase(point9)

	for point:Node in spawn_points:
		if not is_instance_valid(dancerZombie):
			return
		var zombie_instance := BackUpDancerScene.instantiate()
		game_layer.add_child(zombie_instance)
		zombie_instance.global_position = point.global_position

		if is_green:
			zombie_instance.add_to_group("Green")
			zombie_instance.set_hue_shift(125)
			zombie_instance.set_collision_layer_value(1, false)
			zombie_instance.set_collision_layer_value(2, false)
			zombie_instance.set_collision_layer_value(3, false)
			zombie_instance.set_collision_layer_value(4, false)
			zombie_instance.set_collision_layer_value(5, true)
		else:
			zombie_instance.add_to_group("Purple")
			zombie_instance.set_hue_shift(-86)
			zombie_instance.set_collision_layer_value(1, false)
			zombie_instance.set_collision_layer_value(2, false)
			zombie_instance.set_collision_layer_value(3, false)
			zombie_instance.set_collision_layer_value(4, true)

		await get_tree().process_frame
			
			
#Start the summon again by setting the animation
func _on_SummonTimer_timeout() -> void:
	summonTimer.wait_time = slow_summon_wait_time
	summonTimer.start()
	dancerZombie.setSpeed(0)
	animatedSpriteComp.animation = "Summon"
	animatedSpriteComp.setSpecialMoveTrue()

# Start the actual summon at a certain point in the animation
func _on_AnimatedSprite_animation_finished() -> void:
	#print(animatedSpriteComp.animation, " just finished playing")
	if(animatedSpriteComp.animation == "Summon"):
		dancerZombie.reset_speed()
		#print(animatedSpriteComp.animation)
		#print("AnimPlayed")
		summon_backup()
		animatedSpriteComp.setSpecialMoveFalse()
		is_attacking = attackComp.getAttackState()
		if is_attacking:
			animatedSpriteComp.animation = "Attack"
		else:
			animatedSpriteComp.animation = "Walk"
			#animatedSpriteComp.reparent()
		
		
		
		
