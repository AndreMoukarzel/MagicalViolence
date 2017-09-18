extends KinematicBody2D

const SPEED = 6

var direction = Vector2( 0, 0 ) # direction that the fireball flies to
var parent
var owner
var shot = false
var id

func start( parent, owner, id ):
	self.parent = parent
	self.owner = owner
	self.id = id

func fire( direction, parent = parent ):
	self.direction = direction
	self.parent = parent
	self.shot = true
	get_node("LifeTimer").start()
	set_scale(Vector2(1.5, 1.5))
	set_process( true )

func _process(delta):
	move( direction * SPEED )

# does damage if take damage function exists
func _on_Area2D_body_enter( body ):
	if body != parent:
		get_node("Area2D").queue_free()
		if body.has_method("take_damage"):
			body.take_damage(4)
		die()


func _on_LifeTimer_timeout():
	die()


func die():
	if get_node( "AnimationPlayer" ).get_current_animation() != "death":
		get_node( "AnimationPlayer" ).play( "death" )
		if (not shot):
			owner.leaf_death(id-1)
	set_process( false )


func free_scn():
	queue_free()