
extends KinematicBody2D

var SPEED = 2.5

var direction = Vector2( 0, 0 ) # direction that the fireball flies to
var parent


func fire( direction, parent ):
	self.direction = direction
	self.parent = parent
#	add_collision_exception_with( parent )
	set_pos( parent.get_pos() )
	set_process( true )


func _process(delta):
	move( direction * SPEED )
	SPEED -= 0.75*delta
	if (SPEED <= 0):
		die()


# does damage if take damage function exists in body
func _on_Area2D_body_enter( body ):
	if body != parent:
		get_node("Area2D").queue_free()
		if body.has_method("take_damage"):
			body.take_damage(15)
		if body.has_method("_on_SlowTimer_timeout"):
			# Applies slow effect 
			body.slow_multiplier = 0.6
			body.get_node( "SlowTimer" ).set_wait_time(2)
			body.get_node( "SlowTimer" ).start()
			
		die()


func die():
	get_node( "AnimationPlayer" ).play( "death" )
	set_process( false )


func free_scn():
	queue_free()
