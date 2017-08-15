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


func _ready():
	pass

func _on_TagSelector_item_selected( id ):
	if ( id != -1):
		get_node("SelectTag").hide()
		# Continuar logica quando puder
