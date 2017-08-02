
extends KinematicBody2D

const SPEED = 5

var direction = Vector2( 0, 0 ) # direction that the fireball flies to

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	pass


func fire( direction, parent ):
	self.direction = direction
	add_collision_exception_with( parent )
	set_pos( parent.get_pos() )
	set_process( true )


func _process(delta):
	move( direction * SPEED )


func _on_Area2D_area_enter( area ):
	# does damage if take damage function exists
	# dies out
	pass # replace with function body
