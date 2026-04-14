extends Zombie
# BasicZombie.gd

# Handles Any Basic Zombie Specific Logic 


#Kills the Zombie 
func die():
	if compManager.spawn_slow_field == true :
		spawn_slow_field_on_death()
	#if compMana
	#print("Should die")
	zombie_death.emit()
	$AnimatedSprite2D.isDead = true 
	$AnimatedSprite2D.play("death")
	#queue_free()


func kill_zombie():
	queue_free()
