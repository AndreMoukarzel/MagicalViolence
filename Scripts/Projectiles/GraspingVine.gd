extends KinematicBody2D

const SPEED = 0.25

var direction = Vector2( 0, 0 )
var parent


func fire( direction, parent ):
	self.parent = parent
	self.direction = direction
	# get_node( "AnimatedSprite" ).set_frame(0)
	set_pos( parent.get_pos() )
	set_rot( direction.angle() )
	get_node( "LifeTimer" ).start()
	get_node( "AnimationPlayer" ).play( "fire" )
	set_process( true )


func _process(delta):
	move( direction * SPEED )


func _on_Area2D_body_enter( body ):
	if body != parent:
		if body.has_method("take_damage"):
			body.take_damage(10)
			body.Root(1.5)


func _on_LifeTimer_timeout():
	get_node( "AnimationPlayer" ).play( "death" )
	get_node( "Area2D" ).queue_free()


func end_process():
	set_process( false )


func free_scn():
	queue_free()