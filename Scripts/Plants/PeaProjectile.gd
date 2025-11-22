extends Area2D
#PeaProjectile.gd


@export var speed = 300  # Speed of the projectile
@export var damage = 20 #2   # Damage dealt to zombies
@export var lightning_damage = 10 #2   # Damage dealt to zombies

var walnutBuff := false 
var sunBuff := false 
var wyrmBuff := false

func _ready() -> void:
	if wyrmBuff:
		$LightningZone.visible = true 
		$LightningZone.monitoring = true 
		$AnimatedSprite2D.visible = true 

func _process(delta):
	if wyrmBuff:
		$LightningZone.visible = true 
		$LightningZone.monitoring = true 
		$AnimatedSprite2D.visible = true 
		$LightningZone/CollisionShape2D.disabled = false
	position.x += speed * delta  # Move the projectile to the right

	# Remove the projectile if it goes off-screen
	if position.x > get_viewport_rect().size.x:
		queue_free()  # Remove projectile if off-screen


# Handles projectile collison and damage application 
func _on_PeaProjectile_area_entered(area):

	if area.is_in_group("Zombie"):
		if area.get_parent().get_parent() != self.get_parent().get_parent():
			return
		var compManager = area.getCompManager()
		var healthComp = compManager.getHealthComponent()
		compManager.slow()
		compManager.take_damage(damage)  # Call take_damage() on the zombie
		if walnutBuff:
			compManager.knockBack()
		if sunBuff:
			compManager.increaseBloodWorth()
		queue_free()  # Remove the projectile # Replace with function body.


func _on_lightning_zone_area_entered(area: Area2D) -> void:
	if area.is_in_group("Zombie"):
		print(area, " is INDEED in Zombie Group")
		if area.get_parent().get_parent() != self.get_parent().get_parent():
			print("Early Return Rr")
			return
		var compManager = area.getCompManager()
		var healthComp = compManager.getHealthComponent()
		compManager.slow()
		compManager.take_damage(lightning_damage)  # Call take_damage() on the zombie
	else:
		print(area, " is not in Zombie Group")
