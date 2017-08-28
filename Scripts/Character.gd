
extends KinematicBody2D

const RUN_SPEED = 4

var input_states = preload("res://Scripts/input_states.gd")

# Id has to coincide with port, in our model
var controller_id = 0

var btn_magic = input_states.new(name_adapter("char_magic"))
var btn_melee = input_states.new(name_adapter("char_melee"))

var current_anim = "idle_down"
onready var anim_player = get_node("Sprite/AnimationPlayer")

var current_direction = Vector2( 0, 1 )

var magic_element = ""
var charge = 0
var ready_to_spell = true

var health = 100

# Spells
# Fire
var firebolt_scn = preload("res://Scenes/Projectiles/Firebolt.tscn")
var scorching_scn = preload("res://Scenes/Projectiles/ScorchingMissile.tscn")
var fireball_scn = preload("res://Scenes/Projectiles/Fireball.tscn")
# Water
var watersplash_scn = preload("res://Scenes/Projectiles/WaterSplash.tscn")
var watersphere_scn = preload("res://Scenes/Projectiles/WaterSphere.tscn")
var tidalwave_scn = preload("res://Scenes/Projectiles/TidalWave.tscn")
# Nature
var leafshield_scn = preload("res://Scenes/Projectiles/LeafShield.tscn")
# Lightning
var magnetbolt_scn = preload("res://Scenes/Projectiles/MagnetBolt.tscn")


func _ready():
	add_to_group("Player")
	
	#test
	var node_name = self.get_name()
	controller_id = node_name.substr(node_name.length() - 1, node_name.length()).to_int()
	btn_magic = input_states.new(name_adapter("char_magic"))
	
	set_process(true)
	set_fixed_process(true)

	magic_element = "water"


func _process(delta):
	################### MOVEMENT ###################

	var direction = Vector2( 0, 0 )
	var new_anim = ""
	
	if Input.is_action_pressed(name_adapter("char_left")):
		direction -= Vector2( RUN_SPEED, 0 )
	if Input.is_action_pressed(name_adapter("char_right")):
		direction += Vector2( RUN_SPEED, 0 )
	if Input.is_action_pressed(name_adapter("char_down")):
		direction += Vector2( 0, RUN_SPEED )
	if Input.is_action_pressed(name_adapter("char_up")):
		direction -= Vector2( 0, RUN_SPEED )

	if direction == Vector2( 0, 0 ):
		new_anim = str("idle_", current_anim.split("_")[1])
	else:
		current_direction = direction / RUN_SPEED
		new_anim = define_anim(current_direction)

	# should take external forces into consideration
	move( direction )

	################################################

	if Input.is_action_pressed(name_adapter("char_fire")):
		change_element("fire")
	if Input.is_action_pressed(name_adapter("char_water")):
		change_element("water")
	if Input.is_action_pressed(name_adapter("char_lightning")):
		change_element("lightning")
	if Input.is_action_pressed(name_adapter("char_nature")):
		change_element("nature")

	if ready_to_spell and charge > 0:
		if btn_magic.state() == 0 or btn_magic.state() == 3:
			release_spell()

	update_anim( new_anim )


func _fixed_process(delta):
	if btn_magic.state() == 2:
		charge += 1
		get_node("ChargeBar").set_value(charge)

	var cd_bar = get_node("CooldownBar")
	cd_bar.set_value( cd_bar.get_value() - 1 )


func change_element( element ):
	if magic_element != element:
		charge = 0
		get_node("ChargeBar").set_value(charge)
		magic_element = element


# Returns what spell is suposed to be cast depending on
# magic_element and charge
func define_spell():
	if magic_element == "fire":
		if charge < 50:
			return fireball_scn
		elif charge < 100:
			return scorching_scn
		return firebolt_scn
	elif magic_element == "water":
		if charge < 50:
			return watersplash_scn
		elif charge < 100:
			return watersphere_scn
		return tidalwave_scn
	elif magic_element == "nature":
		if charge < 50:
			return leafshield_scn
		elif charge < 100:
			return scorching_scn
		return firebolt_scn
	else: # magic_element == eletricity
		if charge < 50:
			return magnetbolt_scn
		elif charge < 100:
			return scorching_scn
		return firebolt_scn


# Returns correct cooldown(in seconds) for spell
func define_cooldown(spell):
	if magic_element == "fire":
		if spell == fireball_scn:
			return 0.5
		elif spell == scorching_scn:
			return 1
		return 2
	elif magic_element == "water":
		if spell == watersplash_scn:
			return 0.5
		elif spell == watersphere_scn:
			return 1
		return 2
	elif magic_element == "nature":
		if spell == leafshield_scn:
			return 0.5
		elif spell == scorching_scn:
			return 1
		return 2
	else: # magic_element == eletricity
		if spell == magnetbolt_scn:
			return 0.5
		elif spell == scorching_scn:
			return 1
		return 2


func release_spell():
	var spell = define_spell()
	var projectile = spell.instance()
	projectile.fire( current_direction, self )
	get_parent().add_child( projectile )

	# Resets spell
	ready_to_spell = false
	var cd = define_cooldown(spell)
	set_cooldown(cd)


func set_cooldown(time):
	var cd_timer = get_node("Cooldown")
	var cd_bar = get_node("CooldownBar")

	cd_timer.set_wait_time(time)
	cd_timer.start()

	# Display cooldown bar
	get_node("ChargeBar").hide()
	cd_bar.show()
	cd_bar.set_max(time * 60)
	cd_bar.set_value(cd_bar.get_max())


# Spell cooldown is over
func _on_Cooldown_timeout():
	charge = 0
	ready_to_spell = true

	get_node("CooldownBar").hide()
	get_node("ChargeBar").set_value(charge)
	get_node("ChargeBar").show()


func take_damage(damage):
	health -= damage
	get_node("HealthBar").set_value(health)
	if health <= 0:
		die()


func die():
	queue_free()


########################## ANIMATIONS ##########################

func define_anim( direction ):
	if direction.x == 1:
		if direction.y == 1:
			return "run_downright"
		if direction.y == -1:
			return "run_upright"
		return "run_right"
	if direction.x == -1:
		if direction.y == 1:
			return "run_downleft"
		if direction.y == -1:
			return "run_upleft"
		return "run_left"
	if direction.y == 1:
		return "run_down"
	if direction.y == -1:
		return "run_up"


func update_anim( new_animation ):
	current_anim = anim_player.get_current_animation()

	if new_animation != current_anim:
		anim_player.play(new_animation)
		current_anim = new_animation

################################################################

# Function that adds controller_id to the end of
# the name srnt, so that it can be understood by
# the input map.
func name_adapter(name):
	return str(name, "_", controller_id)
