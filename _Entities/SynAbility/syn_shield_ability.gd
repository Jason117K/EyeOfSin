extends Syn_Ability_Instance



@onready var syn_shield :PackedScene= preload("res://_Entities/SynAbility/syn_shield_anim_sprite.tscn")

var weak_shield_area : Area2D
var offset : Vector2 = Vector2(16,16)

func _ready() -> void:
	detect_demons = true 
	is_dual_connection = false
	super()
	self.global_position = grid_pos + offset
	
func activate_ability()->void:
	#print("Shield Demons Called ", self.get_overlapping_areas())
	for demon in self.get_overlapping_areas():
		if demon.is_in_group("Demons"):
			#print("Shield Demon ", demon)
			demon.shield(syn_shield,ability_duration)
	death_timer.start()
	
			
func weak_shield_demons()->void:
	#print("Weak Shield Demons Called ", weak_shield_area.get_overlapping_areas())
	for demon in weak_shield_area.get_overlapping_areas():
		if demon.is_in_group("Demons") && !demon.invulnerable:
			#print("Weak Shield Demon ", demon)
			demon.weak_shield(syn_shield,ability_duration)
			
				
	
func connect_ability(shield_to_connect: Area2D) -> void:
	var start := global_position
	var end := shield_to_connect.global_position

	var line := Line2D.new()
	line.hide()
	line.width = 2.0

	var points := PackedVector2Array()
	points.append(to_local(start))

	if not is_equal_approx(start.x, end.x) and not is_equal_approx(start.y, end.y):
		points.append(to_local(Vector2(start.x, end.y)))

	points.append(to_local(end))

	line.points = points
	add_child(line)

	#var area := Area2D.new()
	weak_shield_area = Area2D.new()
	if self.is_in_group("Green"):
		weak_shield_area.set_collision_mask_value(1,false)
		weak_shield_area.set_collision_mask_value(2,true)
		weak_shield_area.set_collision_mask_value(3,true)
	else:
		weak_shield_area.set_collision_mask_value(1,false)
		weak_shield_area.set_collision_mask_value(2,true)
		weak_shield_area.set_collision_mask_value(3,true)
		

	for i in range(points.size() - 1):
		var a := points[i]
		var b := points[i + 1]
		var col := CollisionShape2D.new()
		var rect := RectangleShape2D.new()

		if is_equal_approx(a.x, b.x):
			rect.size = Vector2(line.width, abs(b.y - a.y))
		else:
			rect.size = Vector2(abs(b.x - a.x), line.width)

		col.shape = rect
		col.position = (a + b) / 2.0
		weak_shield_area.add_child(col)
	
	add_child(weak_shield_area)
	await get_tree().physics_frame
	await get_tree().physics_frame
	await get_tree().physics_frame
	await get_tree().physics_frame

	weak_shield_demons()
	
func get_icon()->Texture:
	return Global.shield_button_icon
