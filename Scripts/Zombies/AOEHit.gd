extends Node2D
#AOEHit.gd

# Handles playing the Ticker zombie explode animation and damaging all the 
# towers caught in it 

# References to the Animation & the Hitbox 
@onready var hit1 = $Hit2
@onready var hit2 = $Hit3
@onready var hit3 = $Hit4
@onready var hitBoxComp = $"../HitBoxComponent"

# Adjustable Explosion Damage
@export var attack_power = 1000

# Play the Animation and Make it Visible 
func goBoom():
	print("TickerRRRRRRR going boom ")
	hit1.play()
	hit2.play()
	hit3.play()
	self.visible = true 
	

# When the last animation is finished, damage all towers caught in the area
func _on_Hit3_animation_finished():
	print("Ticker DEF About Die")
	# Make the animation invisible & stop it 
	self.visible = false 
	hit1.stop()
	hit2.stop()
	hit3.stop()
	
	# Get the Towers to Damage
	var areasToDamage = hitBoxComp.get_overlapping_areas()
	
	# Damage all the Towers & Then Kill the Parent/Ticker Zombie 
	for area in areasToDamage:
		#print("This area is ", area.name)
		if(is_instance_valid(area)):
			if area.is_in_group("Plants"):
				#print("About to bomb ", area.name)
				if(area.health >= 0):
					area.take_damage(attack_power)
				else:
					pass
			else:
				pass
	var parent = get_parent()
	parent.die()
	print("TTicker Should Die")
	

	
