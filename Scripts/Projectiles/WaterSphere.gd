
extends "Projectile.gd"

var SPEED = 3
const DAMAGE = 20
const KNOCKBACK = 50
var element = 3 # Lightning = 0, Nature = 1, Fire = 2, Water = 3
var level = 2

var direction = Vector2( 0, 0 ) # direction that the fireball flies to
var parent


func _ready():
	get_node( "SFX" ).play( "bubble" )


func fire( direction, parent ):
	self.direction = direction
	self.parent = parent
	set_pos( parent.get_pos() )
	set_process( true )


func _process(delta):
	move( direction * SPEED )
	SPEED -= 0.75*delta
	if (SPEED <= 0):
		die()


# does damage if take damage function exists in body
func _on_Area2D_body_enter( body ):
	if body != parent:
		if body.has_method("take_damage"):
			body.take_damage(DAMAGE, self.direction, KNOCKBACK)
		if body.has_method("Slow"):
			# Applies slow effect 
			body.Slow(2, 0.4)
		die()


func die():
	get_node("Area2D").queue_free()
	get_node( "AnimationPlayer" ).play( "death" )
	set_process( false )


func free_scn():
	queue_free()
