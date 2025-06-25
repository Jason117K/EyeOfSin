extends HSlider

@export var busName : String

var busIndex : int

func ready()-> void : 
	busIndex = AudioServer.get_bus_index(busName)
	value_changed.connect(on_value_changed)
	
	value = db_to_linear(
		AudioServer.get_bus_volume_db(busIndex)
	)
	
func on_value_changed(value : float ):
	busIndex = AudioServer.get_bus_index(busName)
	print("BusName is ", busName, "Bus Index is ", busIndex)
	AudioServer.set_bus_volume_db(
		busIndex,
		linear_to_db(value)
	)
	print("Changed Volume")
	
