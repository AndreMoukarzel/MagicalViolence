
extends Node

var positions = [Vector2(200, 300), Vector2(800, 300), Vector2(510, 100), Vector2(510, 500)]
var char_scn = preload("res://Scenes/Character.tscn")

var living = -1

func _ready():
	get_parent().get_node("Loading Animation").hide()

func start(active_players, character_sprites):
	var sprite_counter = 0
	
	living = active_players.size()
	

	for port in active_players:
		var char_inst = char_scn.instance()
		char_inst.set_name(str("Character", port))
		char_inst.set_pos(positions[port])
		print (character_sprites)
		char_inst.get_node("Sprite").set_animation(character_sprites[sprite_counter])
		sprite_counter += 1
		char_inst.connect("death", self, "anotherOneBitesTheDust")
		add_child(char_inst)


func anotherOneBitesTheDust():
	living -= 1
	if living <= 1:
		get_parent().show()
		queue_free()
