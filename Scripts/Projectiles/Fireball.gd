

extends KinematicBody2D

const SPEED = 6

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


	# does damage if take damage function exists in body
	# dies out
func _on_Area2D_body_enter( body ):
	if body != parent:
		if body.has_method("take_damage"):
			body.take_damage(10)
		die()


func _on_LifeTimer_timeout():
	die()


func die():
	get_node( "AnimationPlayer" ).play( "death" )
	set_process( false )


func free_scn():
	queue_free()