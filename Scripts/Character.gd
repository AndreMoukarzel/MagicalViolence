
extends KinematicBody2D

const RUN_SPEED = 4

var input_states = preload("res://Scripts/input_states.gd")

var btn_magic = input_states.new("ui_magic")
var btn_melee = input_states.new("ui_melee")

var current_anim = "idle_down"
onready var anim_player = get_node("Sprite/AnimationPlayer")

var current_direction = Vector2( 0, 1 )

# Spells
var fireball_scn = preload("res://Scenes/Projectiles/Fireball.tscn")
var scorching_scn = preload("res://Scenes/Projectiles/ScorchingMissile.tscn")


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
		# Temporary solution to this issue, will probably be
		# replaced when other animations come into play.
		new_anim = str("idle_", current_anim.split("_")[1])
	else:
		current_direction = direction / RUN_SPEED

	# should take external forces into consideration
	move( direction )

	################################################

	if btn_magic.state() == 3: #release spell
		var fireball = scorching_scn.instance()
		fireball.fire( current_direction, self )
		get_parent().add_child( fireball )

	update_anim( new_anim )


func update_anim( new_animation ):
	current_anim = anim_player.get_current_animation()

	if new_animation != current_anim:
		anim_player.play(new_animation)