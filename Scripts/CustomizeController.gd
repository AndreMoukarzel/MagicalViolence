extends Control
# No caso, vamos ter um dicionario, com os campos
# TAG, e uma grande lista, no formato [["action", "joy_button"], ["action", "joy_button"]...].
# Podemos salvar essa lista, mas precisamos ter acesso facil a ela pois, no começo do jogo é quando
# associaremos a TAG a um device_id. Então, faremos o script que foi criado no ambiente de testes
# de controle. NOTE-SE: não é a forma mais eficiente de se fazer custom_controls. Referencias para
# praticas melhores se encontram em:
# https://godotengine.org/qa/2994/is-there-any-built-in-way-to-save-the-inputmap
# https://github.com/akien-mga/dynadungeons/blob/master/scripts/global.gd#L93
# Mas, por ora, temos a seguinte sequencia de codigo:
#
#for ev in range (0, 17):
#			var temporary_event = InputEvent()
#			temporary_event.type = InputEvent.JOYSTICK_BUTTON
#			temporary_event.button_index = ev
#			temporary_event.device = 0
#			InputMap.action_erase_event("char_fire_0", temporary_event)
#
# No caso, teremos ele fazendo isso para cada item da lista anteriormente explicitada.
# O device seria o device associado a TAG anterior.
#
# Ao inves de um dicionario, uma ideia mais interessante seria salvar aquela lista em
# um arquivo com o mesmo nome da tag. Assim, se uma tag não tiver nenhuma mudança, os controles
# padrões se mantem para ela. Isso ocorre tambem se a tag nao tiver um save associado, mas isso seria
# um problema de design, e devemos previnir para que isso nao aconteça e notificar se isso ocorrer.
#
# As mudanças para cada tag tem que ser salvas nessa cena, toda vez que o botão de "salvar" for acionado.
#
# A configfile salva apenas os indexes dos botoes. Quando formos carrega-los, precisaremos transforma-los
# em eventos de verdade. Uma forma de realizar isto esta exemplificada em ControllerTest.

var selected_tag = null
var selected_input = null



func _ready():
	
	get_node("SelectTag/TagSelector").add_item("Select a Tag")
	
	for node in get_node("GameCustomization").get_children():
		for child in node.get_children():
			if (child.get_name() == "Button"):
				child.connect("pressed", self, "_on_Button_pressed", [child])
				# So controller input is not accounted for on those
				child.set_focus_mode(FOCUS_NONE)
	
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
				get_node("SelectTag/TagSelector").add_item(tag_name)
			
			file_name = dir.get_next()
	else:
		print ("Directory not found. Something went wrong.")
	
	# Caso nao exista nenhuma tag criada	
	if (get_node("SelectTag/TagSelector").get_item_count() == 0):
		get_node("SelectTag/TagSelector").set_disabled(true)
		
	
	
################### Game Controls Costumization ###################

func _on_Button_pressed(button):
	selected_input = button.get_parent().get_name()

	get_node("GameCustomization/PressKey").show()
	get_node("GameCustomization/PressKey/Text").set_text(str("Press the desired button\n for the ", selected_input, " command."))
	
	set_process_input(true)
	
func _input(event):
	
	if (event.type == InputEvent.JOYSTICK_BUTTON and event.pressed):
		var input_name = selected_input.to_lower()
		
		print(str("Recieved joystick button. The key was: ", event.button_index, ", and the device was: ", event.device))
		
		
		# Nota importante: salvamos os controles em formas incompletas,
		# como char_fire, ou char_magic, para podermos carregar na device
		# desejada quando for comecar uma partida. Entao, iremos adicionar
		# o _0, _1, _2 ou _3, e carregar os controles no mapa.
		# Temos que resetar o mapa para o global antes de toda partida,
		# antes de carregar as tags novas.
		
		var config = ConfigFile.new()
		if (config.load(str("user://", selected_tag, "_tagconfig.cfg")) != OK):
			print ("Error, could not load tag data!")
			return
		config.set_value("Joystick Button", str("char_", input_name), event.button_index)
		
		# Finished, update the modified config visually
		check_repeat_button(event.button_index, input_name, config)
		
		get_node(str("GameCustomization/", selected_input, "/Text")).set_text(str("[Button ", event.button_index, "]"))
		get_node("GameCustomization/PressKey").hide()
		selected_input = null
		
		config.save(str("user://", selected_tag, "_tagconfig.cfg"))
		set_process_input(false)
		
