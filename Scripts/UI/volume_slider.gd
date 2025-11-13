extends HSlider

@export var busName : String
var busIndex : int


func _ready()-> void : 
	print("=== VolumeSlider _ready() Debug ===")
	print("busName: ", busName)
	busIndex = AudioServer.get_bus_index(busName)
	print("busIndex: ", busIndex)
	#value_changed.connect(on_value_changed)

	if busIndex >= 0:
		var db_value = AudioServer.get_bus_volume_db(busIndex)
		print("Current bus volume (db): ", db_value)
		value = db_to_linear(db_value)
		print("Setting slider value to: ", value)
	else:
		print("ERROR: Invalid bus index for bus: ", busName)

func on_value_changed(value : float ):
	print("=== SLIDER VALUE CHANGED ===")
	print("Slider for bus: ", busName, " changed to: ", value)
	busIndex = AudioServer.get_bus_index(busName)
	print("BusName is ", busName, "Bus Index is ", busIndex)
	AudioServer.set_bus_volume_db(
		busIndex,
		linear_to_db(value)
	)
	print("Changed Volume to ", value, " or ", linear_to_db(value))
