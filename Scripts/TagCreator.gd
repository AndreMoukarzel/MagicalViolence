
extends Control

var port

var toprow = ["X", "Y", "Z", "A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W"]

var leftmost_toprow = 0
var leftmost_toprow_node = "0"
var rightmost_toprow = 6
var rightmost_toprow_node = "6"

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
	set_process_input(true)

func initialize(port):
	pass
	set_process_input(true)
	
func _input(event):
	
#	if (event.is_action_pressed(name_adapter("css_left", port_found))):
	if (event.is_action_pressed("ui_left")):
		move_left()
	

func move_left():
	var symbol_amount = toprow.size()
	var next_leftmost
	
	# Done here se we can set the correct text later
#	rightmost_toprow = (leftmost_toprow + symbol_amount - 1) % symbol_amount
	rightmost_toprow = (rightmost_toprow + 1) % symbol_amount
	leftmost_toprow = (leftmost_toprow + 1) % symbol_amount
	
	for child in get_node("TopRow").get_children():
		# Make all white
		child.set("custom_colors/font_color", Color(255, 255, 255))
		
		if (child.get_name() == leftmost_toprow_node):
			child.set_pos(Vector2(180, 0))
			
			child.set_text(toprow[rightmost_toprow])
			rightmost_toprow_node = child.get_name()
		else:
			if (child.get_pos().x - 30 == 0):
				next_leftmost = child.get_name()
			
			child.get_node("Tween").interpolate_property(child, "rect/pos", child.get_pos(), child.get_pos() - Vector2(30, 0), 0.3, Tween.TRANS_LINEAR, Tween.EASE_OUT)
			child.get_node("Tween").start()
	
	# yield here
	set_process_input(false)
	# This is sadly hardcoded, and needs to be changed in case we
	# change the number of shown symbols at a time.
	for num in range (0, 7):
		if (str(num) != rightmost_toprow_node):
			yield(get_node(str("TopRow/", num , "/Tween")), "tween_complete")
	
	for child in get_node("TopRow").get_children():
		print(child.get_pos().x - 90)
		if (child.get_pos().x - 90 == 0):
			pass
			# This function is kinda bad on Godot, maybe set an animation
#			child.set("custom_colors/font_color", Color(165, 215, 85))
	
	leftmost_toprow_node = next_leftmost
	set_process_input(true)

func name_adapter(name, port):
	return str(name, "_", port)