func check_repeat_button(button, input_name, config):
	for node in get_node("GameCustomization").get_children():
		for child in node.get_children():
			if (child.get_name() == "Text"):
				if (child.get_text().find(str(button)) >= 0):
					child.set_text("[Unassigned]")
					config.set_value("Joystick Button", str("char_", child.get_parent().get_name().to_lower()), "Unassigned")
	
	
################### Menu Flow ###################

func _on_GameControls_pressed():
	get_node("CustomizationSelect").hide()
	get_node("SelectTag").show()

func _on_TagSelector_item_selected( id ):
	print(id)
	
	if ( id != -1 and id != 0):
		selected_tag = get_node("SelectTag/TagSelector").get_item_text(id)
		
		get_node("SelectTag").hide()
		get_node("SelectTag/TagSelector").select(0)
		
		get_node("GameCustomization").show()
		
		# Carregar os controles da tag, se existirem
		var config = ConfigFile.new()
		if (config.load(str("user://", selected_tag, "_tagconfig.cfg")) != OK):
			print ("Error, could not load tag data!")
			return
		
		for key in config.get_section_keys("Joystick Button"):
			var real_name = str(key.split("_")[1].capitalize())
			# For some reason, Godot is failing to identify value as
			# an JoystickButtonInputEvent, so we have to manually extract the
			# button_index from the string
			var value = config.get_value("Joystick Button", key)
			get_node(str("GameCustomization/", real_name, "/Text")).set_text(str("[Button ", value, "]"))

func _on_CreateTag_pressed():
	var selector = get_node("SelectTag/TagSelector")
	var tag = get_node("SelectTag/TextEdit").get_text()
	
	if (tag != ""):
		for existent in range (0, selector.get_item_count()):
			if (tag == selector.get_item_text(existent)):
				# Notify that it already exists
				get_node("SelectTag/TextEdit").set_text("")
				return
		
		# Add tag
		selector.add_item(tag)
		get_node("SelectTag/TextEdit").set_text("")
		get_node("SelectTag/TagSelector").set_disabled(false)
		
		# Create config file
		var config = ConfigFile.new()
		config.save(str("user://", tag, "_tagconfig.cfg"))
		
func _on_TextEdit_text_changed():
	if (get_node("SelectTag/TextEdit").get_text() == ""):
		get_node("SelectTag/CreateTag").set_disabled(true)
	else:
		get_node("SelectTag/CreateTag").set_disabled(false)
		
################### Back/Cancel Buttons ###################

func _on_SelectTagBack_pressed():
	get_node("SelectTag").hide()
	get_node("CustomizationSelect").show()
	
	get_node("SelectTag/TextEdit").set_text("")
	get_node("SelectTag/TagSelector").select(0)


func _on_GCBack_pressed():
	# Check if left any unassigned actions
	var config = ConfigFile.new()
	if (config.load(str("user://", selected_tag, "_tagconfig.cfg")) != OK):
		print ("Error, could not load tag data!")
		return
	
	for key in config.get_section_keys("Joystick Button"):
		if str(config.get_value("Joystick Button", key)) == "Unassigned":
			print("You have left some controls unassigned!")
			return
	
	get_node("GameCustomization").hide()
	get_node("SelectTag").show()
	
	selected_tag = null


func _on_PressKeyCancel_pressed():
	get_node("GameCustomization/PressKey").hide()
	selected_input = null
