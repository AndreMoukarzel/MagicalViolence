extends KinematicBody2D

const SPEED = 4
const DAMAGE = 15
const STUN_TIME = 1
var element = 0 # Lightning = 0, Nature = 1, Fire = 2, Water = 3
var level = 2

var direction = Vector2( 0, 0 ) # direction that the cloud flies to
var parent


func fire( direction, parent ):
	self.direction = direction
	self.parent = parent
	get_node( "AnimatedSprite" ).play( "cloud" )
	set_pos( parent.get_pos() )
	get_node( "AnimatedSprite" ).set_scale( Vector2(0.26, 0.26 ) )
	get_node( "AnimatedSprite" ).set_pos( Vector2(0, 0 ) )
	set_process( true )


func _process(delta):
	move( direction * SPEED )


# does damage if take damage function exists in body
func _on_Detection_body_enter( body ):
	if body != parent:
		set_pos( body.get_pos() )
		get_node( "Detection" ).queue_free()
		get_node( "DelayTimer" ).start()
		die()


func _on_Detection_area_enter( area ):
	var other = area.get_parent()

	if "element" in other: # Makes shure it's something interactable with projectile
		if other.element == 2: # Oposing element
			die()
		elif other.element == 1: # Weak element
			return
		else:
			if other.level >= level:
				die()


func _on_LifeTimer_timeout():
	die()


func _on_DelayTimer_timeout():
	get_node( "AnimatedSprite" ).stop()
	
	get_node( "AnimationPlayer" ).play( "thunder" )
	
	for body in get_node( "Damage" ).get_overlapping_bodies():
		if body != parent and body.has_method("take_damage"):
			body.take_damage(DAMAGE)
			body.Stun(STUN_TIME)
	get_node( "Damage" ).queue_free()


func die():
	queue_free()


func free_scn():
	queue_free()