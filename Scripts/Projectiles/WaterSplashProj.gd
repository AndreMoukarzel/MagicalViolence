
extends KinematicBody2D

const SPEED = 8

var direction = Vector2( 0, 0 ) # direction that the fireball flies to
var parent


func fire( direction, parent ):
	self.direction = direction
	self.parent = parent

	set_process( true )


func _process(delta):
	move( direction * SPEED )


# does damage if take damage function exists
func _on_Area2D_body_enter( body ):
	if body != parent:
		get_node("Area2D").queue_free()
		if body.has_method("take_damage"):
			body.take_damage(4)
		die()


func die():
	if get_node( "AnimationPlayer" ).get_current_animation() != "death":
		get_node( "AnimationPlayer" ).play( "death" )
	set_process( false )


func free_scn():
	queue_free()