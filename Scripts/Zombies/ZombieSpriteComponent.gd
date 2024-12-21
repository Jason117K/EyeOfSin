extends AnimatedSprite


var is_attacking
var isSlow
onready var zombie = 	get_parent()
onready var attackComp = $"../AttackComponent"
# Called when the node enters the scene tree for the first time.
func _ready():
	pass


func _process(_delta):
	is_attacking = attackComp.getAttackState()
	isSlow = zombie.getSlow()
	print("IsSlow is : ", isSlow)
	if isSlow > 0:
		if not is_attacking:
			self.play("WebWalk")
	else: #isSlow <= 0
		if not is_attacking:
			self.play("Walk")


func _on_AnimatedSprite_animation_finished():
	if("Attack" in self.animation):
		$"../AttackAudioPlayer".play()
