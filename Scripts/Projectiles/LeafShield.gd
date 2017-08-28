extends KinematicBody2D

const SPEED = 6

var direction = Vector2( 0, 0 )
var parent
var proj_count = 0


func fire( direction, parent ):
	self.direction = direction
	self.parent = parent
	
	get_node("LeafShieldProj1").start( parent, self )
	get_node("LeafShieldProj2").start( parent, self )
	get_node("LeafShieldProj3").start( parent, self )
	get_node("LeafShieldProj4").start( parent, self )
	set_pos( parent.get_pos() )
	set_process( true )


func follow():
	set_pos(self.parent.get_pos())


func _process(delta):
	follow()


func activate():
	get_node("AnimationPlayer").stop()
	for child in get_children():
		if child.has_method("fire"):
			child.fire(Vector2(1,1))


func proj_death():
	proj_count += 1
	if proj_count >= 4:
		die()


func die():
	get_node("AnimationPlayer").stop()
	for child in get_children():
		if child.get_name() != "AnimationPlayer" and child.get_name() != "Timer":
			child.die()
	parent.spell_ended()
	set_process( false )
	get_node("Timer").start()


func _on_Timer_timeout():
	queue_free()