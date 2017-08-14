
extends Control

func _ready():
	set_fixed_process(true)
	
func _fixed_process(delta):
	
	var connected_joysticks = Input.get_connected_joysticks()
	var valid_js_only = true
	
	for joy in connected_joysticks:
		if not Input.is_joy_known(joy):
			valid_js_only = false
			break
	
	if (valid_js_only):
		get_tree().set_pause(false)
		queue_free()