extends "Projectile.gd"

const SPEED = 5
var element = 3 # Lightning = 0, Nature = 1, Fire = 2, Water = 3
var level = 3

var direction = Vector2( 0, 0 ) # direction that the wave goes to
var parent


func fire( direction, parent ):
	self.direction = direction
	self.parent = parent
	set_pos( parent.get_pos() )
	if direction.x != 0:
		if direction.x < 0:
			get_node("Sprite").set_scale(Vector2(-0.5, 0.5))
			set_pos(get_pos() + Vector2(-60, 30))
		else:
			set_pos(get_pos() + Vector2(60, 30))
		get_node("AnimationPlayer").play("fire side")
	elif direction.y == 1:
		get_node("AnimationPlayer").play("fire down")
	elif direction.y == -1:
		get_node("AnimationPlayer").play("fire up")
	set_process( true )


func _process(delta):
	move( direction * SPEED )


# Pushes back if target is an enemy
func _on_Area2D_body_enter( body ):
	if body.is_in_group( "Player" ) and body != parent:
		# Target is pushed back
		body.push_direction = direction
		body.Slow(5,0.3)


# Resets the push factor when exiting enemy
func _on_Area2D_body_exit( body ):
	if body.is_in_group( "Player" ) and body != parent:
		body.push_direction = Vector2(0, 0)
		body.Slow(0.1,1)


# Dies when colliding with static objects
func _on_Area2D_static_body_enter( body ):
	if (!body.is_in_group( "Player" )):
		die()


func _on_LifeTimer_timeout():
	die()


func die():
	get_node("Area2D").queue_free()
	get_node( "AnimationPlayer" ).play( "die" )
	set_process( false )


func free_scn():
	queue_free()