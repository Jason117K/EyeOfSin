extends Node2D
#BuffNodes.gd

# All of the possible "blood tile" (buffed) visual effects 
#@onready var bloodTile1 := $BloodTile1
#@onready var bloodTile2 := $BloodTile2
#@onready var bloodTile3 := $BloodTile3
#@onready var bloodTile4 := $BloodTile4
#@onready var bloodTile5 := $BloodTile5
#@onready var bloodTile6 := $BloodTile6
#@onready var bloodTile7 := $BloodTile7
#@onready var bloodTile8 := $BloodTile8
#@onready var bloodTile9 := $BloodTile9

# Parent demon with these buffNodes
@onready var demon := get_parent()

enum Demons { OCCULUM,CRAWLER,SPINALOCCULUM,WYRM,HIVE, MAW, }

# The tile areas representing the area being buffed 
@export var activeTiles: Array = [ # (Array, NodePath)
	"TileArea1",
	"TileArea2",
	"TileArea3",
	"TileArea4",
	"TileArea5",
	"TileArea6",
	"TileArea7",
	"TileArea8"
]

# Which demon types (exact true names, see get_demon_true_name) this demon's
# zones buff. Heart/EmptyDemon are excluded by omission — their true name is "".
@export var give_buff_to: Array[StringName] = [&"Occulum", &"Crawler",
		&"SpinalOcculum", &"Wyrm", &"Hive", &"Maw"]

var buffedDemons: Array[Demon]

# Set by the owning demon after its post-spawn physics-frame awaits (overlap
# queries are invalid for the first frames); cleared again by clearBuffs.
var buff_ready := false

func _ready() -> void:
	# Make sure all the bloodTiles are not visible
	#bloodTile1.visible = false
	#bloodTile2.visible = false
	#bloodTile3.visible = false
	#bloodTile4.visible = false
	#bloodTile5.visible = false
	#bloodTile6.visible = false
	#bloodTile7.visible = false
	#bloodTile8.visible = false
	#bloodTile9.visible = false
	
	for child in get_children():
		if child is Area2D and "TileArea" in child.name:
			if demon.is_in_group(Dim.GREEN):
				child.set_collision_mask_value(Dim.LAYER_SHARED, false)
				child.set_collision_mask_value(Dim.LAYER_PURPLE_DEMONS, false)
				child.set_collision_mask_value(Dim.LAYER_GREEN_DEMONS, true)
				child.set_collision_mask_value(Dim.LAYER_GREEN_BUFF, true)
				child.set_collision_layer_value(Dim.LAYER_GREEN_BUFF, true)
			else:
				child.set_collision_mask_value(Dim.LAYER_SHARED, false)
				child.set_collision_mask_value(Dim.LAYER_PURPLE_DEMONS, true)
				child.set_collision_mask_value(Dim.LAYER_GREEN_DEMONS, false)
				child.set_collision_mask_value(Dim.LAYER_PURPLE_BUFF, true)
				child.set_collision_layer_value(Dim.LAYER_PURPLE_BUFF, true)

func clearBuffs() -> void:
	buff_ready = false
	#print("DDD Buffed Demons is ", buffedDemons)
	for this_demon in buffedDemons:
		#print("Now DDD DeBuffing ", this_demon)
		if is_instance_valid(this_demon):
			this_demon.debuff()
	
	
	
	
	
	
# Driven by Global._process (the per-frame conductor), ordered AFTER zombie
# ticks — this node has no _process of its own. can_process() preserves the
# old pause behavior (e.g. level scenes process-disabled behind the codex).
func tick_buff(_delta: float) -> void:
	if not buff_ready or not can_process():
		return

	# Go through all children of BuffNodes
	for child in get_children():
		
		#If a Child Isn't Visible, the Demon Cannot Buff There
		if not child.visible:
			continue
			
		# Check if the child is a TileArea (Area2D)
		if child is Area2D and "TileArea" in child.name:
			
			# Get the number from the TileArea name
			var area_number := child.name.replace("TileArea", "")

			# Look for overlapping areas
			var overlapping_areas :Array[Area2D]= child.get_overlapping_areas()

			# Find the corresponding BloodTile
			var blood_tile_name := "BloodTile" + area_number
			##print(blood_tile_name)
			var blood_tile := get_node_or_null(blood_tile_name)
			##print(blood_tile)
			#If we have a valid blood tile 
			#if blood_tile:
			if true:
				var bloodTileVisible := false
				var demon_detected := false 
				for potential_demon in overlapping_areas:
					if potential_demon.is_in_group("Demons"):
						##print(potential_demon)
						if potential_demon.is_in_group("Green") && demon.is_in_group("Green"):
							demon_detected = true 
						if potential_demon.is_in_group("Purple") && demon.is_in_group("Purple"):
							demon_detected = true
				#if demon_detected == false:
					#child.set_buff_active()
							
							
				# Check for demons in the overlapped areas
				for demonToBuff in overlapping_areas:
					##print("Demon buff is : ", demonToBuff)
					##print("Demon buff name is : ", demonToBuff.name)
					
					# If the demonToBuff is a valid demon & not a drone
					if(demonToBuff.is_in_group("Demons") && !("Drone" in demonToBuff.name)):      # &&   #demonToBuff.get_parent() ==   demon.get_parent()  ):
						if demonToBuff.is_in_group("Green"):
							if demon.is_in_group("Purple"):
								continue
						elif demonToBuff.is_in_group("Purple"):
							if demon.is_in_group("Green"):
								continue
						##print("Demon to Buff is ", demonToBuff.name)
						bloodTileVisible = true
						#Check our list of valid demons to buff
						if _should_buff(demonToBuff):
							if demonToBuff.isBuffed == false:
								child.set_buff_inactive()
								demonToBuff.receive_buff(demon)
							else:
								child.set_buff_inactive()

							if demonToBuff in buffedDemons:
								pass
							else:
								#print("DD Demon to Buff is ", demonToBuff)
								#print("Self DD Demon is ", demon)
								buffedDemons.append(demonToBuff)
							#blood_tile.visible = true
				#blood_tile.visible = bloodTileVisible


# Exact match on the demon's digit-stripped true name — kills the substring
# trap ("Occulum" was a substring of "SpinalOcculum3", so list ORDER used to
# matter). Demons without a true name (base returns "") never match.
func _should_buff(demonToBuff: Area2D) -> bool:
	var true_name := &""
	if demonToBuff.has_method("get_demon_true_name"):
		true_name = StringName(demonToBuff.get_demon_true_name())
	var buff_match := true_name in give_buff_to
	_check_legacy_match(demonToBuff, buff_match, true_name)
	return buff_match


# MIGRATION SAFETY NET — delete after one warning-free full playtest.
# Mirrors the old substring matching (`demonActor in demonToBuff.name`) and
# warns if the exact-name path decides differently.
const _LEGACY_GIVE_BUFF_TO : Array = ["Occulum","Crawler","SpinalOcculum","Wyrm","Hive","Maw"]

func _check_legacy_match(demonToBuff: Area2D, new_match: bool, true_name: StringName) -> void:
	var legacy_match := false
	for demon_actor: String in _LEGACY_GIVE_BUFF_TO:
		if demon_actor in demonToBuff.name:
			legacy_match = true
			break
	if legacy_match != new_match:
		push_warning("[BUFF-MIGRATION] exact-name=%s legacy-substring=%s for '%s' (true name '%s') in %s's zone"
				% [new_match, legacy_match, demonToBuff.name, true_name, demon.name])
