extends Node


# This is to be called at the beggining of the game (it is loaded globally, and is a singleton),
# so we initialize controller_ports on ready(), then any changes made are caught by the Input signal.
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
			var default_config = ConfigFile.new()
			if (default_config.load(str("user://default.cfg")) != OK):
				print ("Error, could not load default data!")
				return
			
			for key in default_config.get_section_keys("Menu Button"):
				var value = default_config.get_value("Menu Button", key)
				var event = InputEvent()
				
				event.type = InputEvent.JOYSTICK_BUTTON
				event.device = index
				event.button_index = value
				
				InputMap.action_add_event(key, event)
		