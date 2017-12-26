
extends Control

var port

var input_states = preload("res://Scripts/input_states.gd")
var btn_left
var btn_right
var btn_accept
var btn_save

var scroll_counter = 0
var scroll_speed = 0.3
var tag = ""

var toprow = ["X", "Y", "Z", "A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W"]
var toprow_node_order = []

var leftmost_toprow = 0
var rightmost_toprow = 6

# IMPORTANT!
# The leftmost and rightmost labels are buffers. They are never shown, and
# are there solely so the animations occur smoothly.
# For example, when the slider moves left, the leftmost label moves directly
# to the position of the rightmost label, and changes to the appropriate symbol,
# whereas the rest of the labels animate normally.

# Recieve the port to which this tag creator will be associated with.
# We will create a WarioWare-inspired tag creator.
# Also, we will have a WarioWare inspired tag selector.
# Having only horizontal movements while selecting the tag will
# corroborate with the logic used on the Character Select Screen.

# Se decidirmos por mudar a cor da letra selecionada, podemos
# ter as cores dependendo do port (usar um vetor port_colors).

# For testing purposes only
func _ready():
	set_fixed_process(true)
	for child in get_node("TopRow").get_children():
		toprow_node_order.append(child)
	
	controller_monitor.controller_ports[0] = 1000
	controller_monitor.map_css_controls(0, "default")
	
	btn_left = input_states.new(name_adapter("css_left", 0))
	btn_right = input_states.new(name_adapter("css_right", 0))
	btn_accept = input_states.new(name_adapter("css_accept", 0))
	btn_save = input_states.new(name_adapter("css_start", 0))

func initialize(port):
	pass
	set_process_input(true)
	for child in get_node("TopRow").get_children():
		toprow_node_order.append(child)
	# Do it for the rest
#	btn_left = input_states.new(name_adapter("css_left"))

func _fixed_process(delta):
	if (btn_left.state() == input_states.JUST_PRESSED or btn_left.state() == input_states.HOLD):
		move_left()
	elif (btn_right.state() == input_states.JUST_PRESSED or btn_right.state() == input_states.HOLD):
		move_right()
	elif (btn_accept.state() == input_states.JUST_PRESSED):
		select_symbol()
	elif (btn_save.state() == input_states.JUST_PRESSED):
		save_tag()
	else:
		scroll_counter = 0
		scroll_speed = 0.3

func move_left():
	var symbol_amount = toprow.size()
	var next_leftmost
	
	# Done here se we can set the correct text later
#	rightmost_toprow = (leftmost_toprow + symbol_amount - 1) % symbol_amount
	rightmost_toprow = (rightmost_toprow + 1) % symbol_amount
	leftmost_toprow = (leftmost_toprow + 1) % symbol_amount
	
	for child in toprow_node_order:
		# Make all white
		child.set("custom_colors/font_color", Color(255, 255, 255))
		
		# Is leftmost node
		if (toprow_node_order.find(child) == 0):
			child.set_pos(Vector2(180, 0))
			
			child.set_text(toprow[rightmost_toprow])
		else:
			child.get_node("Tween").interpolate_property(child, "rect/pos", child.get_pos(), child.get_pos() - Vector2(30, 0), scroll_speed, Tween.TRANS_LINEAR, Tween.EASE_OUT)
			child.get_node("Tween").start()
	
	# yield here
	set_fixed_process(false)
	for child in toprow_node_order:
		# We choose one that is guaranteed to tween.
		if (toprow_node_order.find(child) == 1):
			yield(child.get_node("Tween"), "tween_complete")
	
	# Mudar a cor do node central. Agora fica facil, só pegar o node que é
	# floor(toprow_node_order.size() / 2)
	
	shift_left_toprow()
	toprow_node_order[floor(toprow_node_order.size() / 2)].add_color_override("font_color", Color(255, 0, 0))
	adjust_scroll()
	set_fixed_process(true)

func move_right():
	var symbol_amount = toprow.size()
	var next_leftmost
	
	# Done here se we can set the correct text later
	rightmost_toprow = (rightmost_toprow + symbol_amount - 1) % symbol_amount
	leftmost_toprow = (leftmost_toprow + symbol_amount - 1) % symbol_amount
	
	for child in toprow_node_order:
		# Make all white
		child.set("custom_colors/font_color", Color(255, 255, 255))
		
		# Is leftmost node
		if (toprow_node_order.find(child) == (toprow_node_order.size() - 1)):
			child.set_pos(Vector2(0, 0))
			
			child.set_text(toprow[leftmost_toprow])
		else:
			child.get_node("Tween").interpolate_property(child, "rect/pos", child.get_pos(), child.get_pos() + Vector2(30, 0), scroll_speed, Tween.TRANS_LINEAR, Tween.EASE_OUT)
			child.get_node("Tween").start()
	
	# yield here
	set_fixed_process(false)
	for child in toprow_node_order:
		# We choose one that is guaranteed to tween.
		if (toprow_node_order.find(child) == 1):
			yield(child.get_node("Tween"), "tween_complete")
	
	# Mudar a cor do node central. Agora fica facil, só pegar o node que é
	# floor(toprow_node_order.size() / 2)
	
	shift_right_toprow()
	toprow_node_order[floor(toprow_node_order.size() / 2)].add_color_override("font_color", Color(255, 0, 0))
	adjust_scroll()
	set_fixed_process(true)

func shift_left_toprow():
	var leftmost
	
	leftmost = toprow_node_order[0]
	toprow_node_order.pop_front()
	
	toprow_node_order.append(leftmost)

func shift_right_toprow():
	var rightmost
	
	rightmost = toprow_node_order[toprow_node_order.size() - 1]
	toprow_node_order.pop_back()
	
	toprow_node_order.push_front(rightmost)

func adjust_scroll():
	scroll_counter += 1
	if (scroll_counter >= 6):
		scroll_speed = 0.15
	elif (scroll_counter >= 3):
		scroll_speed = 0.2
	else:
		scroll_speed = 0.3

func select_symbol():
	var number_to_mid = int(ceil(toprow_node_order.size() / 2))
	var middle_symbol = toprow[floor((leftmost_toprow + number_to_mid) % toprow.size())]
	tag = str(tag, middle_symbol)
	get_node("Tag").set_text(tag)
	
func save_tag():
	var dir = Directory.new()
	var tag_name
	var file_name
	var existent_tags = []
	
	# Do not allow empty tags
	if (tag == ""):
		return
	
	# Populate existent tags
	if (dir.open("user://") == OK):
		dir.list_dir_begin()
		file_name = dir.get_next()
		while (file_name != ""):
			if (file_name.split("_").size() != 1):
				tag_name = file_name.split("_")[0]
				existent_tags.append(tag_name)

			file_name = dir.get_next()
	else:
		print ("Directory not found. Something went wrong.")
		
	# Check if is not a repeat, create a config file
	if (existent_tags.find(tag) == -1):

		if (dir.copy("res://DefaultControls/controller.cfg", str("user://", tag, "_tagconfig.cfg")) != OK):
			print("Error! Default tag initialization failed!")

func name_adapter(name, port):
	return str(name, "_", port)
