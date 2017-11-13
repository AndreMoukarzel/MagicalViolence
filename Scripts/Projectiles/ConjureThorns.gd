extends "Projectile.gd"

const SPEED = 6
const DAMAGE = 15
var element = 1 # Lightning = 0, Nature = 1, Fire = 2, Water = 3
var level = 2

var direction = Vector2( 0, 0 ) # direction that the seed flies to
var parent
var is_seed = true


func fire( direction, parent ):
	self.direction = direction
	self.parent = parent
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
			# If the thorns are grown, play death animation
			# when enemy enters them. Otherwise, the seed just
			# disappears dealing damage
			if !is_seed:
				body.take_damage(2 * DAMAGE)
				_on_LifeTimer_timeout()
			else:
				body.take_damage(DAMAGE)
				die()


func _on_GrowTimer_timeout():
	get_node( "LifeTimer" ).start()
	is_seed = false
	grow()


# Projectile stops moving and expands
func grow():
	set_process( false )
	get_node( "AnimationPlayer" ).play( "grow" )
	get_node("Area2D").set_scale(Vector2(2.5, 2.5))


func _on_LifeTimer_timeout():
	get_node("LifeTimer").queue_free()
	get_node( "AnimationPlayer" ).play( "die" )
	yield( get_node("AnimationPlayer"), "finished")
	die()


func die():
	get_node("Area2D").queue_free()
	queue_free()