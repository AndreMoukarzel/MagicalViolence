
extends KinematicBody2D

var SPEED = 2.5
const DAMAGE = 15
var element = 1 # Fire = 0, Water = 1, Nature = 2, Electricity = 3
var level = 2

var direction = Vector2( 0, 0 ) # direction that the fireball flies to
var parent


func fire( direction, parent ):
	self.direction = direction
	self.parent = parent
#	add_collision_exception_with( parent )
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
		get_node("Area2D").queue_free()
		if body.has_method("take_damage"):
			body.take_damage(DAMAGE)
		if body.has_method("Slow"):
			# Applies slow effect 
			body.Slow(2, 0.4)
			
		die()


func _on_Area2D_area_enter( area ):
	var other = area.get_parent()

	if "element" in other: # Makes shure it's something interactable with projectile
		if other.element == 2: # Oposing element
			die()
		elif other.element == 0: # Weak element
			return
		else:
			if other.level >= level:
				queue_free()


func die():
	get_node( "AnimationPlayer" ).play( "death" )
	set_process( false )


func free_scn():
	queue_free()
