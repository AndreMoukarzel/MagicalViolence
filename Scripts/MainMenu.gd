extends Control

# Helps control the menu by joypad
var menu_pos = 0
var menu_order = ["Versus", "Options", "Credits"]

func _ready():
	set_process_input(true)
	
func _input(event):
	
	if event.is_action_pressed("ui_down") or event.is_action_pressed("ui_right"):
		menu_pos = (menu_pos + 1) % menu_order.size()
		
		move_cat("Down", menu_order.size())
		
		get_node(str(menu_order[menu_pos], "/ButtonAnimations")).play("HoveringDown")
		set_process_input(false)
		yield(get_node(str(menu_order[menu_pos], "/ButtonAnimations")), "finished")
		set_process_input(true)
	
	if event.is_action_pressed("ui_up") or event.is_action_pressed("ui_left"):
		menu_pos = (menu_pos - 1) % menu_order.size()
		
		move_cat("Up", menu_order.size())
		
		get_node(str(menu_order[menu_pos], "/ButtonAnimations")).play("HoveringUp")
		set_process_input(false)
		yield(get_node(str(menu_order[menu_pos], "/ButtonAnimations")), "finished")
		set_process_input(true)
		
################### Animation Functions ###################
	
func move_cat(direction, menu_items):
	# Note that the cat logic is guaranteed, for the tween
	# only lasts for 0.3 seconds, while the menu button's
	# animation lasts for more than that, and is held off
	# by a yield.
	
	var cat = get_node("Cat")
	var sprite = get_node("Cat/AnimatedSprite")
	var future_position
	
	if (direction == "Down"):
		future_position = (cat.get_pos() + Vector2(100, 100))
		future_position.x = int(future_position.x) % (100 * menu_items)
		future_position.y = int(future_position.y) % (100 * menu_items)
		
		if (future_position > cat.get_pos()):
			sprite.set_animation("JumpDown")
		else:
			# Menu loop
			sprite.set_animation("JumpUp")
		
		get_node("Cat/Tween").interpolate_property(cat, "rect/pos", cat.get_pos(), future_position, 0.3, Tween.TRANS_LINEAR, Tween.EASE_OUT)
		get_node("Cat/Tween").start()
		yield(get_node("Cat/Tween"), "tween_complete")
		sprite.set_animation("Idle")
		
	elif (direction == "Up"):
		future_position = (cat.get_pos() - Vector2(100, 100))
		future_position.x = int(future_position.x) % (100 * menu_items)
		future_position.y = int(future_position.y) % (100 * menu_items)
		
		# Needed, for modulo operator does not solve things the desired way
		if (future_position.y < 0):
			future_position = (Vector2(100 * (menu_items - 1), 100 * (menu_items - 1)))
		
		print(future_position)
		
		if (future_position < cat.get_pos()):
			sprite.set_animation("JumpUp")
		else:
			# Menu loop
			sprite.set_animation("JumpDown")
		
		get_node("Cat/Tween").interpolate_property(cat, "rect/pos", cat.get_pos(), future_position, 0.3, Tween.TRANS_LINEAR, Tween.EASE_OUT)
		get_node("Cat/Tween").start()
		yield(get_node("Cat/Tween"), "tween_complete")
		sprite.set_animation("Idle")
	
	
func adjust_z_leaving_down():
	var hover = get_node(str(menu_order[(menu_pos - 1) % menu_order.size()], "/Hover"))
	var normal = get_node(str(menu_order[(menu_pos - 1) % menu_order.size()], "/Normal"))
	
	hover.set("z/z", hover.get("z/z") - 1)
	normal.set("z/z", normal.get("z/z") + 1)
	
func adjust_z_leaving_up():
	var hover = get_node(str(menu_order[(menu_pos + 1) % menu_order.size()], "/Hover"))
	var normal = get_node(str(menu_order[(menu_pos + 1) % menu_order.size()], "/Normal"))
	
	hover.set("z/z", hover.get("z/z") - 1)
	normal.set("z/z", normal.get("z/z") + 1)

func adjust_z_hovering():
	var hover = get_node(str(menu_order[menu_pos], "/Hover"))
	var normal = get_node(str(menu_order[menu_pos], "/Normal"))
	
	hover.set("z/z", hover.get("z/z") + 1)
	normal.set("z/z", normal.get("z/z") - 1)