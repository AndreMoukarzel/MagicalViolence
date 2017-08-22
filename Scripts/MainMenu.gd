extends Control

# Helps control the menu by joypad
var menu_pos = 0
var menu_order = ["Versus", "Options", "Credits"]

func _ready():
	set_process_input(true)
	
func _input(event):
	if event.is_action_pressed("ui_down") or event.is_action_pressed("ui_right"):
		menu_pos = (menu_pos + 1) % menu_order.size()
		
		get_node(str(menu_order[menu_pos], "/ButtonAnimations")).play("Hovering")
		set_process_input(false)
		yield(get_node(str(menu_order[menu_pos], "/ButtonAnimations")), "finished")
		set_process_input(true)
		
################### Animation Functions ###################
		
func adjust_z_leaving():
	var hover = get_node(str(menu_order[(menu_pos - 1) % menu_order.size()], "/Hover"))
	var normal = get_node(str(menu_order[(menu_pos - 1) % menu_order.size()], "/Normal"))
	
	hover.set("z/z", hover.get("z/z") - 1)
	normal.set("z/z", normal.get("z/z") + 1)

func adjust_z_hovering():
	var hover = get_node(str(menu_order[menu_pos], "/Hover"))
	var normal = get_node(str(menu_order[menu_pos], "/Normal"))
	
	hover.set("z/z", hover.get("z/z") + 1)
	normal.set("z/z", normal.get("z/z") - 1)