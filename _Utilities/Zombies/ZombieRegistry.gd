class_name ZombieRegistry

const SCENES: Dictionary = {
	"Reborn": preload("res://_Entities/Zombies/_RebornZombie/BasicZombie.tscn"),
	"Severed": preload("res://_Entities/Zombies/_Severed/ConeHeadZombie.tscn"),
	"Unhallower": preload("res://_Entities/Zombies/_Unhallower/BucketHeadZombie.tscn"),
	"Amalgam": preload("res://_Entities/Zombies/_Amalgam/ScreenDoorZombie.tscn"),
	"Reanimator": preload("res://_Entities/Zombies/_Reanimator/DancerZombie.tscn"),
	"Sundered": preload("res://_Entities/Zombies/_Sundered/PoleVaultZombie.tscn"),
	"Erupter": preload("res://_Entities/Zombies/_Erupter/TickerZombie.tscn"),
	"Flesheater": preload("res://_Entities/Zombies/_Flesheater/FootballZombie.tscn"),
	"Rohan": preload("res://_Entities/Zombies/_RohanBossZombie/RohanBossZombie.tscn"),
	"Buffer": preload("res://_Entities/Zombies/_BufferZombie/BufferZombie.tscn"),
	"Tank" : preload("res://_Entities/Zombies/_Tank/TankZombie.tscn"),
	"Minion" : preload("res://_Entities/Zombies/_MinionZombie/MinionZombie.tscn"),
	"Ranged" : preload("res://_Entities/Zombies/_RangedZombie/RangedZombie.tscn"),
	"Act2Boss" : preload("res://_Entities/Zombies/_Act2Boss/Act_2_Boss_Zombie.tscn"),
	"Argus" : preload("res://_Entities/Zombies/_Act3Boss/Act_3_Boss_Zombie.tscn")
}

## Per-type threat weighting; a wave's danger score is the count-weighted sum.
const DANGER_SCORES: Dictionary = {
	"Reborn": 2,
	"Severed": 5,
	"Unhallower": 50,
	"Amalgam": 25,
	"Reanimator": 100,
	"Sundered": 25,
	"Erupter": 50,
	"Flesheater": 150,
	"Rohan": 1000,
	"Buffer": 50,
	"Tank":400,
	"Minion":5,
	"Ranged": 100,
	"Act2Boss": 1000,
	"Argus": 1000,
}

const Y_OFFSETS: Dictionary = {
	"Erupter": -3,
	"Flesheater": -2,
	"Amalgam": -2,
	"Unhallower": 0,
	
}
