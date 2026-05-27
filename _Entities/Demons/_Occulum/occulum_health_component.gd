extends DemonHealthComponent

@export var maw_health := 500
@export var spinal_occulum_buffed_health := 500
@export var crawler_buffed_health := 500 
@export var wyrm_buffed_health := 500 
@export var hive_buffed_health := 500


func _ready() -> void:
	super()
	maw_health = demon.maw_health

func receive_buff(demonName: String) -> void:
	#print("Buff Name is ", newDemon.name)

	match demonName:
		"Maw" :
			health = maw_health
			maxHealth = maw_health
		"SpinalOcculum":
			health = spinal_occulum_buffed_health
			maxHealth = spinal_occulum_buffed_health
		"Hive":
			health = hive_buffed_health
			maxHealth = hive_buffed_health
		"Wyrm":
			health = wyrm_buffed_health
			maxHealth = wyrm_buffed_health
		"Crawler":
			health = crawler_buffed_health
			maxHealth = crawler_buffed_health
			
