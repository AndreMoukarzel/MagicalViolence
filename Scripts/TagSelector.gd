
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
# Refers to uppermost tag, not node
var uppermost = 0
var lowermost = 6

# Refers to selected node
var selected = 1

# max_scroll_up is always 1
var max_scroll_down


func initialize(port, parent):
	self.port = port
	self.parent = parent
	
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
	
	
	# Probably use ui button scheme if parent is CustomizeController
	btn_up = input_states.new(name_adapter("css_up", port))
	btn_down = input_states.new(name_adapter("css_down", port))
	btn_accept = input_states.new(name_adapter("css_accept", port))
	btn_cancel = input_states.new(name_adapter("css_cancel", port))
	
	# This is a badly-made fix, so the input for entering this scene doesn't double as selecting a tag
	get_node("InitTimer").start()
	yield(get_node("InitTimer"), "timeout")
	
	set_fixed_process(true)
	
func _fixed_process(delta):
	
	if (btn_down.state() == input_states.JUST_PRESSED or btn_down.state() == input_states.HOLD):
		move_down()
	elif (btn_up.state() == input_states.JUST_PRESSED or btn_up.state() == input_states.HOLD):
		move_up()
	
	elif (btn_accept.state() == input_states.JUST_PRESSED):
		select_tag()
	elif (btn_cancel.state() == input_states.JUST_PRESSED):
		return_control()
		
	else:
		scroll_counter = 0
		scroll_speed = 0.3
		
func move_down():
	var tag_amount = tags.size()
	
	# Check if last applicable tag
	if (selected == tags_node_order.size() - 2 or tags_node_order[(selected + 2)].get_text() == ""):
		return
	
	# Check if scroll here
	if (tags.find(tags_node_order[selected].get_text()) > 2 and tags.find(tags_node_order[selected].get_text()) < tag_amount - 4):
		uppermost += 1
		lowermost += 1
		
		
		for child in tags_node_order:
			# Make all white
			child.set("custom_colors/font_color", Color(255, 255, 255))
	
			# Is uppermost node
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
		tags_node_order[selected].add_color_override("font_color", Color(255, 0, 0))
		
		adjust_scroll()
		set_fixed_process(true)
		
	else:
		# Use a timer to limit this movement
		var timer = get_node("ScrollTimer")
		
		set_fixed_process(false)
		timer.set_wait_time(scroll_speed / 2)
		timer.start()
		
		for child in tags_node_order:
			# Make all white
			child.set("custom_colors/font_color", Color(255, 255, 255))
		selected += 1
		tags_node_order[selected].add_color_override("font_color", Color(255, 0, 0))
		
		
		yield(timer, "timeout")
		adjust_scroll()
		set_fixed_process(true)
	
func shift_left_tag_nodes():
	var leftmost

	leftmost = tags_node_order[0]
	tags_node_order.pop_front()

	tags_node_order.append(leftmost)
	
func move_up():
	var tag_amount = tags.size()
	var next_lowermost
	
	# Check if first applicable tag
	if (selected == 1):
		return
	
	# Check if scroll here
	if (tags.find(tags_node_order[selected].get_text()) > 3 and tags.find(tags_node_order[selected].get_text()) < tag_amount - 3):
		uppermost -= 1
		lowermost -= 1
		
		
		for child in tags_node_order:
			# Make all white
			child.set("custom_colors/font_color", Color(255, 255, 255))
	
			# Is lowermost node
			if (tags_node_order.find(child) == tags_node_order.size() - 1):
				child.set_pos(Vector2(0, 0))
	
				child.set_text(tags[uppermost])
			else:
				child.get_node("Tween").interpolate_property(child, "rect/pos", child.get_pos(), child.get_pos() + Vector2(0, 40), scroll_speed, Tween.TRANS_LINEAR, Tween.EASE_OUT)
				child.get_node("Tween").start()
	
		# yield here
		set_fixed_process(false)
		for child in tags_node_order:
			# We choose one that is guaranteed to tween.
			if (tags_node_order.find(child) == 1):
				yield(child.get_node("Tween"), "tween_complete")

	# Mudar a cor do node central. Agora fica facil, só pegar o node que é
	# floor(toprow_node_order.size() / 2)

		shift_right_tag_nodes()
		tags_node_order[selected].add_color_override("font_color", Color(255, 0, 0))
		
		adjust_scroll()
		set_fixed_process(true)
		
	else:
		# Use a timer to limit this movement
		var timer = get_node("ScrollTimer")
		
		set_fixed_process(false)
		timer.set_wait_time(scroll_speed / 2)
		timer.start()
		
		for child in tags_node_order:
			# Make all white
			child.set("custom_colors/font_color", Color(255, 255, 255))
		selected -= 1
		tags_node_order[selected].add_color_override("font_color", Color(255, 0, 0))
		
		
		yield(timer, "timeout")
		adjust_scroll()
		set_fixed_process(true)
	
func shift_right_tag_nodes():
	var rightmost

	rightmost = tags_node_order[tags_node_order.size() - 1]
	tags_node_order.pop_back()

	tags_node_order.push_front(rightmost)

func adjust_scroll():
	scroll_counter += 1
	if (scroll_counter >= 6):
		scroll_speed = 0.15
	elif (scroll_counter >= 3):
		scroll_speed = 0.2
	else:
		scroll_speed = 0.3

func select_tag():
	
	if (parent == "CSS"):
		var selected_tag = tags_node_order[selected].get_text()
		
		# This is bad practice
		get_parent().get_parent().get_parent().selected_tags[port] = selected_tag
		get_parent().get_node("Tag").set_text(selected_tag)
		return_control()

func return_control():
	
	if (parent == "CSS"):
		# This is bad practice
		get_parent().get_parent().get_parent().ignored_ports.erase(port)
		get_parent().get_node("Options").show()
		queue_free()


func name_adapter(name, port):
	return str(name, "_", port)
