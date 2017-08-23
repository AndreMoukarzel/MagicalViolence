extends Control

# Helps control the menu by joypad
var menu_pos = 0
var menu_depth = 0
var menu_order = [["Versus", "Options", "Credits"], [] , ["Controls", "Audio", "Video"]]

func _ready():
	set_process_input(true)
	
func _input(event):
	
	if event.is_action_pressed("ui_down") or event.is_action_pressed("ui_right"):
		menu_pos = (menu_pos + 1) % menu_order[menu_depth].size()
		
		move_cat("Down", menu_order[menu_depth].size())
		
		get_node(str(menu_order[menu_depth][menu_pos], "/ButtonAnimations")).play("HoveringDown")
		set_process_input(false)
		yield(get_node(str(menu_order[menu_depth][menu_pos], "/ButtonAnimations")), "finished")
		set_process_input(true)
	
	elif event.is_action_pressed("ui_up") or event.is_action_pressed("ui_left"):
		menu_pos = (menu_pos - 1) % menu_order[menu_depth].size()
		
		move_cat("Up", menu_order[menu_depth].size())
		
		get_node(str(menu_order[menu_depth][menu_pos], "/ButtonAnimations")).play("HoveringUp")
		set_process_input(false)
		yield(get_node(str(menu_order[menu_depth][menu_pos], "/ButtonAnimations")), "finished")
		set_process_input(true)
		
	elif event.is_action_pressed("ui_accept") or event.is_action_pressed("ui_select"):
		navigate_menus("fowards")
		
	elif event.is_action_pressed("ui_cancel"):
		navigate_menus("backwards")
		
func navigate_menus(direction):
	# Check if going fowards or backwards. Need to implement later the return to title screen.
	if direction == "fowards":
		# Check what menu layer we are
		
		# Main menu options
		if menu_depth == 0:
			
			if menu_pos == 0:
				pass
				# Once we desire more options, we can add
				# menu options to the menu_order array.
				# If we only want to test versus, just
				# take to the scene.
				# menu_depth += 1
				
			elif menu_pos == 1:
				menu_depth = 2
				transition_menus(0, 2)
				
			else:
				pass
				# Take to credits menu. We haave not
				# reserved space on menu_order for this
				# is a guaranteed exit from the main menu.
		
		# Versus Menu
		elif menu_depth == 1:
			pass
		
		# Options Menu
		elif menu_depth == 2:
			# Soon to be implemented
			pass
	
	elif direction == "backwards":
		# Check what menu layer we are
		
		# Main menu options
		if menu_depth == 0:
			pass
			# Return to title screen
			
		# Versus Menu
		elif menu_depth == 1:
			pass
		
		# Options Menu
		elif menu_depth == 2:
			menu_depth = 0
			transition_menus(2, 0)
			
func transition_menus(leaving, entering):
	
	var ap = get_node("MenuTransitions")
	
	set_process_input(false)
	
	cat_menu_transition()
	ap.play(str("SlideRight", leaving))
	yield(ap, "finished")
	ap.play(str("SlideLeft", entering))
	yield(ap, "finished")
	
	for num in range (0, menu_order[leaving].size()):
		var hover = get_node(str(menu_order[leaving][num], "/Hover"))
		var normal = get_node(str(menu_order[leaving][num], "/Normal"))
		
		if (num != 0):
			hover.set("z/z", 10 * num)
			normal.set("z/z", (10 * num) + 1)
		else:
			hover.set("z/z", 1)
			normal.set("z/z", 0)
			
	menu_pos = 0
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
		
func cat_menu_transition():
	var cat = get_node("Cat")
	var sprite = get_node("Cat/AnimatedSprite")
	
	sprite.set_animation("JumpHorizontal")
	sprite.set("transform/rot", -15)
	
	get_node("Cat/Tween").interpolate_property(cat, "rect/pos", cat.get_pos(), cat.get_pos() - Vector2(1000, 0), 0.5, Tween.TRANS_LINEAR, Tween.EASE_OUT)
	get_node("Cat/Tween").start()
	yield(get_node("Cat/Tween"), "tween_complete")
	
	cat.set_pos(Vector2(-1000, 0))
	sprite.set_scale(Vector2(-2, 2))
	
	get_node("Cat/Tween").interpolate_property(cat, "rect/pos", cat.get_pos(), Vector2(0, 0), 0.5, Tween.TRANS_LINEAR, Tween.EASE_OUT)
	get_node("Cat/Tween").start()
	yield(get_node("Cat/Tween"), "tween_complete")
	
	sprite.set_animation("Idle")
	sprite.set("transform/rot", 0)
	sprite.set_scale(Vector2(2, 2))
	
	
func adjust_z_leaving_down():
	var relevant_container = menu_order[menu_depth][(menu_pos - 1) % menu_order[menu_depth].size()]
	
	var hover = get_node(str(relevant_container, "/Hover"))
	var normal = get_node(str(relevant_container, "/Normal"))
	
	hover.set("z/z", hover.get("z/z") - 1)
	normal.set("z/z", normal.get("z/z") + 1)
	
func adjust_z_leaving_up():
	var relevant_container = menu_order[menu_depth][(menu_pos + 1) % menu_order[menu_depth].size()]
	
	var hover = get_node(str(relevant_container, "/Hover"))
	var normal = get_node(str(relevant_container, "/Normal"))
	
	hover.set("z/z", hover.get("z/z") - 1)
	normal.set("z/z", normal.get("z/z") + 1)

func adjust_z_hovering():
	var hover = get_node(str(menu_order[menu_depth][menu_pos], "/Hover"))
	var normal = get_node(str(menu_order[menu_depth][menu_pos], "/Normal"))
	
	hover.set("z/z", hover.get("z/z") + 1)
	normal.set("z/z", normal.get("z/z") - 1)
	