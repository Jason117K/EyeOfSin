extends Demon
#HeartDemon.gd

@export var cost = 0

var DemonManager
var duration : float 

@onready var buffNodes = $BuffNodesComponent
@onready var projectile_shoot_component := $ProjectileShootComponent


#Circle Sprite for Special Move
#@onready var beatOfDeathCirle = $BeatOfDeathCircle

const EXPAND_SCALE: Vector2 = Vector2(0.35, 0.35)  # How large the sprite grows
const START_SCALE: Vector2 = Vector2(0.1, 0.1)

#Grab demonmanager, start default anim and connect/start relevant timers 
func _ready():
	print("Hero DEMON Ready")
	Global.register_hero_demon(self)
	$PreviewNodes/AnimatedSprite2D.hide()
	#set_attack_collision()

	DemonManager = get_parent().get_parent().get_node("DemonManager")

	# Calculate duration from the current animation's frame count and speed
	var frame_count: int = animSpriteComp.sprite_frames.get_frame_count(animSpriteComp.currentAttackAnim)
	var fps: float = animSpriteComp.sprite_frames.get_animation_speed(animSpriteComp.currentAttackAnim)
	duration = frame_count / fps	
	
func set_attack_collision():
	projectile_shoot_component.set_attack_rays_collision()
	
#Cost getter 
func get_cost():
	#print("Return , ", cost )
	return cost
	
					
# Doubles attack speed when receiving a buff 
func receive_buff(newDemon):
	pass


func get_can_attack():
	return projectile_shoot_component.canAttack
	
					
func die():
	DemonManager.clear_space(self.global_position)
	buffNodes.clearBuffs()
	queue_free()	
	
func die_fromClearSpace():
	#print("DD YYYING ---------------------------------")
	buffNodes.clearBuffs()
	queue_free()		
	
	
func _on_mouse_entered() -> void:
	$PreviewNodes.visible = true 


func _on_mouse_exited() -> void:
	$PreviewNodes.visible = false 

	
#func beat_of_death():
	## Reset sprite to starting state
	#beatOfDeathCirle.scale = START_SCALE
	#beatOfDeathCirle.modulate.a = 1.0
	#beatOfDeathCirle.visible = true
#
	#var tween: Tween = create_tween()
	#tween.set_parallel(true)  # Run scale and fade simultaneously
#
	## Scale up
	#tween.tween_property(beatOfDeathCirle, "scale", EXPAND_SCALE, duration)
#
	## Fade out
	#tween.tween_property(beatOfDeathCirle, "modulate:a", 0.0, duration)
	#$BuffZone/CollisionShape2D.disabled = false
	


	
