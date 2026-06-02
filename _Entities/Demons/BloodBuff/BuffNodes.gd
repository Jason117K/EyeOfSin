extends Node2D
#BuffNodes.gd

# All of the possible "blood tile" (buffed) visual effects 
@onready var bloodTile1 := $BloodTile1
@onready var bloodTile2 := $BloodTile2
@onready var bloodTile3 := $BloodTile3
@onready var bloodTile4 := $BloodTile4
@onready var bloodTile5 := $BloodTile5
@onready var bloodTile6 := $BloodTile6
@onready var bloodTile7 := $BloodTile7
@onready var bloodTile8 := $BloodTile8
@onready var bloodTile9 := $BloodTile9

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

# Adjustable variable to store which demons this demon can buff
var giveBuffTo: Array = ["Occulum","Crawler","SpinalOcculum","Wyrm","Hive","Maw","None","None"]

var buffedDemons: Array = []

func _ready() -> void:
	# Make sure all the bloodTiles are not visible
	bloodTile1.visible = false
	bloodTile2.visible = false
	bloodTile3.visible = false
	bloodTile4.visible = false
	bloodTile5.visible = false
	bloodTile6.visible = false
	bloodTile7.visible = false
	bloodTile8.visible = false
	bloodTile9.visible = false
	
	for child in get_children():
		if child is Area2D and "TileArea" in child.name:
			if demon.is_in_group("Green"):
				child.set_collision_mask_value(1,false)
				child.set_collision_mask_value(2,false)
				child.set_collision_mask_value(3,true)
			else:
				child.set_collision_mask_value(1,false)
				child.set_collision_mask_value(2,true)
				child.set_collision_mask_value(3,false)

func clearBuffs() -> void:
	#print("DDD Buffed Demons is ", buffedDemons)
	for this_demon in buffedDemons:
		#print("Now DDD Buffing ", demon)
		if this_demon != null:
			pass
			#demon.debuff()
	pass
	
	
	
	
	
	
func _process(_delta: float) -> void:
	pass
	
	#print("I Am ", get_parent().name)
	
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
			var blood_tile := get_node_or_null(blood_tile_name)
			
			#If we have a valid blood tile 
			if blood_tile:
				
				var bloodTileVisible := false
				
				# Check for demons in the overlapped areas
				for demonToBuff in overlapping_areas:
					#print("Demon buff is : ", demonToBuff)
					#print("Demon buff name is : ", demonToBuff.name)
					
					# If the demonToBuff is a valid demon & not a drone
					if(demonToBuff.is_in_group("Demons") && !("Drone" in demonToBuff.name)):      # &&   #demonToBuff.get_parent() ==   demon.get_parent()  ):
						if demonToBuff.is_in_group("Green"):
							if demon.is_in_group("Purple"):
								continue
						elif demonToBuff.is_in_group("Purple"):
							if demon.is_in_group("Green"):
								continue
						#print("Demon to Buff is ", demonToBuff.name)
						bloodTileVisible = true 
						#Check our list of valid demons to buff
						#print("Demon buff name is : ", demonToBuff.name)
						for demonActor:String in giveBuffTo:
							#print("Demon Actor is ",demonActor )
							
									
							#Handle Rest of Buffs
							if demonActor in demonToBuff.name:
								#Handle Special Wyrm Buff Case, as both demons 'receive' a buff
								#TODO Are We Keeping This?
								if ( "SpinalOcculum" in demonToBuff.name) && ("Wyrm" in demon.name):
									#print("ZZZ Special Buff Case")
									#demon.receive_buff(demonToBuff)
									pass
								#print("Demon to buff : ", demonToBuff.name , " will now receive buff from ", demon.name)
								demonToBuff.receive_buff(demon)
								if demonToBuff in buffedDemons:
									pass
								else:
									buffedDemons.append(demonToBuff)
								#blood_tile.visible = true
								break
				#blood_tile.visible = bloodTileVisible
