
extends KinematicBody2D

const RUN_SPEED = 2

var input_states = preload("res://scripts/input_states.gd")

var btn_magic = input_states.new("ui_magic")
var btn_melee = input_states.new("ui_melee")

var current_anim = ""
onready var anim_player = get_node("Sprite/AnimationPlayer")

func _ready():
	set_process(true)

func _process(delta):
	################### MOVEMENT ###################

	var direction = Vector2( 0, 0 )
	var new_anim
	
	if Input.is_action_pressed("ui_left"):
		direction -= Vector2( RUN_SPEED, 0 )
		new_anim = "run_left"
	if Input.is_action_pressed("ui_right"):
		direction += Vector2( RUN_SPEED, 0 )
		new_anim = "run_right"
	if Input.is_action_pressed("ui_up"):
		direction -= Vector2( 0, RUN_SPEED )
		new_anim = "run_up"
	if Input.is_action_pressed("ui_down"):
		direction += Vector2( 0, RUN_SPEED )
		new_anim = "run_down"

	if direction == Vector2( 0, 0 ):
		new_anim = current_anim # use regex or some shit to get the idle version of old anim
	update_anim( new_anim )

	# should take external forces into consideration
	move( direction )

	################################################


func update_anim( new_animation ):
	current_anim = anim_player.get_current_animation()

	if new_animation != current_anim:
		anim_player.play(new_animation)