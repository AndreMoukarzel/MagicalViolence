extends KinematicBody2D

func fire( direction, parent ):
#	self.direction = direction
#	self.parent = parent
	
	get_node("LeafShieldProj").parent = parent
	get_node("LeafShieldProj1").parent = parent
	get_node("LeafShieldProj2").parent = parent
	get_node("LeafShieldProj3").parent = parent
#	add_collision_exception_with( parent )
	set_pos( parent.get_pos() )
	set_process( true )
	pass

func follow(parent):
	self.pos = parent.pos

func _fixed_process(delta):
	follow(parent)