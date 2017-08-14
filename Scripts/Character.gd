
extends KinematicBody2D

const RUN_SPEED = 4

var input_states = preload("res://Scripts/input_states.gd")

# Id has to coincide with port, in our model
var controller_id = 0

var btn_magic = input_states.new("ui_magic")
var btn_melee = input_states.new("ui_melee")

var current_anim = "idle_down"
onready var anim_player = get_node("Sprite/AnimationPlayer")

var current_direction = Vector2( 0, 1 )

# Spells
var fireball_scn = preload("res://Scenes/Projectiles/Fireball.tscn")
var scorching_scn = preload("res://Scenes/Projectiles/ScorchingMissile.tscn")


func _ready():
	add_to_group("Player")
	
	#test
	var node_name = self.get_name()
	controller_id = node_name.substr(node_name.length() - 1, node_name.length()).to_int()
	
	set_process(true)

func _process(delta):
	################### MOVEMENT ###################

	var direction = Vector2( 0, 0 )
	var new_anim
	
	if Input.is_action_pressed(name_adapter("char_left")):
		direction -= Vector2( RUN_SPEED, 0 )
		new_anim = "run_left"
	if Input.is_action_pressed(name_adapter("char_right")):
		direction += Vector2( RUN_SPEED, 0 )
		new_anim = "run_right"
	if Input.is_action_pressed(name_adapter("char_up")):
		direction -= Vector2( 0, RUN_SPEED )
		new_anim = "run_up"
	if Input.is_action_pressed(name_adapter("char_down")):
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
		fireball.set_name("ball") # test
		get_parent().add_child( fireball )

	update_anim( new_anim )


func update_anim( new_animation ):
	current_anim = anim_player.get_current_animation()

	if new_animation != current_anim:
		anim_player.play(new_animation)
		
# Function that adds controller_id to the end of
# the name srnt, so that it can be understood by
# the input map.
func name_adapter(name):
	return str(name, "_", controller_id)