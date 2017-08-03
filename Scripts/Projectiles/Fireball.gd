
extends KinematicBody2D

const SPEED = 5

var direction = Vector2( 0, 0 ) # direction that the fireball flies to
var parent

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	pass


func fire( direction, parent ):
	self.direction = direction
	self.parent = parent
#	add_collision_exception_with( parent )
	set_pos( parent.get_pos() )
	set_process( true )


func _process(delta):
	move( direction * SPEED )


func _on_Area2D_body_enter( body ):
	# does damage if take damage function exists
	# dies out
	if body != parent:
		die()

func _on_LifeTimer_timeout():
	die()

func die():
	get_node( "AnimationPlayer" ).play( "death" )
	set_process( false )

func free():
	queue_free()
