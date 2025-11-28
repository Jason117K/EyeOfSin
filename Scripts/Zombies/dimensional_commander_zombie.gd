extends Zombie
# DimensionalCommanderZombie.gd

# Handles Any CommanderZombie Specific Logic 
var lane1Demons = {}
var lane1DemonCount = 0 

var lane2Demons = {}
var lane2DemonCount = 0 

var lane3Demons = {}
var lane3DemonCount = 0 

var lane4Demons = {}
var lane4DemonCount = 0 

var lane5Demons = {}
var lane5DemonCount = 0 

var allDemons = [lane1Demons,lane2Demons,lane3Demons,lane4Demons,lane5Demons]

var allZombies = [Zombie]
var lane_to_send_zombies = 0 

func ready():
	if self.is_in_group("Purple"):
		$CommandComponent.add_to_group("Purple")
		
	elif self.is_in_group("Green"):
		$CommandComponent.add_to_group("Green")

func _on_command_zone_area_entered(area: Area2D) -> void:
	if area.is_in_group("Plants"):
		print("Plant Entered")
		if area.is_in_group("Green"):
			print("Demon Is Green")
			if self.is_in_group("Purple"):
				print("Green Register Demon ", area)
				register_demon(area,area.get_laneNumber())
		elif area.is_in_group("Purple"):
			if self.is_in_group("Green"):
				print("Purple Register Demon ", area)
				register_demon(area,area.get_laneNumber())

		
	elif area.is_in_group("Zombie-Basic"):
		if area.is_in_group("Green"):
			if self.is_in_group("Green"):
				print("RRRRRG Register Zombie ", area)
				register_zombie(area)
		elif area.is_in_group("Purple"):
			if self.is_in_group("Purple"):
				print("RRRRRP Register Zombie ", area)
				register_zombie(area)
					


func register_demon(new_demon, laneNumber):
	print("RRRR Register Demon : ", new_demon, " with laneNumber ", laneNumber)
	match laneNumber:
		3.0:
			#print("LLLLLLLLL3")
			lane1DemonCount += 1
			lane1Demons[laneNumber] = lane1DemonCount
		4.0:
			#print("LLLLLLLLL4")
			lane2DemonCount += 1
			lane2Demons[laneNumber] = lane2DemonCount
		5.0:
			#print("LLLLLLLLL5")
			lane3DemonCount += 1
			lane3Demons[laneNumber] = lane3DemonCount
		6.0:
			#print("LLLLLLLLL6")
			lane4DemonCount += 1
			lane4Demons[laneNumber] = lane4DemonCount
		7.0:
			#print("LLLLLLLLL7")
			lane5DemonCount += 1
			lane5Demons[laneNumber] = lane5DemonCount
	allDemons = [lane1Demons,lane2Demons,lane3Demons,lane4Demons,lane5Demons]
	print("RRRR All Demons is ", allDemons)

func commandZombies():
	var lowestDemonCount = 99
	var currentDemonCount = 0
	var currentLane
	#Incremement to find the lane with the lowest amount of demons 
	for lane in allDemons:
		print("lane is ", lane )
		for key in lane:
			currentDemonCount += lane[key]
			break
		#currentDemonCount += lane.size()
		print("lane size is ", currentDemonCount )
		if currentDemonCount < lowestDemonCount:
			lowestDemonCount = currentDemonCount
			currentLane = lane
		currentDemonCount = 0 
	print(currentLane.keys())
	if currentLane.keys().size() > 0:
		lane_to_send_zombies = currentLane.keys()[0]
	else:
		lane_to_send_zombies = 3
	for currentZombie in allZombies:
		print("Moooooooooooooooooooooooooove ", currentZombie, " to lane ", lane_to_send_zombies)
		currentZombie.move_to_lane(lane_to_send_zombies)
		currentZombie.flip_dimension()

func register_zombie(new_zombie : Zombie):
	allZombies.append(new_zombie)
	


func _on_timer_timeout() -> void:
	commandZombies()
