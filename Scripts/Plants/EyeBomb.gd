extends Node2D


onready var spriteComp = $SpriteComponent
onready var hitBoxComp = $HitBoxComponent

var startNum = 0
var damage = 10
var enemiesToHit

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_DetectionComponent_area_entered(area):
	if "Zombie" in area.name:
		if(startNum == 0):
			print("Boom Time")
			spriteComp.animation = "boom"
			enemiesToHit = hitBoxComp.get_overlapping_areas()
			
			startNum = startNum + 1

func _on_SpriteComponent_animation_finished():
	if(spriteComp.animation == "default"):
		pass
	else:
		print("done")
		for enemy in enemiesToHit:
			if(enemy != null):
				if enemy.has_method("take_damage"):
					enemy.take_damage(damage)
		queue_free()
