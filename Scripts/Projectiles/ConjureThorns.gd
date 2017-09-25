extends KinematicBody2D

const SPEED = 6

var direction = Vector2( 0, 0 ) # direction that the seed flies to
var parent
var state = "seed"


func fire( direction, parent ):
	self.direction = direction
	self.parent = parent
	get_node( "Area2D/CollisionShape2D" ).set_shape( CapsuleShape2D )
	get_node( "Area2D/CollisionShape2D" ).set_scale( Vector2( 0.32, 0.32) )
	get_node( "AnimatedSprite" ).play( "seed" )
	set_rot( direction.angle() )
	set_pos( parent.get_pos() )
	set_process( true )


func _process(delta):
	move( direction * SPEED )


func _on_Area2D_body_enter( body ):
	if body != parent:
		grow()
		get_node( "GrowTimer" ).stop()
		get_node( "LifeTimer" ).start()
		if body.has_method( "take_damage" ):
			body.take_damage(15)
			# If the thorns are grown, play death animation
			# when enemy enters them. Otherwise, the seed just
			# disappears dealing damage
			if state == "grown":
				get_node( "AnimatedSprite" ).play( "die" )
			else:
				die()


func _on_GrowTimer_timeout():
	get_node( "LifeTimer" ).start()
	state = "grown"
	grow()


# Projectile stops moving and expands
func grow():
	set_process( false )
	# Changes the collision shape for the thorns and plays animation
	set_rot( 0 )
	get_node( "AnimatedSprite" ).play( "grow" )
	get_node( "Area2D/CollisionShape2D" ).set_shape( CircleShape2D )
	get_node( "Area2D/CollisionShape2D" ).set_scale( Vector2( 1.4, 1.4) )
	get_node( "AnimatedSprite" ).set_scale( Vector2( 0.6, 0.6) )
	# Will die after LifeTimer timeout
	get_node( "LifeTimer" ).start()


func _on_AnimatedSprite_finished():
	get_node( "AnimatedSprite" ).stop()
	if get_node( "AnimatedSprite" ).get_animation() == "die":
		die()


func _on_LifeTimer_timeout():
	get_node( "AnimatedSprite" ).play( "die" )


func die():
	set_process( false )
	queue_free()