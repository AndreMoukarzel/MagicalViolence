
extends "Projectile.gd"

const SPEED = 6
const DAMAGE = 30
var element = 2 # Lightning = 0, Nature = 1, Fire = 2, Water = 3
var level = 3

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


# does damage if take damage function exists in body
func _on_Area2D_body_enter( body ):
	print ("é um corpo safado")
	if body != parent:
		if body.has_method("take_damage"):
			body.take_damage(DAMAGE)
		if alive:
			die()


func _on_LifeTimer_timeout():
	die()


func _on_Trail_Timer_timeout():
	if (alive):
		var Trail_scn = preload("res://Scenes/Projectiles/FireTrail.tscn")
		var Trail = Trail_scn.instance()
		Trail.set_pos(get_pos())
		get_parent().add_child(Trail)


func activate():
	die()


func die():
	alive = false
	get_node( "AnimationPlayer" ).play( "explosion" )
	parent.spell_ended() # Alerts player that spell is finished
	set_process( false )


func free_scn():
	queue_free()
