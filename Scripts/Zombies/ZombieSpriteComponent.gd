extends AnimatedSprite
#ZombieSpriteComp

var is_attacking
var isSlow
onready var zombie = 	get_parent()
onready var attackComp = $"../AttackComponent"
onready var attack_audio_player = $"../AttackAudioPlayer"

func _process(_delta):
	is_attacking = attackComp.getAttackState()
	
	#print(zombie.name)
	isSlow = zombie.getCompManager().getSlow()
	#print("IsSlow is : ", isSlow)
	if isSlow > 0:
		if not is_attacking:
			self.play("WebWalk")
	else: #isSlow <= 0
		if not is_attacking:
			self.play("Walk")


func _on_AnimatedSprite_animation_finished():
	if("Attack" in self.animation):
		#attack_audio_player.play()
		pass
