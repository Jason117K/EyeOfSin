extends Area2D

@onready var death_zone_area := $DeathZoneArea
@onready var detect_zombie_area1 := $DetectZombieArea1
@onready var detect_zombie_area2 := $DetectZombieArea2
@onready var detect_zombie_area3 := $DetectZombieArea3
@onready var detect_zombie_area4 := $DetectZombieArea4
@onready var detect_zombie_area5 = $DetectZombieArea5
@onready var detect_zombie_area6 := $DetectZombieArea6

@onready var all_areas := [death_zone_area,detect_zombie_area1,detect_zombie_area2,detect_zombie_area3, \
							detect_zombie_area4, detect_zombie_area5, detect_zombie_area6]

@onready var all_detection_areas := [detect_zombie_area1,detect_zombie_area2,detect_zombie_area3, \
							detect_zombie_area4, detect_zombie_area5, detect_zombie_area6]
														
@onready var zombie_hiding_rect := $ShouldHideZombies

@onready var pull_from_below_animation : AnimatedSprite2D = $DeathZoneArea/PullFromBelowAnim

var zombie_count_area_1 := 0
var zombie_count_area_2 := 0
var zombie_count_area_3 := 0
var zombie_count_area_4 := 0
var zombie_count_area_5 := 0
var zombie_count_area_6 := 0
var zombie_counts := [0, 0, 0, 0, 0, 0]
var highest_index := 0

var zombies_to_kill := []

signal done_eating

func _ready() -> void:
	set_all_areas()

	
func set_all_areas():
	for area in all_areas:
		if self.is_in_group("Green"):
			area.set_collision_mask_value(1,false)
			area.set_collision_mask_value(2,false)
			area.set_collision_mask_value(3,false)
			area.set_collision_mask_value(4,false)
			area.set_collision_mask_value(5,true)
		else:
			area.set_collision_mask_value(1,false)
			area.set_collision_mask_value(2,false)
			area.set_collision_mask_value(3,false)
			area.set_collision_mask_value(4,true)


func get_highest_zombie_concentration_and_eat():
	print("Should Devour NOW")
	set_all_areas()
	zombie_counts = [0, 0, 0, 0, 0, 0]

	for i in all_detection_areas.size():
		for area in all_detection_areas[i].get_overlapping_areas():
			if area.is_in_group("Zombie"):
				zombie_counts[i] += 1

	zombie_count_area_1 = zombie_counts[0]
	zombie_count_area_2 = zombie_counts[1]
	zombie_count_area_3 = zombie_counts[2]
	zombie_count_area_4 = zombie_counts[3]
	zombie_count_area_5 = zombie_counts[4]
	zombie_count_area_6 = zombie_counts[5]

	highest_index = 0
	
	for i in zombie_counts.size():
		if zombie_counts[i] > zombie_counts[highest_index]:
			highest_index = i

	if zombie_counts[highest_index] > 0:
		#death_zone_area.global_position = all_detection_areas[highest_index].global_position 
		death_zone_area.position = all_detection_areas[highest_index].position 
		pull_from_below()
	else:
		print("Emiting Done Eat Early So Devour Sooner")
		done_eating.emit()
		
		
		
func pull_from_below():
	pull_from_below_animation.show()
	pull_from_below_animation.play()

	for area in death_zone_area.get_overlapping_areas():
		if area.is_in_group("Zombie"):
			print("Wants to Devour ", area)
			zombies_to_kill.append(area)
			
	for zombie in zombies_to_kill:
		zombie.freeze()
	pull_from_below_animation.play()
	for zombie in zombies_to_kill:
		drag_down(zombie)
		
	for zombie in zombies_to_kill:
		pass
		#kill_zombie(zombie)		
	zombies_to_kill.clear()
	print("Emiting Done Eat Normal Time So Devour ")
	done_eating.emit()
			
	
func drag_down(zombie_to_drag):
	zombie_to_drag.reparent(zombie_hiding_rect)
	var sprite_frames = pull_from_below_animation.sprite_frames
	var anim_name = pull_from_below_animation.animation
	var duration = sprite_frames.get_frame_count(anim_name) / sprite_frames.get_animation_speed(anim_name)
	var tween = create_tween()
	tween.tween_property(zombie_to_drag, "position", zombie_to_drag.position + Vector2(0, 42), duration)
	tween.tween_callback(kill_zombie.bind(zombie_to_drag))
	pull_from_below_animation.hide()
	
func kill_zombie(zombie_to_kill):
	pass
	zombie_to_kill.die()



	


func _on_pull_from_below_anim_animation_finished() -> void:
	pass # Replace with function body.
