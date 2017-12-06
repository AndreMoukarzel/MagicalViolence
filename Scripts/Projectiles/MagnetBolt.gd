extends "Projectile.gd"

var SPEED = 10
const DAMAGE = 5
var ROT_SPEED = 3
var element = 0 # Lightning = 0, Nature = 1, Fire = 2, Water = 3
var level = 1

var direction = Vector2( 0, 0 ) # direction that the fireball flies to
var angle
var parent
var state = "going"


func fire( direction, parent ):
	self.direction = direction
	self.parent = parent
	set_pos( parent.get_pos() )
	set_process( true )


func _process(delta):
	if !weakref(parent).get_ref(): # parent was freed
		parent = null
		die()
		return

	if SPEED <= 0:
		state = "returning"
		angle = get_angle_to( parent.get_pos() )
		# negative cos and sin because speed is also negative
		direction = Vector2( -sin(angle), -cos(angle) )
	get_node( "Sprite" ).rotate( ROT_SPEED * delta )

	move( direction * SPEED )
	SPEED -= 8*delta


# does damage if take damage function exists in body
func _on_Area2D_body_enter( body ):
	if body != parent:
		if body.has_method("take_damage"):
			body.take_damage(DAMAGE, null)
	elif state == "returning":
		die()


func die():
	get_node( "AnimationPlayer" ).play( "death" )
	get_node("Area2D").queue_free()
	set_process( false )


func free_scn():
	queue_free()