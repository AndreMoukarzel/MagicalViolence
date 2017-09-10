
extends Control

const KEYBOARD_CUSTOM_ID = 1000

var locked = [false, false, false, false]
var css_order = ["Skeleton", "Broleton"]
var css_selector_index = [0, 0, 0, 0]

# This is made to shorten names, controller_monitor is a global
var cm = controller_monitor

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
	
	# Player trying to enter game
	if (event.is_action_pressed("ui_start")):
		
		var available_port
		
		# Tem que checar se todos estão prontos, se não estiverem deve cair aqui
		if (cm.controller_ports.find(event.device) != -1):
			print("U already in boi")
			return
			
		available_port = cm.controller_ports.find(-1)
		if (available_port != -1):
			# Found possible port
				cm.controller_ports[available_port] = event.device
				
				# Animate
				get_node(str("P", available_port + 1, "/Inactive")).hide()
				get_node(str("P", available_port + 1, "/Active")).show()
				
				# Map CSS Actions to device based on port
				# Make default map for css (much like menus, we do not permit customization)
				var filepath
				var new_event = InputEvent()
				
				if (event.device == KEYBOARD_CUSTOM_ID):
					filepath = "res://DefaultControls/keyboard.cfg"
				else:
					filepath = "res://DefaultControls/default.cfg"
				
				cm.map_css_controls(event.device, available_port, filepath)
	
	# Actions other than entering game
	else:
		
		var port_found = cm.controller_ports.find(event.device)
		
		if (port_found == -1):
			print("You must be in to operate")
			return
		
		# Player selecting character (tag selection and other commands to be decided)
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
				
			# If holds cancel in this state, return to previous menu, if only presses for a moment cancels selection
		
		else:
			
			# Player trying to start game
			if (event.is_action_pressed(name_adapter("css_accept", port_found))):
				
				# Check if enough players are ready
				var players_ready = 0
				
				for l in locked:
					if (l):
						players_ready += 1
				
				if (players_ready <= 1):
					print("At least two players are needed to begin")
					return
				
				# Map controls to given port
				for device in controller_monitor.controller_ports:
					var char_port = controller_monitor.controller_ports.find(device)
					print (str("Device: ", device, " and char_port: ", char_port))
					
					if (device != -1):
						
						var filepath
						
						if (device == KEYBOARD_CUSTOM_ID):
							filepath = "res://DefaultControls/keyboard.cfg"
						else:
							filepath = "res://DefaultControls/default.cfg"
					
						cm.map_game_controls(device, char_port, filepath)
						
				# Instance battle scene
				# Have to instance the characters in the battle scene itself
				
				var battle_scn = load("res://Scenes/Test Scenes/BattleTest.tscn")
				var btl_scn = battle_scn.instance()
				get_tree().get_root().add_child(btl_scn)
				self.hide()
				#test, putting correct character sprite
				btl_scn.get_node("Character0/Sprite").set_animation(css_order[css_selector_index[0]])
				btl_scn.get_node("Character1/Sprite").set_animation(css_order[css_selector_index[1]])
				set_process_input(false)
			
			# Unlock port
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