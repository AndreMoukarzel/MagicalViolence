
extends Control

const KEYBOARD_CUSTOM_ID_1 = 1000
const KEYBOARD_CUSTOM_ID_2 = 2000
const OPEN = 0
const SELECTING_CHARACTER = 1
const SELECTING_TAG = 2
const LOCKED = 3

var port_state = [OPEN, OPEN, OPEN, OPEN]

var css_character_order = ["Skeleton", "Broleton"]

# Where the "cursor" is, at this moment
var css_character_index = [0, 0, 0, 0]
# The character selected by each port, if any
var selected_characters = [-1, -1, -1, -1]

# This is made to shorten names, controller_monitor is a global
var cm = controller_monitor

func _ready():

	set_process_input(true)
	Input.connect("joy_connection_changed", self, "joysticks_changed")

# Determinamos que é mais facil guardar estados em forma de strings, ao
# inves de multiplos vetores. Assim, podemos checar o comando, depois o
# estado em que o jogador se encontra.

func _input(event):

	# Ignore mouse events, for the sake of performance
	if (event.type == InputEvent.MOUSE_MOTION or event.type == InputEvent.MOUSE_BUTTON):
		return

	# Keyboard device ID is default to 0, so we change it to
	# differentiate from joystick device IDs.
	if (event.type == InputEvent.KEY):
		var k_id = determine_keyboard_player(event.scancode)
		print (k_id)
		if (k_id != -1):
			event.device = k_id
		else:
			# We should not have reached here. Something went wrong.
			return

	# This one is not dependent on the port states, initially, because devices
	# that are not yet assigned to a port might
	if (event.is_action_pressed("ui_start")):
		# There is a problem here, we always check this if someone presses "start".
		# This will be checked if a players presses "start" to begin the match, but
		# to no consequence.


		# Assigns port to a device, if it is not yet assigned,
		# and there are available ports.
		assign_port(event)

	# We are assured that devices not on ports will not operate, because
	# we assign CSS controls only when we find a port for the device, and
	# remove controls in case of a device being disconnected, or a player
	# deciding do re-open a port.
<<<<<<< HEAD

=======
>>>>>>> 978afc4f4277c51b128e220135ea1fb74b03ad2c
	var port_found = cm.controller_ports.find(event.device)

	if (port_found == -1):
		print("There is no port assigned to this device.")
		return

	if (port_state[port_found] == SELECTING_CHARACTER):

		# If holds cancel in this state, return to previous menu,
		# if only presses for a moment cancels selection.

		if (event.is_action_pressed(name_adapter("css_left", port_found))):
			character_selection_move_left(port_found)

		elif (event.is_action_pressed(name_adapter("css_right", port_found))):
			character_selection_move_right(port_found)

		elif (event.is_action_pressed(name_adapter("css_accept", port_found))):
			select_character(port_found)

		elif (event.is_action_pressed(name_adapter("css_cancel", port_found))):
			open_port(event)

	elif (port_state[port_found] == SELECTING_TAG):
		
		if (event.is_action_pressed(name_adapter("css_accept", port_found))):
			lock_port(port_found)

		elif (event.is_action_pressed(name_adapter("css_cancel", port_found))):
			unselect_character(port_found)

	elif (port_state[port_found] == LOCKED):

		# Jogador tentando comecar partida, vai trocar do accept para start, provavelmente
		if (event.is_action_pressed(name_adapter("css_accept", port_found))):
			test_instance_battle()

		elif (event.is_action_pressed(name_adapter("css_cancel", port_found))):
			unlock_port(port_found)


##################################################################################
################################ ACTION FUNCTIONS ################################
##################################################################################

func character_selection_move_left(port_found):
	css_character_index[port_found] = (css_character_index[port_found] + css_character_order.size() - 1) % css_character_order.size()
	while (selected_characters.find(css_character_index[port_found]) != -1):
		css_character_index[port_found] = (css_character_index[port_found] + css_character_order.size() - 1) % css_character_order.size()
	get_node(str("P", port_found + 1, "/Active/Character")).set_animation(css_character_order[css_character_index[port_found]])

func character_selection_move_right(port_found):
	# Do this to avoid repeated characters
	css_character_index[port_found] = (css_character_index[port_found] + 1) % css_character_order.size()
	while (selected_characters.find(css_character_index[port_found]) != -1):
		css_character_index[port_found] = (css_character_index[port_found] + 1) % css_character_order.size()
	get_node(str("P", port_found + 1, "/Active/Character")).set_animation(css_character_order[css_character_index[port_found]])

