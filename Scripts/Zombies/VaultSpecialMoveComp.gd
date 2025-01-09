extends Node2D
#VaultSpecialMoveComp.gd

onready var animatedSprite = $"../AnimatedSprite"  # Reference to animated Sprite
onready var speedComp = $"../SpeedComponent"
onready var parent = get_parent()

onready var tween = Tween.new()  # Create new Tween node

var move_duration = 3.3  # Duration of the vault movement in seconds
var vault_distance = -150  # Distance to move left (negative for leftward movement)
var moveDone = false

func _ready():
	# Add Tween as child of this node
	add_child(tween)

func executeMove():
	animatedSprite.animation = "Vault"
	speedComp.setSpeed(0)
	
	# Create and configure timer
	var vaultTimer = Timer.new()
	add_child(vaultTimer)
	vaultTimer.wait_time = move_duration
	vaultTimer.one_shot = true
	vaultTimer.connect("timeout", self, "_on_vault_timer_timeout")
	
	# Start the tween movement
	var start_pos = parent.position
	var end_pos = start_pos + Vector2(vault_distance, 0)
	
	tween.interpolate_property(
		parent,
		"position",
		start_pos,
		end_pos,
		move_duration,
		Tween.TRANS_LINEAR,
		Tween.EASE_IN_OUT
	)
	
	# Start both timer and tween
	vaultTimer.start()
	tween.start()

func _on_vault_timer_timeout():
	# Stop the tween if it's still running
	if tween.is_active():
		tween.stop_all()
	
	# Clean up the timer
	var timer = get_node("Timer")
	if timer:
		timer.queue_free()
	
	moveFinished()

func moveFinished():
	animatedSprite.setSpecialMoveFalse()
	speedComp.setSpeed(26)
	moveDone = true
	
func isMoveFinished():
	return moveDone
