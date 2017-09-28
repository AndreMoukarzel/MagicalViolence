extends Node

var tags_number = 0
var tags_h_offset = []

var expanded = false

var current_cursor = 0

func _ready():
	
	# To test this functionality we have to give CSS Controls to port 0,
	# and process inputs like the CSS script would be doing
	controller_monitor.controller_ports[0] = 1000
	controller_monitor.map_css_controls(0, "default")
	set_process_input(true)
	
func _input(event):
	# Vai ter que trocar o "_0" pelo name adapter, e receber o port de quem o estiver manipulando ao ser inicializado
	if (event.is_action_pressed("css_accept_0")):
		expand_list()
		expanded = true
	elif (event.is_action_pressed("css_cancel_0")):
		close_list()
		expanded = false
	elif (event.is_action_pressed("css_up_0")):
		move_up()
	elif (event.is_action_pressed("css_down_0")):
		move_down()
		
func expand_list():
	
	var vertical_offset = 0
	
	var dir = Directory.new()
	var file_name
	var tag_name
	
	if (expanded):
		return
	
	# Placeholder visuals
	get_node("ClosedScroll").set_texture(load("res://Sprites/GUI/Buttons/Tag Selector/opened-scroll.png"))
	get_node("CursorContainer/Cursor").show()
	
	if (dir.open("user://") == OK):
		dir.list_dir_begin()
		file_name = dir.get_next()
		while (file_name != ""):
			if (file_name.split("_").size() != 1):
				tag_name = file_name.split("_")[0]
				
				# Add tag name to the list
				var label = Label.new()
				label.set_text(tag_name)
				label.set_name(tag_name)
				label.set("custom_fonts/font", load("res://Resources/Fonts/homemadeapples16.fnt"))
				label.set("custom_colors/font_color", Color(0,0,0))
				label.set_pos(Vector2(0, vertical_offset))
				get_node("Tags").add_child(label)
				
				tags_h_offset.append(label.get_size().x)
				vertical_offset += 30
				tags_number += 1
			
			file_name = dir.get_next()
	else:
		print ("Directory not found. Something went wrong.")
	
	# Placeholder visuals
	get_node("CursorContainer/Cursor").set_pos(Vector2(tags_h_offset[0], 0))
		
func close_list():
	if (not expanded):
		return
	
	for tag in get_node("Tags").get_children():
		tag.queue_free()
		
	current_cursor = 0
	tags_number = 0
	
	# Placeholder visuals
	get_node("CursorContainer/Cursor").hide()
	get_node("CursorContainer/Cursor").set_pos(Vector2(0, 0))
	
	get_node("ClosedScroll").set_texture(load("res://Sprites/GUI/Buttons/Tag Selector/old-scroll.png"))
	
func move_up():
	
	if (not expanded):
		return
	
	var cursor = get_node("CursorContainer/Cursor")
	
	current_cursor = (current_cursor + tags_number - 1) % tags_number
	
	var future_pos = Vector2(tags_h_offset[current_cursor], 30 * current_cursor)
	
	get_node("Tween").interpolate_property(cursor, "transform/pos", cursor.get_pos(), future_pos, 0.3, Tween.TRANS_LINEAR, Tween.EASE_OUT)
	get_node("Tween").start()
	yield(get_node("Tween"), "tween_complete")

func move_down():
	
	if (not expanded):
		return
	
	var cursor = get_node("CursorContainer/Cursor")
	
	current_cursor = (current_cursor + 1) % tags_number
	
	var future_pos = Vector2(tags_h_offset[current_cursor], 30 * current_cursor)
	
	get_node("Tween").interpolate_property(cursor, "transform/pos", cursor.get_pos(), future_pos, 0.3, Tween.TRANS_LINEAR, Tween.EASE_OUT)
	get_node("Tween").start()
	yield(get_node("Tween"), "tween_complete")