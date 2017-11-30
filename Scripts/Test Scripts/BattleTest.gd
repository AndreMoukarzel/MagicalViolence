
extends Node

var positions = [Vector2(200, 300), Vector2(800, 300), Vector2(510, 100), Vector2(510, 500)]
var char_scn = preload("res://Scenes/Character.tscn")

var living = -1

func start(players_num):
	living = players_num
	
	for i in range(players_num):
		var char_inst = char_scn.instance()
		char_inst.set_name(str("Character", i))
		char_inst.set_pos(positions[i])
		char_inst.connect("death", self, "anotherOneBitesTheDust")
		add_child(char_inst)


func anotherOneBitesTheDust():
	living -= 1
	if living <= 1:
		get_parent().show()
		queue_free()