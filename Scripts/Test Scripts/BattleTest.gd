
extends Control

var positions = [Vector2(200, 300), Vector2(800, 300), Vector2(510, 100), Vector2(510, 500)]
var char_scn = preload("res://Scenes/Character.tscn")

var active_players = []
var character_sprites = []
var port_to_sprite = {}
var living = -1

func _ready():
	get_parent().get_node("Loading Animation").hide()

func _process(delta):
	check_and_apply_end_condition()

func start(a_p, c_s):
	var sprite_counter = 0

	active_players = a_p
	character_sprites = c_s
	living = active_players.size()


	for port in active_players:
		var char_inst = char_scn.instance()
		char_inst.set_name(str("Character", port))
		char_inst.set_pos(positions[port])
		print (character_sprites)
		char_inst.get_node("Sprite").set_animation(character_sprites[sprite_counter])
		# This is so we can recover the right sprite for the end battle text
		port_to_sprite[port] = sprite_counter
		print(port_to_sprite)
		sprite_counter += 1
		char_inst.connect("death", self, "anotherOneBitesTheDust")
		add_child(char_inst)
		
	set_process(true)

func anotherOneBitesTheDust():
	living -= 1
		
func check_and_apply_end_condition():
	if living <= 1:
		set_process(false)
		get_parent().show()
		
		var winner_port
		for node in get_children():
			if (node.get_name().substr(0, node.get_name().length() - 1) == "Character"):
				winner_port = (node.get_name().substr(get_name().length() - 1, node.get_name().length())).to_int()
				print(winner_port)
		get_node("RainbowLabel/Label").set_text(str(character_sprites[port_to_sprite[winner_port]], " WINS!"))
		get_node("RainbowLabel").show()

		get_node("WinTimer").start()
		yield(get_node("WinTimer"), "timeout")
		for port in active_players:
			get_parent().unlock_port(port)
		get_parent().set_process_input(true)

		end()

func end():
	living = -1
	for node in get_children():
		if (node.get_name().substr(0, node.get_name().length() - 1) == "Character"):
			node.queue_free()
	get_node("RainbowLabel").hide()
	self.hide()