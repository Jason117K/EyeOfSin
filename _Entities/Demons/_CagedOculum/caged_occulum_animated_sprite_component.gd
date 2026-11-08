extends DemonSpriteComp

func _process(_delta: float) -> void:
	if animation == "spawn":
		return
	else:
		match demon.demon_buff_name:
			"Occulum":
				#print("Occulum")
				set_occulum_anim()
			"Crawler":
				#print("Crawler")
				set_crawler_anim()
			"Wyrm":
				#print("Wyrm")
				set_wyrm_anim()
			"Hive":
				#print("Hive")
				set_hive_anim()
			"Maw":
				#print("Maw")
				set_maw_anim()
			"None":
				set_default_anim()
			_:
				
				print("Demon Buff Name is ", demon.demon_buff_name)
				


func set_default_anim()->void:
	#print("Demon Health is ", demon.healthComp.health)
	if demon.healthComp.health > (demon.healthComp.maxHealth * 0.9):
		demon.animSpriteComp.animation = "idle"
	elif demon.healthComp.health < demon.healthComp.maxHealth && demon.healthComp.health > ((demon.healthComp.maxHealth/3)*2) :
		demon.animSpriteComp.animation = "idle_hurt_1"
	elif (demon.healthComp.health < ((demon.healthComp.maxHealth/3)*2)) && demon.healthComp.health > (demon.healthComp.maxHealth/3):
		demon.animSpriteComp.animation = "idle_hurt_2"
	else:
		demon.animSpriteComp.animation = "idle_hurt_3"
					


func set_crawler_anim()->void:
	#print("Demon Health is ", demon.healthComp.health)
	if demon.healthComp.health > (demon.healthComp.maxHealth * 0.9):
		demon.animSpriteComp.animation = "idle_Crawler"
	elif demon.healthComp.health < demon.healthComp.maxHealth && demon.healthComp.health > ((demon.healthComp.maxHealth/3)*2) :
		demon.animSpriteComp.animation = "idle_Crawler_hurt_1"
	elif (demon.healthComp.health < ((demon.healthComp.maxHealth/3)*2)) && demon.healthComp.health > (demon.healthComp.maxHealth/3):
		demon.animSpriteComp.animation = "idle_Crawler_hurt_2"
	else:
		demon.animSpriteComp.animation = "idle_Crawler_hurt_3"
		
func set_occulum_anim()->void:
	if demon.healthComp.health > (demon.healthComp.maxHealth * 0.9):
		demon.animSpriteComp.animation = "idle_Occulum"
	elif demon.healthComp.health < demon.maxHealth && demon.healthComp.health > ((demon.healthComp.maxHealth/3)*2) :
		demon.animSpriteComp.animation = "idle_Occulum_hurt_1"
	elif (demon.healthComp.health < ((demon.maxHealth/3)*2)) && demon.healthComp.health > (demon.healthComp.maxHealth/3):
		demon.animSpriteComp.animation = "idle_Occulum_hurt_2"
	else:
		demon.animSpriteComp.animation = "idle_Occulum_hurt_3"
				

func set_wyrm_anim()->void:
	if demon.healthComp.health > (demon.healthComp.maxHealth * 0.9):
		demon.animSpriteComp.animation = "idle_Wyrm"
	elif demon.healthComp.health < demon.healthComp.maxHealth && demon.healthComp.health > ((demon.healthComp.maxHealth/3)*2) :
		demon.animSpriteComp.animation = "idle_Wyrm_hurt_1"
	elif (demon.healthComp.health < ((demon.healthComp.maxHealth/3)*2)) && demon.healthComp.health > (demon.healthComp.maxHealth/3):
		demon.animSpriteComp.animation = "idle_Wyrm_hurt_2"
	else:
		demon.animSpriteComp.animation = "idle_Wyrm_hurt_3"
		
		
func set_hive_anim()->void:
	if demon.healthComp.health > (demon.healthComp.maxHealth * 0.9):
		demon.animSpriteComp.animation = "idle_Hive"
	elif demon.healthComp.health < demon.healthComp.maxHealth && demon.healthComp.health > ((demon.healthComp.maxHealth/3)*2) :
		demon.animSpriteComp.animation = "idle_Hive_hurt_1"
	elif (demon.healthComp.health < ((demon.healthComp.maxHealth/3)*2)) && demon.healthComp.health > (demon.healthComp.maxHealth/3):
		demon.animSpriteComp.animation = "idle_Hive_hurt_2"
	else:
		demon.animSpriteComp.animation = "idle_Hive_hurt_3"
		
		
		
func set_maw_anim()->void:
	if demon.healthComp.health > (demon.healthComp.maxHealth * 0.9):
		demon.animSpriteComp.animation = "idle_Maw"
	elif demon.healthComp.health < demon.healthComp.maxHealth && demon.healthComp.health > ((demon.healthComp.maxHealth/3)*2) :
		demon.animSpriteComp.animation = "idle_Maw_hurt_1"
	elif (demon.healthComp.health < ((demon.healthComp.maxHealth/3)*2)) && demon.healthComp.health > (demon.healthComp.maxHealth/3):
		demon.animSpriteComp.animation = "idle_Maw_hurt_2"
	else:
		demon.animSpriteComp.animation = "idle_Maw_hurt_3"		
		
		
		
		
		
		
		
		
		
				
