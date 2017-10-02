extends KinematicBody2D

const SPEED = 0.25
const DAMAGE = 10
const ROOT_TIME = 1.5

var direction = Vector2( 0, 0 )
var parent


func fire( direction, parent ):
	self.parent = parent
	self.direction = direction
	# get_node( "AnimatedSprite" ).set_frame(0)
	set_pos( parent.get_pos() )
	set_rot( direction.angle() )
	get_node( "AnimationPlayer" ).play( "fire" )


func _on_Area2D_body_enter( body ):
	if body != parent:
		if body.has_method("take_damage"):
			body.take_damage(DAMAGE)
			body.Root(ROOT_TIME)


func _on_LifeTimer_timeout():
	get_node( "AnimationPlayer" ).play( "death" )
	get_node( "Area2D" ).queue_free()


func free_scn():
	queue_free()