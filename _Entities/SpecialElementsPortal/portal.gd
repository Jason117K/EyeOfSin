extends Area2D

@onready var animSprite := $PortalAnimSprite

#Make Place Other Portal
func _ready() -> void:
	if self.is_in_group("Green"):
		Global.register_green_portal(self)
		self.set_collision_mask_value(5,true)
		animSprite.animation = "Purple"
	elif self.is_in_group("Purple"):
		Global.register_purple_portal(self)
		self.set_collision_mask_value(4,true)
		animSprite.animation = "Green"
		
 

func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("Zombie"):
		print("Swap Portal Area Entered")
		if area.is_in_group("HasTeleported"):
			pass
		else:
			if self.is_in_group("EntrancePortal"):
				if self.is_in_group("Purple") && area.is_in_group("Purple"):
					print("SWAP ZOMBIE DIMENSION PURPLE->GREEN")
					area.add_to_group("HasTeleported")
					area.change_dimensions(Global.get_green_portal_location())
					
				elif self.is_in_group("Green") && area.is_in_group("Green"):
					print("SWAP ZOMBIE DIMENSION GREEN->PURPLE")
					area.add_to_group("HasTeleported")
					area.change_dimensions(Global.get_purple_portal_location())


func _on_area_exited(_area: Area2D) -> void:
	pass # Replace with function body.

func get_cost() -> int:
	return 0


func _on_lightning_spawn_animation_finished() -> void:
	$LightningSpawn.hide()


func finish_spawn() -> void:
	pass
