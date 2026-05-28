extends Demon
#HeartDemon.gd


#var DemonManager
var duration: float


#@onready var buffNodes = $BuffNodesComponent
@onready var projectile_shoot_component := $ProjectileShootComponent
@onready var beat_of_death_damage_aoe := $BeatOfDeathDamage
@onready var hero_ability_component := $HeroAbilityComponent
#Circle Sprite for Special Move
#@onready var beatOfDeathCirle = $BeatOfDeathCircle

var is_hero = true 

const EXPAND_SCALE: Vector2 = Vector2(0.35, 0.35)  # How large the sprite grows
const START_SCALE: Vector2 = Vector2(0.1, 0.1)

#Grab demonmanager, start default anim and connect/start relevant timers 
func _ready() -> void:
	print("Hero DEMON Ready")
	Global.register_hero_demon(self)
	$PreviewNodes/AnimatedSprite2D.hide()
	#set_attack_collision()

	demon_manager = get_parent().get_parent().get_node("DemonManager")

	# Calculate duration from the current animation's frame count and speed
	var frame_count: int = animSpriteComp.sprite_frames.get_frame_count(animSpriteComp.currentAttackAnim)
	var fps: float = animSpriteComp.sprite_frames.get_animation_speed(animSpriteComp.currentAttackAnim)
	duration = frame_count / fps	
	
	
	set_beat_of_death_collision()


func set_beat_of_death_collision()->void:
	if self.is_in_group("Green"):
		
		beat_of_death_damage_aoe.set_collision_mask_value(1,false)
		beat_of_death_damage_aoe.set_collision_mask_value(2,false)
		beat_of_death_damage_aoe.set_collision_mask_value(3,false)
		beat_of_death_damage_aoe.set_collision_mask_value(4,false)
		beat_of_death_damage_aoe.set_collision_mask_value(5,true)
	else:
		beat_of_death_damage_aoe.set_collision_mask_value(1,false)
		beat_of_death_damage_aoe.set_collision_mask_value(2,false)
		beat_of_death_damage_aoe.set_collision_mask_value(3,false)
		beat_of_death_damage_aoe.set_collision_mask_value(4,true)			
			
func set_attack_collision() -> void:
	projectile_shoot_component.set_attack_rays_collision()

#Cost getter
func get_cost() -> float:
	#print("Return , ", cost )
	return cost

func swap_scenes()->void:
	projectile_shoot_component.set_attack_rays_collision()
	set_beat_of_death_collision()
	if is_in_group("Green"):
		set_collision_layer_value(1, false)
		set_collision_layer_value(2, false)
		set_collision_layer_value(3, true)
	else:
		set_collision_layer_value(1, false)
		set_collision_layer_value(2, true)
		set_collision_layer_value(3, false)
		
		
# Doubles attack speed when receiving a buff
func receive_buff(_newDemon:String) -> void:
	pass


func get_can_attack() -> bool:
	return projectile_shoot_component.canAttack
	
					
func die() -> void:
	if demon_manager != null:
		demon_manager.clear_space(self.global_position)
	buffNodes.clearBuffs()
	queue_free()

func die_fromClearSpace() -> void:
	#print("DD YYYING ---------------------------------")
	buffNodes.clearBuffs()
	queue_free()		
	
	
func _on_mouse_entered() -> void:
	$PreviewNodes.visible = true 


func _on_mouse_exited() -> void:
	$PreviewNodes.visible = false 


func get_demon_icon()->CompressedTexture2D:
	return Global.crawler_icon
	
func get_special_description()->String:
	return Global.crawler_special_description
	
	
	
	
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
	


	
