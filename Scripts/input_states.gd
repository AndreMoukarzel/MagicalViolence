
extends Node

# The better name here would be "action", as
# an actions can represent multiple keys at once.
var key

var PREV_STATE = false
var STATE = false
var NEXT_STATE = false

const NOT_PRESSED = 0
const JUST_PRESSED = 1
const HOLD = 2
const JUST_RELEASED = 3

func _init(key_name):
	key = key_name

func state():
	PREV_STATE = STATE
	STATE = NEXT_STATE
	
	var state
	
	if (PREV_STATE != STATE):
		if (STATE == true):
			state = JUST_PRESSED
		else:
			state = JUST_RELEASED
	else:
		if (STATE == true):
			state = HOLD
		else:
			state = NOT_PRESSED
	
	NEXT_STATE = Input.is_action_pressed(key)
	
	return state

func is_pressed():
	return Input.is_action_pressed(key)