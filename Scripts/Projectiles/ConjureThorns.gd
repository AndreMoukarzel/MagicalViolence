extends KinematicBody2D

const SPEED = 6

var direction = Vector2( 0, 0 ) # direction that the seed flies to
var parent
var is_seed = true


func fire( direction, parent ):
	self.direction = direction
	self.parent = parent
	get_node( "Area2D/CollisionShape2D" ).set_shape( CapsuleShape )
	get_node( "Area2D/CollisionShape2D" ).set_scale( Vector2( 0.32, 0.32) )
	set_rot( direction.angle() )
	set_pos( parent.get_pos() )
	set_process( true )


func _process(delta):
	move( direction * SPEED )


func _on_Area2D_body_enter( body ):
	if body != parent:
		grow()
		get_node( "GrowTimer" ).queue_free()
		get_node( "LifeTimer" ).start()
		if body.has_method( "take_damage" ):
			get_node("Area2D").queue_free()
			# If the thorns are grown, play death animation
			# when enemy enters them. Otherwise, the seed just
			# disappears dealing damage
			if !is_seed:
				body.take_damage(40)
				_on_LifeTimer_timeout()
			else:
				body.take_damage(15)
				die()


func _on_GrowTimer_timeout():
	get_node( "LifeTimer" ).start()
	is_seed = false
	grow()


# Projectile stops moving and expands
func grow():
	set_process( false )
	# Changes the collision shape for the thorns and plays animation
	set_rot( 0 )
	get_node( "AnimationPlayer" ).play( "grow" )
	get_node( "Area2D/CollisionShape2D" ).set_shape( CircleShape2D )
	get_node( "Area2D/CollisionShape2D" ).set_scale( Vector2( 1.4, 1.4) )
	get_node( "AnimatedSprite" ).set_scale( Vector2( 0.6, 0.6) )


func _on_LifeTimer_timeout():
	get_node("LifeTimer").queue_free()
	get_node( "AnimationPlayer" ).play( "die" )
	yield( get_node("AnimationPlayer"), "finished")
	die()


func die():
	queue_free()