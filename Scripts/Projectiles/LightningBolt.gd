extends "Projectile.gd"

const DAMAGE = 20
var element = 0 # Lightning = 0, Nature = 1, Fire = 2, Water = 3
var level = 3

var parent


func _ready():
	get_node( "SFX" ).play( "thunder" )


func fire( direction, parent ):
	self.parent = parent
	get_node( "AnimatedSprite" ).set_frame(0)
	set_rot( direction.angle() )
	set_pos( parent.get_pos() )
	get_node( "AnimationPlayer" ).play( "fire" )
	get_node( "Area2D" ).queue_free()


# Damages and stuns if target is an enemy
func _on_Area2D_body_enter( body ):
	if body != parent:
		if body.has_method("take_damage"):
			body.take_damage(DAMAGE, null)
			body.Stun(1.5)


func die():
	queue_free()


func free_scn():
	queue_free()