
extends "Projectile.gd"

const SPEED = 7
const DAMAGE = 35
const KNOCKBACK = 70
var element = 2 # Lightning = 0, Nature = 1, Fire = 2, Water = 3
var level = 3

var direction = Vector2( 0, 0 ) # direction that the fireball flies to
var parent
var alive = true


func _ready():
	get_node( "SFX" ).play( "fire" )


func fire( direction, parent ):
	self.direction = direction
	self.parent = parent
	set_pos( parent.get_pos() )
	set_process( true )


func _process(delta):
	move( direction * SPEED )


# does damage if take damage function exists in body
func _on_Area2D_body_enter( body ):
	if body != parent:
		if body.has_method("take_damage"):
			body.take_damage(DAMAGE, self.direction, KNOCKBACK)
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
	get_node( "SFX" ).play( "firebolt" )
	get_node( "AnimationPlayer" ).play( "explosion" )
	set_process( false )
	if !weakref(parent).get_ref(): # Parent was freed
		return
	parent.spell_ended() # Alerts player that spell is finished


func free_scn():
	queue_free()
