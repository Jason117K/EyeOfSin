extends DemonHealthComponent

var maw_health := 500
var spinal_occulum_buffed_health := 500
var crawler_buffed_health := 500 
var wyrm_buffed_health := 500 
var hive_buffed_health := 500


func _ready() -> void:
	super()
	maw_health = demon.maw_health
	spinal_occulum_buffed_health = demon.spinal_occulum_buffed_health
	crawler_buffed_health = demon.crawler_buffed_health
	wyrm_buffed_health = demon.wyrm_buffed_health
	hive_buffed_health = demon.hive_buffed_health

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
			
