

extends KinematicBody2D

const SPEED = 2

var direction = Vector2( 0, 0 ) # direction that the wave flies to
var parent
var angle


func fire( direction, parent ):
	self.direction = direction
	self.parent = parent
#	add_collision_exception_with( parent )
	set_pos( parent.get_pos() )
	angle = direction.angle()
	set_rot( angle )
	get_node( "AnimationPlayer" ).play( "alive" )
	set_process( true )


func _process(delta):
	move( direction * SPEED )


# slows and push back if take damage function exists in body (?)
func _on_Area2D_body_enter( body ):
	if body != parent:
		if body.has_method("take_damage"):
			print("boi is in")
			# Target is slowed and pushed back


func _on_LifeTimer_timeout():
	die()


func die():
	get_node( "AnimationPlayer" ).play( "death" )
	set_process( false )


func free_scn():
	queue_free()