extends Node2D
#SummonComponent.gd

@export var slow_summon_wait_time := 17
# Copied from the parent Tank's summon_wait_time in _ready
var summon_timer_wait_time := 5

#Various node references
@onready var summonTimer := $SummonTimer
@onready var tankZombie :Zombie = get_parent()
@onready var animatedSpriteComp := get_parent().get_node("AnimatedSprite2D")
@onready var attackComp :ZombieAttackRefCountedComponent  

#Summon Points for MinionZombie
@onready var minion_summon_point := $SummonPoint1


#Load the zombie we will summon
var minion_zombie_scene := preload("res://_Entities/Zombies/_MinionZombie/MinionZombie.tscn")
var is_silenced := false
var is_attacking:bool

func _ready() -> void:
	if "summon_wait_time" in tankZombie:
		summon_timer_wait_time = tankZombie.get("summon_wait_time")
	summonTimer.wait_time = summon_timer_wait_time

func silence() -> void:
	is_silenced = true


func summon_backup() -> void:
	if is_silenced:
		return

	var game_layer := get_parent().get_parent()
	var is_green := get_parent().is_in_group("Green")

	


	var zombie_instance :Zombie= minion_zombie_scene.instantiate()
	zombie_instance.add_to_group("Green" if is_green else "Purple")
	game_layer.add_child(zombie_instance)
	zombie_instance.animatedSprite.specialMove = true
	zombie_instance.animatedSprite.animation = "Spawn"
	zombie_instance.global_position = minion_summon_point.global_position
	#print("Should Have Summoned ", zombie_instance, " with parent " , zombie_instance.get_parent())

	if is_green:
		#zombie_instance.add_to_group("Green")
		zombie_instance.set_hue_shift(125)
		zombie_instance.set_collision_layer_value(1, false)
		zombie_instance.set_collision_layer_value(2, false)
		zombie_instance.set_collision_layer_value(3, false)
		zombie_instance.set_collision_layer_value(4, false)
		zombie_instance.set_collision_layer_value(5, true)
	else:
		#zombie_instance.add_to_group("Purple")
		zombie_instance.set_hue_shift(-86)
		zombie_instance.set_collision_layer_value(1, false)
		zombie_instance.set_collision_layer_value(2, false)
		zombie_instance.set_collision_layer_value(3, false)
		zombie_instance.set_collision_layer_value(4, true)

		await get_tree().process_frame

	zombie_instance.animatedSprite.play()
	#zombie_instance.animatedSprite.play("Spawn")
			
#Start the summon again by setting the animation
func _on_SummonTimer_timeout() -> void:
	#summonTimer.wait_time = slow_summon_wait_time
	summonTimer.start()
	tankZombie.setSpeed(0)
	animatedSpriteComp.animation = "LaunchZombie"
	animatedSpriteComp.setSpecialMoveTrue()

# Start the actual summon at a certain point in the animation
func _on_AnimatedSprite_animation_finished() -> void:
	##print(animatedSpriteComp.animation, " just finished playing")
	if(animatedSpriteComp.animation == "LaunchZombie"):
		tankZombie.reset_speed()
		##print(animatedSpriteComp.animation)
		##print("AnimPlayed")
		#summon_backup()
		animatedSpriteComp.setSpecialMoveFalse()
		is_attacking = attackComp.getAttackState()
		if is_attacking:
			animatedSpriteComp.animation = "Attack"
		else:
			animatedSpriteComp.animation = "Walk"
			#animatedSpriteComp.reparent()
		
	
func _on_animated_sprite_2d_frame_changed() -> void:
	if(animatedSpriteComp.animation == "LaunchZombie"):
		if animatedSpriteComp.frame == 4:
			summon_backup()
