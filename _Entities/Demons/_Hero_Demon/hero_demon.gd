class_name HeroDemon
extends Area2D

@onready var beat_of_death_controller : HeroAbilityComponent = $BeatOfDeath_Controller
@onready var lightning_strike_controller : HeroAbilityComponent = $LightningStrike_Controller
@onready var revive_controller : ReviveDemonController = $ReviveDemon_Controller

@onready var all_ability_controllers :Array[HeroAbilityComponent] = \
					[beat_of_death_controller,lightning_strike_controller,]

var parent_demon : Demon
var is_demo := false

func _ready() -> void:
	if is_demo:
		$Revive_Timer.stop()
		return
	Global.register_hero_demon(self)

## Codex previews: call before add_child. A demo Monolith stays out of Global (registering
## would remove the player's real Monolith) and its abilities only fire when told to.
func make_demo() -> void:
	is_demo = true
	for child in get_children():
		if child is HeroAbilityComponent:
			child.is_demo = true

func remove_hero()->void:
	parent_demon.despawn_hero_demon()


func assign_parent_demon(new_parent_demon : Demon)->void:
	parent_demon = new_parent_demon

	for controller in all_ability_controllers:
		parent_demon._init_collision_mask(controller.get_detection_area(),true)

	parent_demon._init_collision_mask(revive_controller.get_detection_area(),false)
