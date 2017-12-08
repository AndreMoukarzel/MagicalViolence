
extends Node2D


func _ready():
	get_node( "SFX" ).play( "splash" )


func fire( direction, parent ):

	set_rot( direction.angle() )
	set_pos( parent.get_pos() + direction * 30 )

	get_node("Projectile1").fire(direction, parent)
	get_node("Projectile2").fire(projectileDirection(direction, -10), parent)
	get_node("Projectile3").fire(projectileDirection(direction, 10), parent)
	get_node("Projectile4").fire(projectileDirection(direction, -20), parent)
	get_node("Projectile5").fire(projectileDirection(direction, 20), parent)



func projectileDirection( direction, angle ):
	var a = deg2rad(angle)
	return Vector2 (direction.x * cos(a) + direction.y * sin(a), - direction.x * sin(a) + direction.y * cos(a))

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
