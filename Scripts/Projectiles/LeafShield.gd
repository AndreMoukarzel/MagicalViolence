extends KinematicBody2D

const SPEED = 6

var direction = Vector2( 0, 0 )
var parent
var proj_count = 4
var leaf_count = 4

var leaves = [true, true, true, true]

var leafProj = preload("res://Scenes/Projectiles/LeafShieldProj.tscn")

var angle = 0

var c = Color(1, 0.5, 0.2)

func fire( direction, parent ):
	self.parent = parent
	
	get_node("LeafShieldProj1").start( parent, self, 1 )
	get_node("LeafShieldProj2").start( parent, self, 2 )
	get_node("LeafShieldProj3").start( parent, self, 3 )
	get_node("LeafShieldProj4").start( parent, self, 4 )
	set_pos( parent.get_pos() )
	next_leaf()
	set_process( true )


func follow():
	if !weakref(parent).get_ref(): # parent was freed
		parent = null
		die()
		return
	set_pos(self.parent.get_pos())


func spin_leaves(delta):
	var leaf
	var a
	var x
	var y
	angle += delta*5
	for i in range(4):
		if (leaves[i] == true):
			leaf = get_node(str("LeafShieldProj", i+1))
			a = angle + (i+1)*PI/2
			x = 25*sin(a)
			y = 25*cos(a)
			leaf.set_pos(Vector2(x, y))
			# Rotates the leaves along with their movement around the character
			leaf.set_rotd( rad2deg( Vector2(x, y).angle() ) + 90)


func _process(delta):
	if leaf_count < proj_count:
		proj_count = leaf_count
	if leaf_count < 1:
		die()
	spin_leaves(delta)
	follow()
	self.direction = self.parent.current_direction.normalized()


func activate():
	for i in range (4):
		if (leaves[i] == true):
			shoot_leaf(i+1)
			break


func next_leaf():
	for i in range (4):
		if (leaves[i] == true):
			get_node(str("LeafShieldProj", i+1, "/Sprite")).set_modulate(c)
			break


func shoot_leaf(id):
	print ("id = ", id)
	var leaf = get_node(str("LeafShieldProj", id))
	var pos = leaf.get_pos() + self.get_pos()
	remove_child(leaf)
	print (get_parent().get_name())
	get_parent().add_child(leaf)
	leaf.set_pos(pos)
	leaf.fire(self.direction, self.parent)
	leaves[id-1] = false
	leaf_count -= 1
	next_leaf()


func leaf_death(id):
	leaf_count -= 1
	if leaf_count == 0:
		die()
	leaves[id] = false
	next_leaf()


func die():
	set_process( false )
	if weakref(parent).get_ref(): # parent was not freed
		parent.spell_ended()
	for child in get_children():
		if child.get_name() != "AnimationPlayer" and child.get_name() != "Timer":
			child.die()
	get_node("AnimationPlayer").play("death")
	yield( get_node("AnimationPlayer"), "finished")
	queue_free()


func _on_Timer_timeout():
	leaf_count = 0
	die()