func select_character(port_found):
	port_state[port_found] = SELECTING_TAG
	selected_characters[port_found] = css_character_index[port_found]
	get_node(str("P", port_found + 1, "/Active/Confirmation")).set_text("Lock")

	# Avoid possible repeated selection
	for num in range (0, 4):
		if (cm.controller_ports[num] == -1 or num == port_found):
			continue
		if (css_character_index[num] == selected_characters[port_found]):
			character_selection_move_left(num)

func open_port(event):
	joysticks_changed(event.device, false)
	
#####################################################################################
#####################################################################################

func lock_port(port_found):
	port_state[port_found] = LOCKED
	get_node(str("P", port_found + 1, "/Active/Confirmation")).set_text("Ready to Battle!!")

func unselect_character(port_found):
	port_state[port_found] = SELECTING_CHARACTER
	selected_characters[port_found] = -1
	get_node(str("P", port_found + 1, "/Active/Confirmation")).set_text("Select Character")
	
#####################################################################################
#####################################################################################

func unlock_port(port_found):
	port_state[port_found] = SELECTING_TAG
	get_node(str("P", port_found + 1, "/Active/Confirmation")).set_text("Lock")

#####################################################################################
################################ AUXILIARY FUNCTIONS ################################
#####################################################################################

func determine_keyboard_player(scancode):

	var keyboard_1_config = ConfigFile.new()
	var filepath_1 = "res://DefaultControls/keyboard_1.cfg"
	var keyboard_2_config = ConfigFile.new()
	var filepath_2 = "res://DefaultControls/keyboard_2.cfg"

	if (keyboard_1_config.load(filepath_1) != OK):
		print ("Error, could not load keyboard_1 data!")
		return

	if (keyboard_2_config.load(filepath_2) != OK):
		print ("Error, could not load keyboard_2 data!")
		return

	for key in keyboard_1_config.get_section_keys("CSS"):
		if scancode == keyboard_1_config.get_value("CSS", key):
			return KEYBOARD_CUSTOM_ID_1

	for key in keyboard_2_config.get_section_keys("CSS"):
		if scancode == keyboard_2_config.get_value("CSS", key):
			return KEYBOARD_CUSTOM_ID_2

	return -1

func assign_port(event):
	var available_port

	# Tem que checar se todos estão prontos, se não estiverem deve cair aqui
	if (cm.controller_ports.find(event.device) != -1):
		print(str("This device (", event.device, ") is already assigned to a port."))
		return

	available_port = cm.controller_ports.find(-1)
	if (available_port != -1):
		# Found possible port
			cm.controller_ports[available_port] = event.device
			port_state[available_port] = SELECTING_CHARACTER

			# Animate
			get_node(str("P", available_port + 1, "/Inactive")).hide()
			get_node(str("P", available_port + 1, "/Active")).show()

			cm.map_css_controls(available_port, "default")


func name_adapter(name, port):
	return str(name, "_", port)


func test_instance_battle():
	# Check if enough players are ready
	var players_ready = 0

	for state in port_state:
		if (state == LOCKED):
			players_ready += 1

	if (players_ready <= 1):
		print("At least two players are needed to begin")
		return

	# Map controls to given port (not accounting for tags, yet)
	for port in range (0, 4):
		cm.map_game_controls(port, "default")

	# Instance battle scene
	# Have to instance the characters in the battle scene itself

	var battle_scn = load("res://Scenes/Test Scenes/BattleTest.tscn")
	var btl_scn = battle_scn.instance()
	get_tree().get_root().add_child(btl_scn)
	self.hide()
	#test, putting correct character sprite
	btl_scn.get_node("Character0/Sprite").set_animation(css_character_order[css_character_index[0]])
	btl_scn.get_node("Character1/Sprite").set_animation(css_character_order[css_character_index[1]])
	set_process_input(false)

#####################################################################################
################################# SIGNAL FUNCTIONS ##################################
#####################################################################################

func joysticks_changed(index, connected):

	# We do not account for keyboard being disconnected
	if not connected:

		var port_found = controller_monitor.controller_ports.find(index)
		if port_found != -1:
			controller_monitor.controller_ports[port_found] = -1
			port_state[port_found] = OPEN

			# Animate
			get_node(str("P", port_found + 1, "/Active")).hide()
			get_node(str("P", port_found + 1, "/Inactive")).show()

			# Remove CSS port mappings from index

			cm.unmap_css_controls(port_found)
