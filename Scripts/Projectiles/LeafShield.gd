extends KinematicBody2D

const SPEED = 6

var direction = Vector2( 0, 0 )
var parent
var shoot = false
var proj_count = 0

func _ready():
	set_fixed_process(true)

func fire( direction, parent ):
	if not shoot:
		prepare(direction, parent)
	else:
		pass

func follow():
	set_pos(self.parent.get_pos())

func _fixed_process(delta):
	follow()

# Create the leaf shield
func prepare (direction, parent):
	self.direction = direction
	self.parent = parent
	
	get_node("LeafShieldProj1").parent = parent
	get_node("LeafShieldProj2").parent = parent
	get_node("LeafShieldProj3").parent = parent
	get_node("LeafShieldProj4").parent = parent
#	add_collision_exception_with( parent )
	set_pos( parent.get_pos() )
	set_process( true )
	shoot = true

#func shoot():
#	if proj_count == 0:
#		get_node("LeafShieldProj1").set_pos(self.parent.get_pos())
#		get_node("LeafShieldProj1").move(direction * SPEED)
#	proj_count = proj_count + 1
#	if proj_count == 4:
#		shoot = false
#	pass