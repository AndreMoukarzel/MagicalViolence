
extends Control

var connected_joysticks = []

var key_mapping = false
#var real_joysticks = []

#var controllers_locked = false

# Os controles funcionarao da seguinte maneira:
# Todo joystick conectado sera testado pelo Input.is_joy_known().
# Se algum falhar no teste, bloqueia os comandos do jogador
# (pause a cena), e coloque um aviso que o controle nao e suportado
# ainda.

func _ready():
	set_fixed_process(true)
	
	set_process_input(true)
	
func _input(event):
	
	if (key_mapping and event.type == InputEvent.JOYSTICK_BUTTON and event.pressed):
		print(str("Recieved joystick button. The key was: ", event.button_index, ", and the device was: ", event.device))
		
		for ev in range (0, 17):
#			var temporary_event = event
#			temporary_event.button_index = ev
			var temporary_event = InputEvent()
			temporary_event.type = InputEvent.JOYSTICK_BUTTON
			temporary_event.button_index = ev
			temporary_event.device = 0
			InputMap.action_erase_event("char_fire_0", temporary_event)
		
		print(InputMap.has_action("char_fire_0"))
		InputMap.action_add_event("char_fire_0", event)
		print(InputMap.event_is_action(event, "char_fire_0"))
		
#		InputMap.load_from_globals()
#		print(InputMap.get_actions())
		
func _fixed_process(delta):
	
	# Controller conectivity test
	for node in get_node("Controllers").get_children():
		node.set_texture(load("res://Sprites/TestSprites/NoController.png"))
	
	connected_joysticks = Input.get_connected_joysticks()
	
	# Controller validity test
	
	for joy in connected_joysticks:
		if not Input.is_joy_known(joy):
			# Instance Warning
			var warning_scn = load("res://Scenes/Warnings/ControllerWarning.tscn")
			var wrn_scn = warning_scn.instance()
			add_child(wrn_scn)
			get_tree().set_pause(true)
			
	
	
	# This was the consistency test for the previous format.
	# There is no more consistency test, for we do not care
	# if the controller connected is the same as before, only
	# if it is valid.
#	# Controller consistency test
#	
#	if (not controllers_locked):
#		real_joysticks.clear()
#		
#		var joysticks = 0
#		# Consider only 4 real joysticks
#		for joy in connected_joysticks:
#			if (Input.is_joy_known(joy)):
#				real_joysticks.append(joy)
#				joysticks += 1
#			if (joysticks == 4):
#				break
#				
#	else:
#		# Procura todos os joysticks do real no vetor dos
#		# conectados. Se algum deles nao estiver la, acuse
#		# que foi desconectado.
#		var missing_joysticks = []
#		
#		for joy in real_joysticks:
#			if (connected_joysticks.find(joy) == -1):
#				missing_joysticks.append(real_joysticks.find(joy))
#		
#		if (missing_joysticks.size() != 0):
#			print(str("Controllers ", missing_joysticks, " are missing"))
		
		
	# Input tests
	
	for joy in connected_joysticks:
		#print (Input.is_joy_known(joy))
		# The controller port is different from the joystick identifier.
		# The controller port is what is kept consistent on our node structure,
		# but the controller identifier can differ since we are ignoring joysticks
		# that godot consider as not known.
		
		get_node(str("Controllers/", joy)).set_texture(load(str("res://Sprites/TestSprites/Yes", joy, "Controller.png")))
		
		# Face button check
		
		if (Input.is_action_pressed("char_fire_0")):
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


func _on_KeyMapping_pressed():
	if (key_mapping):
		get_node("Options/KeyMapping").set_text("Key Mapping: Off")
		key_mapping = false
	
	else:
		get_node("Options/KeyMapping").set_text("Key Mapping: On")
		key_mapping = true
