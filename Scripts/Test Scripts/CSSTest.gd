
extends Control

const KEYBOARD_CUSTOM_ID = 1000

var locked = [false, false, false, false]
var css_order = ["Skeleton", "Broleton"]
var css_selector_index = [0, 0, 0, 0]

func _ready():
	
	set_process_input(true)
	Input.connect("joy_connection_changed", self, "joysticks_changed")
	
func _input(event):
	
	
	# Jogador tentando entrar
	
	# Keyboard device ID is default to 0, so we change it to
	# differentiate from joystick device IDs.
		
	if (event.type == InputEvent.KEY):
		event.device = KEYBOARD_CUSTOM_ID
	
	# Provavelmente vai trocar para dentro da checagem do lock,
	# para o start ser o botão que prossegue, além do que da o port.
	if (event.is_action_pressed("ui_start")):
		
		var available_port
		
		if (controller_monitor.controller_ports.find(event.device) != -1):
			print("U already in boi")
			return
			
		available_port = controller_monitor.controller_ports.find(-1)
		if (available_port != -1):
			# Found possible port
				controller_monitor.controller_ports[available_port] = event.device
				
				# Animate
				get_node(str("P", available_port + 1, "/Inactive")).hide()
				get_node(str("P", available_port + 1, "/Active")).show()
				
				# Map CSS Actions to device based on port
				# Make default map for css (much like menus, we do not permit customization)
				var filepath
				var new_event = InputEvent()
				
				if (event.device == KEYBOARD_CUSTOM_ID):
					event.device = 0
					filepath = "user://keyboard.cfg"
				else:
					filepath = "user://default.cfg"
					
				var default_config = ConfigFile.new()
				if (default_config.load(filepath) != OK):
					print ("Error, could not load default data!")
					return
	
				for key in default_config.get_section_keys("CSS"):
					var real_name = str(key, "_", available_port)
					var value = default_config.get_value("CSS", key)
					
					var new_event = InputEvent()
					
					if (event.type == InputEvent.KEY):
						new_event.type = InputEvent.KEY
						new_event.scancode = value
						new_event.device = event.device
					elif (event.type == InputEvent.JOYSTICK_BUTTON):
						new_event.type = InputEvent.JOYSTICK_BUTTON
						new_event.button_index = value
						new_event.device = event.device
					
					InputMap.action_add_event(real_name, new_event)
	
	else:
		
		var port_found = controller_monitor.controller_ports.find(event.device)
		
		if (port_found == -1):
			print("You must be in to operate")
			return
		
		if (not locked[port_found]):
			
			if (event.is_action_pressed(name_adapter("css_left", port_found))):
				css_selector_index[port_found] = (css_selector_index[port_found] + css_order.size() - 1) % css_order.size()
				get_node(str("P", port_found + 1, "/Active/Character")).set_animation(css_order[css_selector_index[port_found]])
				
			elif (event.is_action_pressed(name_adapter("css_right", port_found))):
				css_selector_index[port_found] = (css_selector_index[port_found] + 1) % css_order.size()
				get_node(str("P", port_found + 1, "/Active/Character")).set_animation(css_order[css_selector_index[port_found]])
				
			elif (event.is_action_pressed(name_adapter("css_accept", port_found))):
				locked[port_found] = true
				get_node(str("P", port_found + 1, "/Active/Confirmation")).set_text("Locked!")
				
			# If holds cancel in this state, return to previous menu
		
		else:
			
			if (event.is_action_pressed(name_adapter("css_accept", port_found))):
				var players_ready = 0
				
				for l in locked:
					if (l):
						players_ready += 1
				
				if (players_ready <= 1):
					print("At least two players are needed to begin")
					return
				
				# Map controls to given port
				for device in controller_monitor.controller_ports:
					if (device != -1):
						
						var filepath
						
						if (device == KEYBOARD_CUSTOM_ID):
							filepath = "user://keyboard.cfg"
						else:
							filepath = "user://default.cfg"
					
						var default_config = ConfigFile.new()
						if (default_config.load(filepath) != OK):
							print ("Error, could not load default data!")
							return
						
						if (device == KEYBOARD_CUSTOM_ID):
							# Clear input map of keys and Map keyboard to port
							for key in default_config.get_section_keys("Keyboard Game Input"):
								var real_name = str(key, "_", port_found)
								var value = default_config.get_value("Keyboard Game Input", key)
								
								# Clear input map of keys
								var event_list = InputMap.get_action_list(real_name)
								for ev in event_list:
									InputMap.action_erase_event(real_name, ev)
								
								# Map keyboard to port
								var new_event = InputEvent()
								
								new_event.type = InputEvent.KEY
								new_event.scancode = value
								# Necessary, for keyboard default device ID is 0
								new_event.device = 0
								
								InputMap.action_add_event(real_name, new_event)
						else:
							# Map controller to port, if tag selected map here
							for key in default_config.get_section_keys("Joystick Button"):
								var real_name = str(key, "_", port_found)
								var value = default_config.get_value("Joystick Button", key)
								
								# Clear input map of keys
								var event_list = InputMap.get_action_list(real_name)
								for ev in event_list:
									InputMap.action_erase_event(real_name, ev)
								
								# Map keyboard to port
								var new_event = InputEvent()
								
								new_event.type = InputEvent.JOYSTICK_BUTTON
								new_event.button_index = value
								# Necessary, for keyboard default device ID is 0
								new_event.device = device
								
								InputMap.action_add_event(real_name, new_event)
			
			if (event.is_action_pressed(name_adapter("css_cancel", port_found))):
				locked[port_found] = false
				get_node(str("P", port_found + 1, "/Active/Confirmation")).set_text("Lock")

func name_adapter(name, port):
	return str(name, "_", port)

func joysticks_changed(index, connected):
	
	# We do not account for keyboard being disconnected
	if not connected:
		
		var port_found = controller_monitor.controller_ports.find(index)
		if port_found != -1:
			controller_monitor.controller_ports[port_found] = -1
			locked[port_found] = false
			
			# Animate
			get_node(str("P", port_found + 1, "/Active")).hide()
			get_node(str("P", port_found + 1, "/Inactive")).show()
			
			# Remove CSS port mappings from index