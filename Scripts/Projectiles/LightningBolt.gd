extends KinematicBody2D


var parent


func fire( direction, parent ):
	self.parent = parent
	set_rotd( rad2deg( direction.angle() ) - 90)
	set_pos( parent.get_pos() )
	get_node( "AnimationPlayer" ).play( "fire" )
	get_node( "Area2D" ).queue_free()


# Damages and stuns if target is an enemy
func _on_Area2D_body_enter( body ):
	if body != parent:
		if body.has_method("take_damage"):
			body.take_damage(20)
			body.is_stunned = true
			# Time stunned
			body.get_node( "StunTimer" ).set_wait_time(1.5)
			body.get_node( "StunTimer" ).start()


func free_scn():
	queue_free()