extends Area2D


func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("Zombie"):
		print("Swap Portal Area Entered")
		if area.is_in_group("HasTeleported"):
			pass
		else:
			if self.is_in_group("Purple") && area.is_in_group("Purple"):
				print("SWAP ZOMBIE DIMENSION PURPLE->GREEN")
				area.add_to_group("HasTeleported")
				area.change_dimensions()
				
			elif self.is_in_group("Green") && area.is_in_group("Green"):
				print("SWAP ZOMBIE DIMENSION GREEN->PURPLE")
				area.add_to_group("HasTeleported")
				area.change_dimensions()


func _on_area_exited(area: Area2D) -> void:
	pass # Replace with function body.
