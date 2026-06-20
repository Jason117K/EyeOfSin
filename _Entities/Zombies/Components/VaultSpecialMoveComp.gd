extends Node2D
#VaultSpecialMoveComp.gd

@onready var animatedSprite := $"../AnimatedSprite2D"  # RefCounted to animated Sprite2D
#@onready var speedComp := $"../SpeedComponent"       # RefCounted to speed component
@onready var parent :Zombie= get_parent()                  # RefCounted to parent
@onready var attack_comp :ZombieAttackRefCountedComponent   #= parent.get_attack_comp()# $"../AttackComponent"

var pre_special_speed
var vaultTimer: Timer
#@onready var tween = Tween.new()  # Create new Tween node
var tween : Tween
var move_duration := 3.3  # Duration of the vault movement in seconds
var vault_distance := -110  # Distance to move left (negative for leftward movement)
var moveDone := false

func _ready() -> void:
	# Add Tween as child of this node
	tween = create_tween()
	tween.stop()


# Perform the pole vault 
func executeMove(old_speed : float) -> void:
	pre_special_speed = old_speed
	animatedSprite.animation = "Vault"
	parent.setSpeed(0)

	vaultTimer = Timer.new()
	add_child(vaultTimer)
	vaultTimer.wait_time = move_duration
	vaultTimer.one_shot = true
	vaultTimer.connect("timeout", Callable(self, "_on_vault_timer_timeout"))

	var start_pos :Vector2= parent.position
	var end_pos :Vector2= start_pos + Vector2(vault_distance, 0)

	var tweener : PropertyTweener = tween.tween_property(parent, "position", end_pos, move_duration)
	if tweener:  # Check if tween was created successfully
		tweener.set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)
	else:
		print("Tween failed! Check parent/end_pos.")	
	#tween.tween_property(
		#parent,
		#"position",
		#end_pos,
		#move_duration).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)
	
	# Start both timer and tween
	vaultTimer.start()
	#tween.start()
	tween.play()

# Stop the tween and delete the timer 
func _on_vault_timer_timeout() -> void:
	# Stop the tween if it's still running
	if tween and tween.is_running():
		tween.stop()
	
	# Clean up the timer

	if vaultTimer:
		vaultTimer.queue_free()
	
	moveFinished()

# Make it so the polevaulter cannot vault again and starts walking normally 
func moveFinished() -> void:
	animatedSprite.setSpecialMoveFalse()
	parent.setSpeed(pre_special_speed)
	attack_comp.stop_attack()
	moveDone = true

func silence() -> void:
	animatedSprite.setSpecialMoveFalse()
	parent.setSpeed(26)
	moveDone = true
	#TODO Add Ability to Recover From Being Silenced?

# Informs whether or not the move was performed 
func isMoveFinished() -> bool:
	return moveDone
