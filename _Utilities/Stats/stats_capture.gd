@tool
## Builds stat configs from zombie/demon scene roots. Shared by the capture
## EditorScripts (capture_unit_stats.gd, capture_stats_set.gd); uses no
## editor-only API.
class_name StatsCapture extends RefCounted

const ZOMBIE_BASE := "res://_Entities/Zombies/BaseZombie.gd"
const DEMON_BASE := "res://_Entities/Demons/demon_base.gd"

## Per-type stats classes: unit root script path -> stats script path.
const TYPE_STATS := {
	"res://_Entities/Demons/_Crawler/Crawler.gd": "res://_Utilities/Stats/Types/crawler_stats.gd",
	"res://_Entities/Demons/_Occulum/Occulum.gd": "res://_Utilities/Stats/Types/occulum_stats.gd",
	"res://_Entities/Demons/_Maw/Maw.gd": "res://_Utilities/Stats/Types/maw_stats.gd",
	"res://_Entities/Demons/_Hive/Hive.gd": "res://_Utilities/Stats/Types/hive_stats.gd",
	"res://_Entities/Demons/_Wyrm/Wyrm.gd": "res://_Utilities/Stats/Types/wyrm_stats.gd",
	"res://_Entities/Demons/_CagedOculum/SpinalOcculum.gd": "res://_Utilities/Stats/Types/spinal_occulum_stats.gd",
	"res://_Entities/Zombies/_BufferZombie/BufferZombie.gd": "res://_Utilities/Stats/Types/buffer_stats.gd",
	"res://_Entities/Zombies/_Erupter/TickerZombie.gd": "res://_Utilities/Stats/Types/erupter_stats.gd",
	"res://_Entities/Zombies/_Reanimator/DancerZombie.gd": "res://_Utilities/Stats/Types/reanimator_stats.gd",
	"res://_Entities/Zombies/_Tank/tank_zombie.gd": "res://_Utilities/Stats/Types/tank_stats.gd",
	"res://_Entities/Zombies/_Sundered/PoleVaultZombie.gd": "res://_Utilities/Stats/Types/sundered_stats.gd",
	"res://_Entities/Zombies/_Amalgam/ScreenDoorZombie.gd": "res://_Utilities/Stats/Types/amalgam_stats.gd",
	"res://_Entities/Zombies/_RangedZombie/ranged_zombie.gd": "res://_Utilities/Stats/Types/ranged_stats.gd",
	"res://_Entities/Zombies/_Act2Boss/act2_boss_zombie.gd": "res://_Utilities/Stats/Types/act2_boss_stats.gd",
	"res://_Entities/Zombies/_Act3Boss/argus_boss.gd": "res://_Utilities/Stats/Types/argus_stats.gd",
	"res://_Entities/Zombies/_RohanBossZombie/rohan_boss_zombie.gd": "res://_Utilities/Stats/Types/rohan_boss_stats.gd",
}


## A new, empty config of the right class for a unit root script, or null if
## the script is not a zombie or demon. Most-derived match wins, so per-type
## entries beat the zombie/demon base.
static func new_stats_for(script: Script) -> UnitStats:
	var s := script
	while s != null:
		if TYPE_STATS.has(s.resource_path):
			return load(TYPE_STATS[s.resource_path]).new()
		if s.resource_path == ZOMBIE_BASE:
			return ZombieStats.new()
		if s.resource_path == DEMON_BASE:
			return DemonStats.new()
		s = s.get_base_script()
	return null


## The unit's values as a new config, or null if root is not a zombie or demon.
## With include_slot, a config assigned to the unit's Stats slot is laid over
## the scene's values, so the result is what the unit actually uses.
static func capture(root: Node, include_slot: bool = false) -> UnitStats:
	if root.get_script() == null:
		return null
	var stats := new_stats_for(root.get_script())
	if stats == null:
		return null
	for stat in stats.get_stat_names():
		if stat in root:
			stats.set(stat, root.get(stat))
		else:
			push_warning("Capture stats: '%s' has no '%s'; kept the default." % [root.name, stat])
	var slot = root.get("stats")
	if include_slot and slot is UnitStats:
		for stat in slot.get_stat_names():
			if stat in stats:
				stats.set(stat, slot.get(stat))
		stats.notes = slot.notes
	return stats
