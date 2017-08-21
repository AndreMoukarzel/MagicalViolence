
extends KinematicBody2D

const SPEED = 6

var direction = Vector2( 0, 0 ) # direction that the fireball flies to
var parent
var alive = true

func fire( direction, parent ):
	self.direction = direction
	self.parent = parent
#	add_collision_exception_with( parent )
	set_pos( parent.get_pos() )
	set_process( true )


func _process(delta):
	move( direction * SPEED )
	


func _on_Area2D_body_enter( body ):
	# does damage if take damage function exists
	# dies out
	if body != parent:
		if body.has_method("take_damage"):
			body.take_damage(30)
#			get_node( "AnimationPlayer" ).play( "explosion" )
		if (alive):
			explosion()


func _on_LifeTimer_timeout():
	explosion()


func _on_Trail_Timer_timeout():
	if (alive):
		var Trail_scn = preload("res://Scenes/Projectiles/FireTrail.tscn")
		var Trail = Trail_scn.instance()
		Trail.set_pos(get_pos())
		get_parent().add_child(Trail)
	
	
func explosion():
	alive = false
	get_node( "AnimationPlayer" ).play( "explosion" )
	set_process( false )


func free_scn():
	queue_free()
