extends ProgressBar

@export var recharge_time := 10 

@onready var recharge_timer : Timer = $RechargeTimer
@onready var portal_button : TextureButton = $"../PortalButton"

func _ready() -> void:
	Global.register_portal_progess_bar(self)
	recharge_timer.wait_time = recharge_time
	recharge_timer.timeout.connect(make_portal_available)

func recharge()->void:
	print("Time to Recharge")
	portal_button.disabled = true 
	recharge_timer.start()
	
func _process(_delta: float) -> void:
	if portal_button.disabled:
		self.value = (abs((recharge_timer.time_left / recharge_timer.wait_time)-1.0)) * 100
		print("Self Value is ", self.value)
	
func make_portal_available()->void:
	portal_button.disabled = false 
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	##
