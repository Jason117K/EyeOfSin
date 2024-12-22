extends AnimatedSprite
#ZombieSpriteComp

var is_attacking
var isSlow
var isInjured
onready var zombie = 	get_parent()
onready var attackComp = $"../AttackComponent"
onready var attack_audio_player = $"../AttackAudioPlayer"
onready var healthComp  =  $"../HealthComponent"
#Allow Summons While Webbed?
#Maybe Give Zombies With Special Animations Own Sprite Comp Controller

func _process(_delta):
	is_attacking = attackComp.getAttackState()
	isInjured = healthComp.getInjured()
	
	#print(zombie.name)
	isSlow = zombie.getCompManager().getSlow()
	#print("IsSlow is : ", isSlow)
	
	
	#Slow Webbed Block
	#--------------------------------------------------------------------------
	if isSlow > 0:

		#Dancer Specific 
		if(zombie.name == "DancerZombie"):
			if(self.animation == "Summon"):
				pass
			else:
				if(not is_attacking):
					self.play("WebWalk")     

		if isInjured: #Injured and Webbed 
			if not is_attacking:
				self.play("WebWalk")    #InjuredWebWalk
			else:
				self.play("Attack")  #InjuredWebAttack
		else: #Not Injured, Are Webbed
			if not is_attacking:
				self.play("WebWalk")
			else:
				self.play("Attack") #WebAttack
	#--------------------------------------------------------------------------
		
	#Not Slow Block
	else: #isSlow <= 0

		#Dancer Specific 
		if(zombie.name == "DancerZombie"):
			if(self.animation == "Summon"):
				pass
			else:
				if(not is_attacking):
					self.play("Walk")

		if isInjured: #Injured and NOT Webbed 
			if not is_attacking:
				self.play("Walk") #InjuredWalk
			else:
				self.play("Attack") #InjuredAttack
		else: #Not Injured, NOT Webbed
			if not is_attacking:
				self.play("Walk")
			else:
				self.play("Attack")


func _on_AnimatedSprite_animation_finished():
	if("Attack" in self.animation):
		#attack_audio_player.play()
		pass
