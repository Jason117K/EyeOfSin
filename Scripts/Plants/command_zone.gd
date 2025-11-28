extends Area2D



func register_plant(demon_to_register, laneNumber):
	get_parent().get_parent().register_demon(demon_to_register, laneNumber)
