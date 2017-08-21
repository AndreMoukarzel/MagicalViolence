
extends Node2D

const SPEED = 6



func fire( direction, parent ):

	set_rot( direction.angle() )
	set_pos( parent.get_pos() + direction * 30 )

	get_node("Projectile1").fire(direction, parent)
	get_node("Projectile2").fire(direction, parent)
	get_node("Projectile3").fire(direction, parent)
	get_node("Projectile4").fire(direction, parent)
	get_node("Projectile5").fire(direction, parent)


# murders all children
func die():
	for child in get_children():
		if child.has_method("die"):
			child.die()
	set_process( false )


func _on_LifeTimer_timeout():
	die()


func _on_FreeTimer_timeout():
	queue_free()
