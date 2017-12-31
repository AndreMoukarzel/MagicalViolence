
extends Control

# Set for testing purposes only
var port = 0
var parent

var input_states = preload("res://Scripts/input_states.gd")
var btn_up
var btn_down
var btn_accept
var btn_cancel

var scroll_counter = 0
var scroll_speed = 0.3

var tags = []
var tags_node_order = []

# Used lowermost for variable consistency, lowest is the appropriate word here.
var uppermost = 0
var lowermost = 7
var selected = 1

# max_scroll_up is always 1
var max_scroll_down

# We will need an initializer, later on
func _ready():
	
	# For testing purposes
	controller_monitor.controller_ports[0] = 1000
	controller_monitor.map_css_controls(0, "default")
	
	# Carregar as tags existentes explorando o diretorio do user
	var dir = Directory.new()
	var file_name
	var tag_name

	if (dir.open("user://") == OK):
		dir.list_dir_begin()
		file_name = dir.get_next()
		while (file_name != ""):
			if (file_name.split("_").size() != 1):
				tag_name = file_name.split("_")[0]
				tags.append(tag_name)

			file_name = dir.get_next()
	else:
		print ("Directory not found. Something went wrong.")
	tags.sort()
	
	# Added here, to be after sorting
	tags.push_front(str("Player ", port + 1))
	tags.push_front("Hidden")
	tags.push_back("Hidden")
	
	max_scroll_down = tags.size() - 2
	
	var node_counter = 0
	for child in get_node("TagContainer").get_children():
		tags_node_order.append(child)
		
		if (node_counter < tags.size()):
			child.set_text(tags[node_counter])
		else:
			child.set_text("")
		
		node_counter += 1
	
	btn_up = input_states.new(name_adapter("css_up", port))
	btn_down = input_states.new(name_adapter("css_down", port))
	btn_accept = input_states.new(name_adapter("css_accept", port))
	btn_cancel = input_states.new(name_adapter("css_cancel", port))
	
	print(tags)
	set_fixed_process(true)
	
func _fixed_process(delta):
	if (btn_up.state() == input_states.JUST_PRESSED or btn_up.state() == input_states.HOLD):
		move_up()
	elif (btn_down.state() == input_states.JUST_PRESSED or btn_down.state() == input_states.HOLD):
		move_down()
	
	elif (btn_accept.state() == input_states.JUST_PRESSED):
		select_symbol()
	elif (btn_cancel.state() == input_states.JUST_PRESSED):
		return_control()
		
	else:
		scroll_counter = 0
		scroll_speed = 0.3
		
func move_up():
	var tag_amount = tags.size()
	var next_uppermost
	
	# Check if last applicable tag
	if (selected == tags_node_order.size() - 2):
		return
	
	# Check if scroll here
	if (tags.find(tags_node_order[selected].get_text()) > 2 and tags.find(tags_node_order[selected].get_text()) < tag_amount - 5):
		uppermost += 1
		lowermost += 1
		
		
		for child in tags_node_order:
			# Make all white
			child.set("custom_colors/font_color", Color(255, 255, 255))
	
			# Is selected node
			if (tags_node_order.find(child) == 0):
				child.set_pos(Vector2(0, 240))
	
				child.set_text(tags[lowermost])
			else:
				child.get_node("Tween").interpolate_property(child, "rect/pos", child.get_pos(), child.get_pos() - Vector2(0, 40), scroll_speed, Tween.TRANS_LINEAR, Tween.EASE_OUT)
				child.get_node("Tween").start()
	
		# yield here
		set_fixed_process(false)
		for child in tags_node_order:
			# We choose one that is guaranteed to tween.
			if (tags_node_order.find(child) == 1):
				yield(child.get_node("Tween"), "tween_complete")

	# Mudar a cor do node central. Agora fica facil, só pegar o node que é
	# floor(toprow_node_order.size() / 2)

		shift_left_tag_nodes()
		adjust_scroll()
		set_fixed_process(true)
		
	else:
		# Use a timer to limit this movement
		
		for child in tags_node_order:
			# Make all white
			child.set("custom_colors/font_color", Color(255, 255, 255))
		
		selected += 1
	
	
	tags_node_order[selected].add_color_override("font_color", Color(255, 0, 0))
	
func shift_left_tag_nodes():
	var leftmost

	leftmost = tags_node_order[0]
	tags_node_order.pop_front()

	tags_node_order.append(leftmost)

func adjust_scroll():
	scroll_counter += 1
	if (scroll_counter >= 6):
		scroll_speed = 0.15
	elif (scroll_counter >= 3):
		scroll_speed = 0.2
	else:
		scroll_speed = 0.3


func name_adapter(name, port):
	return str(name, "_", port)
