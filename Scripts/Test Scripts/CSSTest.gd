
extends Control

const KEYBOARD_CUSTOM_ID = 1000

func _ready():
	
	set_process_input(true)
	Input.connect("joy_connection_changed", self, "joysticks_changed")
	
func _input(event):
	
	
	# Jogador tentando entrar
	
	if (event.is_action_pressed("ui_start")):
		
		var available_port
		
		# Keyboard device ID is default to 0, so we change it to
		# differentiate from joystick device IDs.
		
		if (event.type == InputEvent.KEY):
			print (event.device)
			event.device = KEYBOARD_CUSTOM_ID
		
		if (controller_monitor.controller_ports.find(event.device) != -1):
			print("U already in boi")
			return
			
		available_port = controller_monitor.controller_ports.find(-1)
		if (available_port != -1):
			# Found possible port
				controller_monitor.controller_ports[available_port] = event.device
				
				# Animate and unlock functionality
				get_node(str("P", available_port + 1, "/Inactive")).hide()

func joysticks_changed(index, connected):
	
	# We do not account for keyboard being disconnected
	if not connected:
		
		var port_found = controller_monitor.controller_ports.find(index)
		if port_found != -1:
			controller_monitor.controller_ports[port_found] = -1
			
			get_node(str("P", port_found + 1, "/Inactive")).show()
