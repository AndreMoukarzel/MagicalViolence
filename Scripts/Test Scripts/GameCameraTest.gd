
extends Camera2D


func _ready():
	#set_follow_smoothing()
	set_process(true)

func _process(delta):
	var center = Vector2(0, 0)
	var number = 0
	
	var distance = 0
	var positions = []
	
	for node in get_tree().get_nodes_in_group("Player"):
		center += node.get_pos()
		positions.append(node.get_pos())
		number += 1
	
	distance = sqrt(pow(positions[0].x - positions[1].x, 2) + pow(positions[0].y - positions[1].y, 2))
	if (distance > 400):
		set_zoom(Vector2(distance/400, distance/400))
	else:
		set_zoom(Vector2(1, 1))
	print(distance)
	
	center = center / number
	get_parent().set_pos(center)