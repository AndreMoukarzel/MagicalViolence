extends "Projectile.gd"

const SPEED = 10
const DAMAGE = 4
var element = 1 # Lightning = 0, Nature = 1, Fire = 2, Water = 3
var level = 1

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
	get_node("AnimationPlayer").play("spin")
	set_process( true )


func _process(delta):
	move( direction * SPEED )


# does damage if take damage function exists
func _on_Area2D_body_enter( body ):
	if body != parent:
		get_node("Area2D").queue_free()
		if body.has_method("take_damage"):
			body.take_damage(DAMAGE)
		die()


#func _on_Area2D_area_enter( area ):
#	var other = area.get_parent()
#
#	if "parent" in other:
#		if parent == other.parent:
#			return
#
#	if "element" in other: # Makes shure it's something interactable with projectile
#		if other.element == 0: # Oposing element
#			die()
#		elif other.element == 3: # Weak element
#			return
#		else:
#			if other.level >= level:
#				die()


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