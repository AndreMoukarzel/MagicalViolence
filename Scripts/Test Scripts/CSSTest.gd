
extends Control

const KEYBOARD_CUSTOM_ID_1 = 1000
const KEYBOARD_CUSTOM_ID_2 = 2000
const OPEN = 0
const SELECTING_CHARACTER = 1
const SELECTING_TAG = 2
const LOCKED = 3

var tc_scn = preload("res://Scenes/TagCreator.tscn")
var ts_scn = preload("res://Scenes/TagSelector.tscn")

var port_state = [OPEN, OPEN, OPEN, OPEN]
# Used to determine which ports are being used by instances of other scenes.
var ignored_ports = []

var css_character_order = ["Skeleton", "Broleton", "Bloodyskel", "Sealeton"]

# Where the "cursor" is, at this moment, for the characters
var css_character_index = [0, 0, 0, 0]
# The character selected by each port, if any
var selected_characters = [-1, -1, -1, -1]

# The tag selected by each port.
var selected_tags = ["Player 1", "Player 2", "Player 3", "Player 4"]

# Order of the menu that appears once your character is selected
var css_options_order = ["Lock", "Create Tag", "Select Tag"]

# Where the "cursor" is, at this moment, for the options menu
var css_options_index = [0, 0, 0, 0]

# This is made to shorten names, controller_monitor is a global
var cm = controller_monitor

func _ready():

	set_process_input(true)
	Input.connect("joy_connection_changed", self, "joysticks_changed")
#	get_node("BattleTest").hide()

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
		if (k_id != -1):
			event.device = k_id
		else:
			# We should not have reached here. Something went wrong.
			return

	# This one is not dependent on the port states, initially, because devices
	# that are not yet assigned to a port might
	var port_found = cm.controller_ports.find(event.device)

	if (port_found == -1 and event.is_action_pressed("ui_start")):
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
	elif (port_found == -1):
		print("There is no port assigned to this device.")
		return
		
	if (ignored_ports.find(port_found) != -1):
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

		if (event.is_action_pressed(name_adapter("css_down", port_found))):
			option_selection_move_down(port_found)
		elif (event.is_action_pressed(name_adapter("css_up", port_found))):
			option_selection_move_up(port_found)
		elif (event.is_action_pressed(name_adapter("css_accept", port_found))):
			var selected_option = determine_selected_option(port_found)
			if (selected_option == "Create Tag"):
				hand_over_control_tc(port_found)
			elif (selected_option == "Select Tag"):
				hand_over_control_ts(port_found)
			elif (selected_option == "Lock"):
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

	# Avoid possible repeated selection
	for num in range (0, 4):
		if (num == port_found):
			continue
		if (css_character_index[num] == selected_characters[port_found]):
			character_selection_move_left(num)
			
	# Cosmetic
	get_node(str("P", port_found + 1, "/Active/Confirmation")).hide()
	get_node(str("P", port_found + 1, "/Active/Options")).show()

func open_port(event):
	joysticks_changed(event.device, false)

#####################################################################################
#####################################################################################

func option_selection_move_down(port_found):
	var next_options_index = (css_options_index[port_found] + 1) % css_options_order.size()
	for child in get_node(str("P", port_found + 1, "/Active/Options")).get_children():
		if (child.get_name() == css_options_order[css_options_index[port_found]]):
			child.set("custom_colors/font_color", Color(255, 255, 255))
		elif (child.get_name() == css_options_order[next_options_index]):
			child.set("custom_colors/font_color", Color(255, 0, 0))
	
	css_options_index[port_found] = next_options_index

func option_selection_move_up(port_found):
	var next_options_index = (css_options_index[port_found] + css_options_order.size() - 1) % css_options_order.size()
	for child in get_node(str("P", port_found + 1, "/Active/Options")).get_children():
		if (child.get_name() == css_options_order[css_options_index[port_found]]):
			child.set("custom_colors/font_color", Color(255, 255, 255))
		elif (child.get_name() == css_options_order[next_options_index]):
			child.set("custom_colors/font_color", Color(255, 0, 0))
	
	css_options_index[port_found] = next_options_index

func determine_selected_option(port_found):
	return css_options_order[css_options_index[port_found]]
	
func hand_over_control_tc(port_found):
	ignored_ports.append(port_found)
	
	var tc_instance = tc_scn.instance()
	tc_instance.initialize(port_found, "CSS")
	tc_instance.set_name("TagCreator")
	tc_instance.set_pos(Vector2(15, 400))
	
	get_node(str("P", port_found + 1, "/Active/Options")).hide()
	get_node(str("P", port_found + 1, "/Active")).add_child(tc_instance)
	
func hand_over_control_ts(port_found):
	ignored_ports.append(port_found)
	
	var ts_instance = ts_scn.instance()
	ts_instance.initialize(port_found, "CSS")
	ts_instance.set_name("TagSelector")
	ts_instance.set_pos(Vector2(15, 400))
	
	get_node(str("P", port_found + 1, "/Active/Options")).hide()
	get_node(str("P", port_found + 1, "/Active")).add_child(ts_instance)
	

func lock_port(port_found):
	port_state[port_found] = LOCKED
	
	# Cosmetic
	get_node(str("P", port_found + 1, "/Active/Confirmation")).show()
	get_node(str("P", port_found + 1, "/Active/Confirmation")).set_text("Ready to Battle!!")
	get_node(str("P", port_found + 1, "/Active/Options")).hide()

func unselect_character(port_found):
	port_state[port_found] = SELECTING_CHARACTER
	selected_characters[port_found] = -1
	
	# Cosmetic
	get_node(str("P", port_found + 1, "/Active/Confirmation")).set_text("Select Character")
	get_node(str("P", port_found + 1, "/Active/Confirmation")).show()
	get_node(str("P", port_found + 1, "/Active/Options")).hide()

#####################################################################################
#####################################################################################

func unlock_port(port_found):
	port_state[port_found] = SELECTING_TAG
	
	# Cosmetic
	get_node(str("P", port_found + 1, "/Active/Confirmation")).hide()
	get_node(str("P", port_found + 1, "/Active/Options")).show()

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
		elif (state != OPEN):
			print("Someone is not yet ready.")
			return

	if (players_ready <= 1):
		print("At least two players are needed to begin")
		return

	# Map controls to given port (not accounting for tags, yet)
	for port in range (0, 4):
		cm.map_game_controls(port, "default")

	# Instance battle scene
	# Have to instance the characters in the battle scene itself

	instance_and_load_battle()

	# Ignore inputs to this scene, and show loading animation
	set_process_input(false)


# Note that an argument is always necessary so the thread works properly.
func instance_and_load_battle():
#	var battle_scn = load("res://Scenes/Test Scenes/BattleTest.tscn")
#	var btl_scn = battle_scn.instance()

	var active_ports = []
	var character_sprites = []

	# Insert correct port and character sprites
	for num in range (0, 4):
		if (port_state[num] == LOCKED):
			active_ports.append(num)
			character_sprites.append(css_character_order[css_character_index[num]])

	get_node("BattleTest").start(active_ports, character_sprites)
	get_node("BattleTest").show()

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
			
			# Remove tag from port
			selected_tags[port_found] = str("Player ", port_found + 1)
			get_node(str("P", port_found + 1, "/Active/Tag")).set_text(str("Player ", port_found + 1))

			# Remove CSS port mappings from index

			cm.unmap_css_controls(port_found)
