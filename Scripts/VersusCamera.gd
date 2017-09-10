
extends Camera2D


func _ready():
	#set_follow_smoothing()
	set_process(true)

func _process(delta):
	var center = Vector2(0, 0)
	var number = 0
	
	# We do not have a different behavior for horizontal
	# and vertical distances because if you do not zoom
	# both coordinates equally, it gives out a stretching effect.
	var distance = 0
	var positions = []
	
	for node in get_tree().get_nodes_in_group("Player"):
		positions.append(node.get_pos())
		number += 1
	
	# Not sure if the "else" formula works for
	# polygons of all kinds.
	if positions.size() == 2:
		# Get center
		for pos in positions:
			center += pos
		center = center / 2
	else:
		for pos in positions:
			center += pos
		center = center / positions.size()
		
	
	# Get maximum distance
	for pos1 in positions:
		for pos2 in positions:
			var new_distance = linear_distance(pos1, pos2)
			if (new_distance > distance):
				distance = new_distance
	
	if (distance > 400):
		var zoom_distance = distance/400
		
		# Limite superior
		if (zoom_distance > 1.75):
			zoom_distance = 1.75
			
		set_zoom(Vector2(zoom_distance, zoom_distance))
	else:
		# Limite inferior
		set_zoom(Vector2(1, 1))
		
	print (get_zoom())
	
	get_parent().set_pos(center)

func linear_distance(pos1, pos2):
	return sqrt(pow(pos1.x - pos2.x, 2) + pow(pos1.y - pos2.y, 2))