extends Node2D


@onready var enemy = self.get_parent()

var lane1Zombies = {}
var lane1ZombieCount = 0 

var lane2Zombies  = {}
var lane2ZombieCount = 0 

var lane3Zombies  = {}
var lane3ZombieCount = 0 

var lane4Zombies  = {}
var lane4ZombieCount = 0 

var lane5Zombies  = {}
var lane5ZombieCount = 0 

var allZombiesByLane = [lane1Zombies,lane2Zombies,lane3Zombies,lane4Zombies,lane5Zombies]
var allZombies = [Zombie]

var lane_to_send_zombies = 0 

func _on_sensing_area_entered(area: Area2D) -> void:
	if area.is_in_group("Zombie-Basic"):
		if area.is_in_group("Green"):
			if self.is_in_group("Green"):
				register_zombie(area,area.get_lane_number())
				#canAttack = true
		if area.is_in_group("Purple"):
			if self.is_in_group("Purple"):
				register_zombie(area,area.get_lane_number())
				#canAttack = true 


func register_zombie(new_zombie, laneNumber):
	#print("RRRR Register Demon : ", new_demon, " with laneNumber ", laneNumber)
	register_zombie_to_array(new_zombie)
	match laneNumber:
		3.0:
			#print("LLLLLLLLL3")
			lane1ZombieCount += 1
			lane1Zombies[laneNumber] = lane1ZombieCount
		4.0:
			#print("LLLLLLLLL4")
			lane2ZombieCount += 1
			lane2Zombies[laneNumber] = lane2ZombieCount
		5.0:
			#print("LLLLLLLLL5")
			lane3ZombieCount += 1
			lane3Zombies[laneNumber] = lane3ZombieCount
		6.0:
			#print("LLLLLLLLL6")
			lane4ZombieCount += 1
			lane4Zombies[laneNumber] = lane4ZombieCount
		7.0:
			#print("LLLLLLLLL7")
			lane5ZombieCount += 1
			lane5Zombies[laneNumber] = lane5ZombieCount
	allZombiesByLane = [lane1Zombies,lane2Zombies,lane3Zombies,lane4Zombies,lane5Zombies]
	
	
func register_zombie_to_array(new_zombie : Zombie):
	allZombies.append(new_zombie)
	
func moveToStrongestZombieLane():
	var strongestZombieCount = -1
	var currentZombieCount = 0
	var currentLane = allZombiesByLane[0]
	#Incremement to find the lane with the highest amount of zombies 
	for lane in allZombiesByLane:
		#print("lane is ", lane )
		for key in lane:
			currentZombieCount += lane[key]
			break
		#currentDemonCount += lane.size()
		#print("lane size is ", currentDemonCount )
		if currentZombieCount > strongestZombieCount:
			strongestZombieCount = currentZombieCount
			currentLane = lane
		currentZombieCount = 0 
	print(currentLane.keys())
	
	if currentLane.keys().size() > 0:
		lane_to_send_zombies = currentLane.keys()[0]
	else:
		lane_to_send_zombies = 3
			

	print("Moooooooooooooooooooooooooove ", self, " to lane ", lane_to_send_zombies)
	enemy.move_to_lane(lane_to_send_zombies)
