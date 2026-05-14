extends DemonHealthComponent

var blood_spawn_timer : Timer
var can_damage_zombie := false 
var canGenBlood := false
var thisBufferName : String

func take_damage(damage):
	super(damage)
	if isOcculumBuffed:
		if canGenBlood:
			generate_blood()

#Move to Generate Blood Component That Gets Added
func generate_blood():
	var blood_instance = demon.bloodScene.instantiate()
	#print("Spawn Blood")
	get_parent().add_child(blood_instance)  
	blood_instance.global_position = self.global_position + Vector2(0,-40)
	canGenBlood = false 
	
func _on_reset_blood_spawn_cooldown() -> void:
	canGenBlood = true 

	
func receiveBuff(bufferName):
	if !demon.get_is_buffed() :		
		if "Occulum" in bufferName.name && !isOcculumBuffed:
			canGenBlood = true
			health = buffedHealth
			maxHealth = buffedMaxHealth
			isOcculumBuffed = true 
			blood_spawn_timer = Timer.new()
			blood_spawn_timer.autostart = false 
			blood_spawn_timer.one_shot = false
			blood_spawn_timer.wait_time = blood_spawn_time
			blood_spawn_timer.timeout.connect(_on_reset_blood_spawn_cooldown)
			blood_spawn_timer.start()
		elif "Wyrm" in bufferName.name && !isWyrmBuffed:
			isWyrmBuffed = true 
			can_damage_zombie = true 
		elif "Maw" in bufferName.name && !isMawBuffed:
			healthRegen = buffedHealthRegen
			isMawBuffed = true 
			#TODO Re Implement Color Changes
			#$AnimatedSpriteComponent.change_color()
		thisBufferName = bufferName.name

func debuff():
	super() 

	
