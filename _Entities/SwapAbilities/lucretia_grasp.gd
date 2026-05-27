extends SwapAbility


@onready var grasp_container := $AllGrasp


func apply_swap_ability()->void:
	pass


#func undo_swap_ability() -> void:
	#if is_active:
		#for zombie : Zombie in Global.get_all_zombies():
			#if zombie != null:
				#zombie.undoBloodSlow()
		#stop()	
	

	
