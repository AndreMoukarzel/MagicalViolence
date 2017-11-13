extends Control

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

func _ready():
	set_process_input(true)
	
func _input(event):
	if (event.type == InputEvent.KEY):
		print(event.scancode)
