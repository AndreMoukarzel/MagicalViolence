extends Control

var controller_ports = []

# This is to be called at the beggining of the game (it is loaded globally, and is a singleton),
# so we initialize controller_ports on ready(), then any changes made are caught by the Input signal.
func _ready():
	Input.connect("joy_connection_changed", self, "joysticks_changed")
	
	# Initialize controller_ports
	var connected_joysticks = Input.get_connected_joysticks()
	
	if (global.keyboard_enabled == true):
		controller_ports.append("Keyboard")
		
		for num in range (0, connected_joysticks.size()):
			if (controller_ports.size() >= 4):
				break
			controller_ports.append(connected_joysticks[num])
	
func joysticks_changed(index, connected):
	print (str("Index = ", index))
	print (str("Connected = ", connected))