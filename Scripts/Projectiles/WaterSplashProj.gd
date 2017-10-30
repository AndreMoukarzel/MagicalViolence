
extends KinematicBody2D

const SPEED = 8
const DAMAGE = 4
var element = 1 # Fire = 0, Water = 1, Nature = 2, Electricity = 3
var level = 1

var direction = Vector2( 0, 0 ) # direction that the fireball flies to
var parent


func fire( direction, parent ):
	self.direction = direction
	self.parent = parent

	set_process( true )


func _process(delta):
	move( direction * SPEED )


# does damage if take damage function exists
func _on_Area2D_body_enter( body ):
	if body != parent:
		get_node("Area2D").queue_free()
		if body.has_method("take_damage"):
			body.take_damage(DAMAGE)
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
	if get_node( "AnimationPlayer" ).get_current_animation() != "death":
		get_node( "AnimationPlayer" ).play( "death" )
	set_process( false )


func free_scn():
	queue_free()