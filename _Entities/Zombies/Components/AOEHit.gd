extends Node2D
#AOEHit.gd

# Handles playing the Ticker zombie explode animation and damaging all the 
# towers caught in it 

# References to the Animation & the Hitbox 
@onready var hit1 := $Hit2
@onready var hit2 := $Hit3
@onready var hit3 := $Hit4
@onready var hitBoxComp := $HitBoxComponent
@onready var erupter_zombie_parent := get_parent()

# Adjustable Explosion Damage
@export var attack_power := 1000

var silenced := false


# Play the Animation and Make it Visible
func goBoom() -> void:

	##print("TickerRRRRRRR going boom ")
	if get_parent().is_in_group("Green"):
		hitBoxComp.set_collision_mask_value(1,false)
		hitBoxComp.set_collision_mask_value(2,false)
		hitBoxComp.set_collision_mask_value(3,true)
	else:
		hitBoxComp.set_collision_mask_value(1,false)
		hitBoxComp.set_collision_mask_value(2,true)
		hitBoxComp.set_collision_mask_value(3,false)
		
	if silenced:
		hide()
	else:
		show()

	hit1.play()
	hit2.play()
	hit3.play()
	AudioManager.create_2d_audio_at_location(self.global_position, SoundEffect.SOUND_EFFECT_TYPE.TICKER_BOOM)
	

# When the last animation is finished, damage all towers caught in the area
func _on_Hit3_animation_finished() -> void:
	if silenced:
		erupter_zombie_parent.die()
	##print("Ticker DEF About Die")
	# Make the animation invisible & stop it
	self.visible = false
	#hit1.stop()
	#hit2.stop()
	#hit3.stop()
	
	# Get the Towers to Damage
	var areasToDamage :Array= hitBoxComp.get_overlapping_areas()
	
	# Damage all the Towers & Then Kill the Parent/Ticker Zombie 
	for area:Area2D in areasToDamage:
		#print("This area is ", area.name)
		if(is_instance_valid(area)):
			if area.is_in_group("Demons"):
				#print("About to bomb ", area.name)
				#print("AP IS ", attack_power)
				if(area.get_health() >= 0):
					area.take_damage(attack_power)
				else:
					pass
			else:
				pass
	var parent := get_parent()
	parent.die()
	##print("TTicker Should Die")

func silence() -> void:
	attack_power = 0
	silenced = true
