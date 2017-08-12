
extends Control

var connected_joysticks = []


func _ready():
	set_fixed_process(true)

func _fixed_process(delta):
	for node in get_node("Controllers").get_children():
		node.set_texture(load("res://Sprites/TestSprites/NoController.png"))
	
	connected_joysticks = Input.get_connected_joysticks()
	for joy in connected_joysticks:
		get_node(str("Controllers/", joy)).set_texture(load(str("res://Sprites/TestSprites/Yes", joy, "Controller.png")))