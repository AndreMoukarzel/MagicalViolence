
extends "Projectile.gd"

const SPEED = 8
const DAMAGE = 7
const KNOCKBACK = 20
var element = 2 # Lightning = 0, Nature = 1, Fire = 2, Water = 3
var level = 1

var direction = Vector2( 0, 0 ) # direction that the fireball flies to
var parent


func _ready():
	get_node( "SFX" ).play( "fire" )


func fire( direction, parent ):
	self.direction = direction
	self.parent = parent
	set_pos( parent.get_pos() )
	set_rot( direction.angle() )
	set_process( true )


func _process(delta):
	move( direction * SPEED )


# does damage if take damage function exists in body
func _on_Area2D_body_enter( body ):
	if body != parent:
		get_node("Area2D").queue_free()
		if body.has_method("take_damage"):
			body.take_damage(DAMAGE, self.direction, KNOCKBACK)
		die()


func _on_LifeTimer_timeout():
	die()


func die():
	get_node( "SFX" ).play( "fireball" )
	get_node( "Area2D" ).queue_free()
	get_node("LifeTimer").queue_free()
	get_node( "AnimationPlayer" ).play( "death" )
	set_process( false )


func free_scn():
	queue_free()