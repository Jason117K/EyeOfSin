extends Node2D
#BuffNodes.gd

# All of the possible "blood tile" (buffed) visual effects 
@onready var bloodTile1 = $BloodTile1
@onready var bloodTile2 = $BloodTile2
@onready var bloodTile3 = $BloodTile3
@onready var bloodTile4 = $BloodTile4
@onready var bloodTile5 = $BloodTile5
@onready var bloodTile6 = $BloodTile6
@onready var bloodTile7 = $BloodTile7
@onready var bloodTile8 = $BloodTile8
@onready var bloodTile9 = $BloodTile9

# Parent plant with these buffNodes
@onready var plant = get_parent()

# The tile areas representing the area being buffed 
@export var activeTiles = [ # (Array, NodePath)
	"TileArea1",
	"TileArea2",
	"TileArea3",
	"TileArea4",
	"TileArea5",
	"TileArea6",
	"TileArea7",
	"TileArea8"
]

# Adjustable variable to store which plants this plant can buff
@export var giveBuffTo = ["None","None","None","None","None","None","None","None"]


func _ready():
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
					#print("Plant buff is : ", plantToBuff)
					#print("Plant buff name is : ", plantToBuff.name)
					
					# If the plantToBuff is a valid plant & not a drone
					if(         plantToBuff.is_in_group("Plants") &&    !("Drone" in plantToBuff.name)    ):
						#print("Plant to Buff is ", plantToBuff.name)
						
						#Check our list of valid plants to buff
						for plantActor in giveBuffTo:

							
									
							#Handle Rest of Buffs
							if plantActor in plantToBuff.name:
								#Handle Special EggWorm Buff Case, as both plants 'receive' a buff
								if (plantToBuff.name == "WalnutTree") && ("EggWorm" in plant.name):
									plant.receiveBuff(plantToBuff)
								print("Plant to buff : ", plantToBuff.name , " will now receive buff from ", plant.name)
								plantToBuff.receiveBuff(plant)
								blood_tile.visible = true
								break
