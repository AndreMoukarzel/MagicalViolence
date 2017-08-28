
extends Control

func _ready():
	
	set_process_input(true)
	Input.connect("joy_connection_changed", self, "joysticks_changed")
	
func _input(event):
	
	if (event.is_action_pressed("ui_start")):
		
		for num in range (0, 4):
			if (controller_monitor.controller_ports[num] == -1):
				# Found possible port
				controller_monitor.controller_ports[num] = event.device
				
				# Animate and unlock functionality

