extends AnimatedSprite2D

@onready var preview_area := $PreviewArea


var is_purple := false 

func _ready() -> void:
	pass
	#print(self, " PREVIEW SPRITE IS READYYY")

func set_collision()->void:
	if Global.game_controller.on_purple_scene():
		is_purple = true
	if preview_area != null:
		if !is_purple:
			preview_area.set_collision_mask_value(1,false)
			preview_area.set_collision_mask_value(2,false)
			#preview_area.set_collision_mask_value(3,true)
			preview_area.set_collision_mask_value(13,true)

		else:
			preview_area.set_collision_mask_value(1,false)
			#preview_area.set_collision_mask_value(2,true)
			preview_area.set_collision_mask_value(3,false)
			preview_area.set_collision_mask_value(12,true)

func get_overlapping_demon_areas()->Array:
	var overlapping_areas : Array = []
	for demon_tile_area in preview_area.get_overlapping_areas():
		if demon_tile_area.is_in_group("BloodTile") && demon_tile_area.visible == true:
			overlapping_areas.append(demon_tile_area)
	return overlapping_areas

		
		

func receive_buff(new_form : String) -> void:
	match new_form:
		"Occulum":
			animation = "idle_Occulum"

		"Crawler":
			animation = "idle_Crawler"

		"SpinalOcculum" :
			animation = "idle_SpinalOcculum"

		"Wyrm":
			animation = "idle_Wyrm"
			
		"Hive":
			animation = "idle_Hive"

		"Maw":
			animation = "idle_Maw"

			
