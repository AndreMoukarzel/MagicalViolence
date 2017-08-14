
extends Node2D

const SPEED = 6

var direction = Vector2( 0, 0 ) # direction that the fireball flies to
var parent

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	pass


func fire( direction, parent ):
	self.direction = direction
	self.parent = parent
#	add_collision_exception_with( parent )
	set_pos( parent.get_pos() )
	set_process( true )


func _on_LifeTimer_timeout():
	die()


func die():
	for child in get_children():
		if child.has_node( "AnimationPlayer" ):
			child.get_node( "AnimationPlayer" ).play( "death" )
	set_process( false )


func _on_FreeTimer_timeout():
	queue_free()
