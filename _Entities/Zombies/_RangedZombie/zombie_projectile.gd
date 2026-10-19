extends Area2D
# ZombieProjectile.gd — the Ranged zombie's web ball. Flies straight down the lane
# and damages the first target it touches.

@onready var sprite : Sprite2D = $Sprite2D

var speed := 325.0
var damage : float = 20
var direction := -1.0  # -1 = left toward the demons, +1 when the zombie is flipped
var target_group : String = "Demons"
var max_distance_can_travel : float = 0
var spawn_position : Vector2
var hit_once := false


func _ready() -> void:
	if max_distance_can_travel == 0:
		max_distance_can_travel = get_viewport_rect().size.x
	spawn_position = position
	sprite.flip_h = direction < 0
	area_entered.connect(on_hit)

	# Same-dimension targets only; a flipped Ranged zombie targets zombies instead.
	var is_green := Dim.of(self) == Dim.GREEN
	for layer : int in [Dim.LAYER_SHARED, Dim.LAYER_PURPLE_DEMONS, Dim.LAYER_GREEN_DEMONS,
			Dim.LAYER_PURPLE_ZOMBIES, Dim.LAYER_GREEN_ZOMBIES]:
		set_collision_mask_value(layer, false)
	if target_group == "Zombie":
		set_collision_mask_value(Dim.LAYER_GREEN_ZOMBIES if is_green else Dim.LAYER_PURPLE_ZOMBIES, true)
	else:
		set_collision_mask_value(Dim.LAYER_GREEN_DEMONS if is_green else Dim.LAYER_PURPLE_DEMONS, true)


func _physics_process(delta: float) -> void:
	position.x += speed * direction * delta
	if absf(position.x - spawn_position.x) > max_distance_can_travel:
		queue_free()


func on_hit(area: Area2D) -> void:
	if hit_once:
		return
	if not area.is_in_group(target_group) or area.is_in_group("Portal"):
		return
	# EmptyDemon is only a cross-dimension placement blocker.
	if area.get("is_empty"):
		return
	if area is Zombie:
		if area.is_dead:
			return
		area.take_damage(false, damage, false)
	elif area.has_method("take_damage"):
		area.take_damage(damage)
	else:
		return
	hit_once = true
	queue_free()
