extends Node2D
#BuffNodes.gd


onready var bloodTile1 = $BloodTile1
onready var bloodTile2 = $BloodTile2
onready var bloodTile3 = $BloodTile3
onready var bloodTile4 = $BloodTile4
onready var bloodTile5 = $BloodTile5
onready var bloodTile6 = $BloodTile6
onready var bloodTile7 = $BloodTile7
onready var bloodTile8 = $BloodTile8

onready var plant = get_parent()

export(Array, NodePath) var activeTiles = [
	"TileArea1",
	"TileArea2",
	"TileArea3",
	"TileArea4",
	"TileArea5",
	"TileArea6",
	"TileArea7",
	"TileArea8"
]

export var giveBuffTo = ["None","None","None","None","None","None","None","None"]


func _ready():
	
	bloodTile1.visible = false
	bloodTile2.visible = false
	bloodTile3.visible = false
	bloodTile4.visible = false
	bloodTile5.visible = false
	bloodTile6.visible = false
	bloodTile7.visible = false
	bloodTile8.visible = false


func _process(_delta):
	
	# Go through all children of BuffNodes
	for child in get_children():
		
		#If a Child Isn't Visible, the Plant Cannot Buff There
		if not child.visible:
			continue
			
		# Check if the child is a TileArea (Area2D)
		if child is Area2D and "TileArea" in child.name:
			
			# Get the number from the TileArea name
			var area_number = child.name.replace("TileArea", "")
			
			# Look for overlapping areas
			var overlapping_areas = child.get_overlapping_areas()
			
			# Find the corresponding BloodTile
			var blood_tile_name = "BloodTile" + area_number
			var blood_tile = get_node_or_null(blood_tile_name)
			
			#If we have a valid blood tile 
			if blood_tile:
				
				# Check for plants in the overlapped areas
				for plantToBuff in overlapping_areas:
					
					# If the plantToBuff is a valid plant 
					if(plantToBuff.is_in_group("Plants") && !("Drone" in plantToBuff.name)):
						print("Plant to Buff is ", plantToBuff.name)
						
						#Check our list of valid plants to buff
						for plantActor in giveBuffTo:
							
							var selfPlantName = ""
							var buffPlantName = ""
							selfPlantName = plant.name
							buffPlantName = plantActor
							
									
							#Handle Rest of Buffs
							if plantActor in plantToBuff.name:
								#plantToBuff.receiveBuff(plant.name)
								plantToBuff.receiveBuff(plant)
								blood_tile.visible = true
								break










