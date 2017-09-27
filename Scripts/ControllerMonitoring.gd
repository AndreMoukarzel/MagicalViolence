extends Node

const KEYBOARD_CUSTOM_ID = 1000

var controller_ports = [-1, -1, -1, -1]


# This is to be called at the beggining of the game
# (it is loaded globally, and is a singleton), so we
# initialize controller_ports on ready(), then any changes
# made are caught by the Input signal.
func _ready():
	Input.connect("joy_connection_changed", self, "joysticks_changed")

	# So we acknowledge controllers connected on game startup
	for joy in Input.get_connected_joysticks():
		joysticks_changed(joy, true)

func joysticks_changed(index, connected):
	# Por ora, vamos assumir que temos uma estrutura de árvore
	# linear, e que o node mais relevante é o último. Ou podemos
	# adicionar o node como filho da árvore, pode ser também.

	if (connected):
		# Check if a known joystick
		if not Input.is_joy_known(index):
			# Instance Warning
			var warning_scn = load("res://Scenes/Warnings/ControllerWarning.tscn")
			var wrn_scn = warning_scn.instance()
			add_child(wrn_scn)
			get_tree().set_pause(true)

		else:
			# Give menu controls to the device
			# There is no problem on giving controls twice, for
			# repeats are not accounted for on the InputMap.

			var default_config = ConfigFile.new()
			if (default_config.load(str("res://DefaultControls/default.cfg")) != OK):
				print ("Error, could not load default joystick menu data!")
				return

			for key in default_config.get_section_keys("Menu Buttons"):
				var value = default_config.get_value("Menu Buttons", key)
				var event = InputEvent()

				event.type = InputEvent.JOYSTICK_BUTTON
				event.device = index
				event.button_index = value

				print (key)
				print (event)
				InputMap.action_add_event(key, event)

###################################################################################################
################################ CONTROLLER MAPPING FLOW FUNCTIONS ################################
###################################################################################################

func map_css_controls(port, tag):

	var control_config = ConfigFile.new()
	var device = controller_ports[port]
	var filepath = determine_filepath(port, tag)

	if (control_config.load(filepath) != OK):
		print ("Error, could not load css control data!")
		return

	for key in control_config.get_section_keys("CSS"):
		var real_name = str(key, "_", port)
		var value = control_config.get_value("CSS", key)

		# Clear controls associated to the current key
		clear_controls(real_name)

		# Map keyboard / controller to port
		var new_event = InputEvent()

		if (device == KEYBOARD_CUSTOM_ID):
			new_event.type = InputEvent.KEY
			new_event.scancode = value
			new_event.device = 0
		else:
			# Does not account for joystick motion,
			# though it seems unecessary for CSS/Menu controls.
			new_event.type = InputEvent.JOYSTICK_BUTTON
			new_event.button_index = value
			new_event.device = device

		InputMap.action_add_event(real_name, new_event)

func map_game_controls(port, tag):

	var default_config = ConfigFile.new()
	var device = controller_ports[port]
	var filepath = determine_filepath(port, tag)

	if (default_config.load(filepath) != OK):
		print ("Error, could not load default data!")
		return

	if (device == KEYBOARD_CUSTOM_ID):
		# Clear input map of keys and Map keyboard to port
		for key in default_config.get_section_keys("Game Keys"):
			var real_name = str(key, "_", port)
			var value = default_config.get_value("Game Keys", key)

			# Clear controls associated to the current key
			clear_controls(real_name)

			# Map keyboard to port
			var new_event = InputEvent()

			# Make new event, then add it
			new_event.type = InputEvent.KEY
			new_event.scancode = value
			# Necessary, for keyboard default device ID is 0
			new_event.device = 0

			InputMap.action_add_event(real_name, new_event)

	else:
		# Map controller to port, if tag selected map here
		for key in default_config.get_section_keys("Game Buttons"):
			var real_name = str(key, "_", port)
			var value = default_config.get_value("Game Buttons", key)

			# Clear controls associated to the current key
			clear_controls(real_name)

			# Map joystick button to port
			var new_event = InputEvent()

			# Make new event, then add it
			new_event.type = InputEvent.JOYSTICK_BUTTON
			new_event.button_index = value
			new_event.device = device

			InputMap.action_add_event(real_name, new_event)

		# Map controller axis
		for key in default_config.get_section_keys("Game Motions"):

			var real_name = str(key, "_", port)
			var axis_value_vector = default_config.get_value("Game Motions", key)

			# We do not erase controls a second time, we already did this
			# when we were mapping the buttons.

			# Map joystick button to port
			var new_event = InputEvent()

			# Make new event, then add it
			new_event.type = InputEvent.JOYSTICK_MOTION
			new_event.axis = axis_value_vector[0]
			new_event.value = axis_value_vector[1]
			new_event.device = device

			InputMap.action_add_event(real_name, new_event)

func determine_filepath(device, tag):
	if (tag != "default"):
		return str("user://", tag, "_tagconfig.cfg")
	else:
		if (device == KEYBOARD_CUSTOM_ID):
			return "res://DefaultControls/keyboard.cfg"
		else:
			return "res://DefaultControls/default.cfg"

func clear_controls(real_name):
	var event_list = InputMap.get_action_list(real_name)
	for ev in event_list:
		InputMap.action_erase_event(real_name, ev)
