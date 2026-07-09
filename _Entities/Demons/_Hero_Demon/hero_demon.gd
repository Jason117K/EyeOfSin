extends Area2D

@onready var beat_of_death_controller : HeroAbilityComponent = $BeatOfDeath_Controller
@onready var lightning_strike_controller : HeroAbilityComponent = $LightningStrike_Controller
@onready var revive_controller : HeroAbilityComponent = $ReviveDemon_Controller

@onready var all_ability_controllers :Array[HeroAbilityComponent] = \
					[beat_of_death_controller,lightning_strike_controller,]

var parent_demon : Demon 

func _ready() -> void:
	Global.register_hero_demon(self)


func assign_parent_demon(new_parent_demon : Demon)->void:
	parent_demon = new_parent_demon
	
	for controller in all_ability_controllers:
		parent_demon._init_collision_mask(controller.get_detection_area(),true)

	parent_demon._init_collision_mask(revive_controller.get_detection_area(),false)
