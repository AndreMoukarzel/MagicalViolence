extends KinematicBody2D

const SPEED = 2
const DAMAGE = 30
var element = 1 # Fire = 0, Water = 1, Nature = 2, Electricity = 3
var level = 3

var direction = Vector2( 0, 0 ) # direction that the wave goes to
var parent


func fire( direction, parent ):
	self.direction = direction
	self.parent = parent
#	add_collision_exception_with( parent )
	set_pos( parent.get_pos() )
	set_rot( direction.angle() )
	get_node( "AnimationPlayer" ).play( "alive" )
	set_process( true )


func _process(delta):
	move( direction * SPEED )


# Pushes back if target is an enemy
func _on_Area2D_body_enter( body ):
	if body.is_in_group( "Player" ) and body != parent:
		# Target is pushed back
		body.push_direction = direction


# Resets the push factor when exiting enemy
func _on_Area2D_body_exit( body ):
	if body.is_in_group( "Player" ) and body != parent:
		body.push_direction = Vector2(0, 0)


# Dies when colliding with static objects
func _on_Area2D_static_body_enter( body ):
	if (!body.is_in_group( "Player" )):
		die()


func _on_LifeTimer_timeout():
	die()


func die():
	get_node( "AnimationPlayer" ).play( "death" )
	set_process( false )


func free_scn():
	queue_free()


