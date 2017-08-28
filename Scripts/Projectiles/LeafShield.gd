extends KinematicBody2D

const SPEED = 6

var direction = Vector2( 0, 0 )
var parent
var proj_count = 4
var leaf_count = 4

var leaves = [true, true, true, true]

var leafProj = preload("res://Scenes/Projectiles/LeafShieldProj.tscn")

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
	if leaf_count < proj_count:
		proj_count = leaf_count
	if leaf_count < 1:
		die()
	follow()


func activate():
#	get_node("AnimationPlayer").stop()
#	for child in get_children():
#		if child.has_method("fire"):
#			print(child.get_name())
#			child.fire(Vector2(1,1))
	if (leaf_count > 0) and (proj_count > 0):
		var id
		for i in range(4):
			if leaves[i] == true:
				id = i
				break
		print (id)
		shoot_leaf(id)
		proj_count -= 1
#			get_node("LeafShieldProj1").queue_free()
#			var leaf = leafProj.instance()
#			leaf.set_pos(self.parent.get_pos())
#			leaf.start(parent, self)
#			leaf.fire(self.direction, self.parent)
#			get_parent().add_child( leaf )

func shoot_leaf(id):
	get_node(str("LeafShieldProj", id+1)).queue_free()
	var leaf = leafProj.instance()
	leaf.set_pos(self.parent.get_pos())
	leaf.start(parent, self)
	leaf.fire(self.direction, self.parent)
	get_parent().add_child(leaf)
	leaves[id] = false

func leaf_death():
	leaf_count -= 1
	if leaf_count == 0:
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
