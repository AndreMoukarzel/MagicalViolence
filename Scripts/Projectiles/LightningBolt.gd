extends "Projectile.gd"

var parent
const DAMAGE = 20
var element = 0 # Lightning = 0, Nature = 1, Fire = 2, Water = 3
var level = 3


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
			body.take_damage(DAMAGE)
			body.Stun(1.5)


#func _on_Area2D_area_enter( area ):
#	var other = area.get_parent()
#
#	if "element" in other: # Makes shure it's something interactable with projectile
#		if other.element == 2: # Oposing element
#			die()
#		elif other.element == 1: # Weak element
#			return
#		else:
#			if other.level >= level:
#				queue_free()


func free_scn():
	queue_free()
