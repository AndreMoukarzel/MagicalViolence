
extends Control

var connected_joysticks = []


func _ready():
	set_fixed_process(true)

func _fixed_process(delta):
	for node in get_node("Controllers").get_children():
		node.set_texture(load("res://Sprites/TestSprites/NoController.png"))
	
	connected_joysticks = Input.get_connected_joysticks()
	for joy in connected_joysticks:
		#print (Input.is_joy_known(joy))
		get_node(str("Controllers/", joy)).set_texture(load(str("res://Sprites/TestSprites/Yes", joy, "Controller.png")))
		
		# Face button check
		
		if (Input.is_joy_button_pressed(joy, JOY_BUTTON_0)):
			get_node(str("FaceButtons/", joy, "/A")).set_texture(load("res://Sprites/TestSprites/APressed.png"))
		else:
			get_node(str("FaceButtons/", joy, "/A")).set_texture(load("res://Sprites/TestSprites/ANormal.png"))
		
		if (Input.is_joy_button_pressed(joy, JOY_BUTTON_1)):
			get_node(str("FaceButtons/", joy, "/B")).set_texture(load("res://Sprites/TestSprites/BPressed.png"))
		else:
			get_node(str("FaceButtons/", joy, "/B")).set_texture(load("res://Sprites/TestSprites/BNormal.png"))
			
		if (Input.is_joy_button_pressed(joy, JOY_BUTTON_2)):
			get_node(str("FaceButtons/", joy, "/X")).set_texture(load("res://Sprites/TestSprites/XPressed.png"))
		else:
			get_node(str("FaceButtons/", joy, "/X")).set_texture(load("res://Sprites/TestSprites/XNormal.png"))
			
		if (Input.is_joy_button_pressed(joy, JOY_BUTTON_3)):
			get_node(str("FaceButtons/", joy, "/Y")).set_texture(load("res://Sprites/TestSprites/YPressed.png"))
		else:
			get_node(str("FaceButtons/", joy, "/Y")).set_texture(load("res://Sprites/TestSprites/YNormal.png"))
			
		# Left Stick Axis Check
		
		var horizontal = Input.get_joy_axis(joy, JOY_AXIS_0) * 37
		var vertical = Input.get_joy_axis(joy, JOY_AXIS_1) * 37
		
		#print (str("h = ", horizontal))
		#print (str("v = ", vertical))
		get_node(str("LeftJoystick/", joy, "/Center")).set_pos(Vector2(horizontal + 132, vertical + 320))