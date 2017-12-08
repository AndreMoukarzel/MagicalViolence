extends KinematicBody2D

const SPEED = 0.25
const DAMAGE = 10
const ROOT_TIME = 1.5
var element = 1 # Lightning = 0, Nature = 1, Fire = 2, Water = 3
var level = 3

var direction = Vector2( 0, 0 )
var parent


func _ready():
	get_node( "SFX" ).play( "vines" )


func fire( direction, parent ):
	self.parent = parent
	self.direction = direction
	set_pos( parent.get_pos() )
	set_rot( direction.angle() )
	get_node( "AnimationPlayer" ).play( "fire" )


func _on_Area2D_body_enter( body ):
	if body != parent:
		if body.has_method("take_damage"):
			body.take_damage(DAMAGE, null)
			body.Root(ROOT_TIME)


func _on_Area2D_area_enter( area ):
	var other = area.get_parent()
	
	# Makes sure it's something interactable with projectile
	if "element" in other:
		if other.level > level:
			die()
		elif other.element == 0: # Opposing element
			die()


func _on_LifeTimer_timeout():
	die()


func die():
	get_node("Area2D").queue_free()
	get_node("AnimationPlayer").play("death")


func free_scn():
	queue_free()

