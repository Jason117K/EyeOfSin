extends Node2D
#AOEHit.gd

onready var hit1 = $Hit2
onready var hit2 = $Hit3
onready var hit3 = $Hit4
onready var hitBoxComp = $"../HitBoxComponent"

export var attack_power = 1000

func goBoom():
	hit1.play()
	hit2.play()
	hit3.play()
	self.visible = true 
	

func _on_Hit3_animation_finished():
	self.visible = false 
	hit1.stop()
	hit2.stop()
	hit3.stop()
	var areasToDamage = hitBoxComp.get_overlapping_areas()
	
	for area in areasToDamage:
		print("This area is ", area.name)
		if(is_instance_valid(area)):
			if area.is_in_group("Plants"):
				print("About to bomb ", area.name)
				if(area.health >= 0):
					area.take_damage(attack_power)
				else:
					pass
			else:
				pass
	var parent = get_parent()
	parent.die()
	

	

