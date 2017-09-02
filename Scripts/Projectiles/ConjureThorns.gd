extends KinematicBody2D

const SPEED = 8

var direction = Vector2( 0, 0 ) # direction that the seed flies to
var parent


func fire( direction, parent ):
	self.direction = direction
	self.parent = parent
	set_pos( parent.get_pos() )
	set_process( true )


func _process(delta):
	move( direction * SPEED )


func _on_Area2D_body_enter( body ):
	if body != parent:
		get_node( "GrowTimer" ).stop()
		get_node( "LifeTimer" ).start()
		grow()
		if body.has_method( "take_damage" ):
			body.take_damage(15)
			die()


func _on_GrowTimer_timeout():
	grow()
	get_node( "LifeTimer" ).start()


# Projectile stops moving and expands
func grow():
	# Will die after LifeTimer timeout
	set_process( false ) 
	get_node( "AnimationPlayer" ).play( "grow" )
	get_node( "LifeTimer" ).start()


func _on_LifeTimer_timeout():
	die()


func die():
	get_node( "AnimationPlayer" ).play( "death" )
	set_process( false )


func free_scn():
	queue_free()

