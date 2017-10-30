extends KinematicBody2D

const SPEED = 0.25
const DAMAGE = 10
const ROOT_TIME = 1.5
var element = 2 # Fire = 0, Water = 1, Nature = 2, Electricity = 3
var level = 3

var direction = Vector2( 0, 0 )
var parent


func fire( direction, parent ):
	self.parent = parent
	self.direction = direction
	set_pos( parent.get_pos() )
	set_rot( direction.angle() )
	get_node( "AnimationPlayer" ).play( "fire" )


func _on_Area2D_body_enter( body ):
	if body != parent:
		if body.has_method("take_damage"):
			body.take_damage(DAMAGE)
			body.Root(ROOT_TIME)


func _on_Area2D_area_enter( area ):
	var other = area.get_parent()

	if "element" in other: # Makes shure it's something interactable with projectile
		if other.element == 0: # Oposing element
			die()
		elif other.element == 3: # Weak element
			return
		else:
			if other.level >= level:
				die()


func _on_LifeTimer_timeout():
	die()


func die():
	get_node("Area2D").queue_free()
	get_node("AnimationPlayer").play("death")


func free_scn():
	queue_free()

