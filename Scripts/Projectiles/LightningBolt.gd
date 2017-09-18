extends KinematicBody2D


var parent


func fire( direction, parent ):
	self.parent = parent
	get_node( "AnimatedSprite" ).set_frame(0)
	set_rotd( rad2deg( direction.angle() ) - 90)
	set_pos( parent.get_pos() )
	get_node( "AnimationPlayer" ).play( "fire" )
	get_node( "Area2D" ).queue_free()


# Damages and stuns if target is an enemy
func _on_Area2D_body_enter( body ):
	if body != parent:
		if body.has_method("take_damage"):
			body.take_damage(20)
			body.Stun(1.5)


func free_scn():
	queue_free()