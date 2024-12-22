extends Node2D

func _process(_delta):
	# Go through all children of BuffNodes
	for child in get_children():
		# Check if the child is a TileArea (Area2D)
		if child is Area2D and "TileArea" in child.name:
			# Get the number from the TileArea name
			var area_number = child.name.replace("TileArea", "")
			
			# Look for overlapping areas
			var overlapping_areas = child.get_overlapping_areas()
			
			# Find the corresponding BloodTile
			var blood_tile_name = "BloodTile" + area_number
			var blood_tile = get_node_or_null(blood_tile_name)
			
			if blood_tile:
				#print("Blood tile is ", blood_tile)
				# Default to invisible
				blood_tile.visible = false
				
				# Check all overlapping areas
				for area in overlapping_areas:
					
					# If any overlapping area has "Pea" in its name, make BloodTile visible
					if(area.is_in_group("Plants")):
						print(area.name + " is Overlapping")
					#if "Pea" in area.name:
						blood_tile.visible = true
						break
