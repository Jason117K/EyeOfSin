extends AnimatedSprite


var is_attacking
onready var attackComp = $"../AttackComponent"
# Called when the node enters the scene tree for the first time.
func _ready():
	pass


func _process(_delta):
	is_attacking = attackComp.getAttackState()
	if not is_attacking:
		self.play("default")


func _on_AnimatedSprite_animation_finished():
	if("Attack" in self.animation):
		$"../AttackAudioPlayer".play()
