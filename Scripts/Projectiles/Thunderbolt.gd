extends KinematicBody2D

const SPEED = 4
const DAMAGE = 15

var direction = Vector2( 0, 0 ) # direction that the cloud flies to
var parent


func fire( direction, parent ):
	self.direction = direction
	self.parent = parent
	set_pos( parent.get_pos() )
	set_process( true )


func _process(delta):
	move( direction * SPEED )


# does damage if take damage function exists in body
func _on_Detection_body_enter( body ):
	if body != parent:
		get_node( "Detection" ).queue_free()
		get_node( "DelayTimer" ).start()
		die()


func _on_LifeTimer_timeout():
	die()


func _on_DelayTimer_timeout():
	for body in get_node( "Damage" ).get_overlapping_bodies():
		if body != parent and body.has_method("take_damage"):
			body.take_damage(DAMAGE)
			body.Stun(1)
	#get_node( "AnimationPlayer" ).play( "thunder" )
	get_node( "Damage" ).queue_free()
	free_scn()


func die():
	get_node( "AnimationPlayer" ).play( "death" )
	set_process( false )


func free_scn():
	queue_free()