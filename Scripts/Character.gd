
extends KinematicBody2D

const RUN_SPEED = 4

signal death

var input_states = preload("res://Scripts/input_states.gd")

# We use the port, because actions are named ending on port,
# and port - device_id association is made on the InputMap before
# each game.
var controller_port = 0

var btn_magic = input_states.new(name_adapter("char_magic"))
var btn_melee = input_states.new(name_adapter("char_melee"))

var current_anim = "idle_down"
onready var anim_player = get_node("Sprite/AnimationPlayer")
onready var glow_player = get_node("Sprite/Glow/AnimationPlayerGlow")


var current_direction = Vector2( 0, 1 )

var magic_element = ""
var current_spell
var charge = 0
var current_spell_charge = 0
# Doesn't represent level 3. A level 3 spell is ready when
# this variable is 2 and chargeBar has a value >= max_charge
var current_spell_level = 1
var ready_to_spell = true
var holding_spell = false
var is_stunned = false
var is_rooted = false
var active_proj
var slow_multiplier = 1
var push_direction = Vector2(0, 0)
var damage_per_sec = 0

var health = 100

var wait = 0
# Spells
# Fire
var firebolt_scn = preload("res://Scenes/Projectiles/Firebolt.tscn")
var scorching_scn = preload("res://Scenes/Projectiles/ScorchingMissile.tscn")
var fireball_scn = preload("res://Scenes/Projectiles/Fireball.tscn")
var f_charge = [30, 120]
var f_cd = [0.2, 0.5, 1.5]
# Water
var watersplash_scn = preload("res://Scenes/Projectiles/WaterSplash.tscn")
var watersphere_scn = preload("res://Scenes/Projectiles/WaterSphere.tscn")
var tidalwave_scn = preload("res://Scenes/Projectiles/TidalWave.tscn")
var w_charge = [40, 90]
var w_cd = [0.7, 1, 1.5]
# Nature
var leafshield_scn = preload("res://Scenes/Projectiles/LeafShield.tscn")
var conjurethorns_scn = preload("res://Scenes/Projectiles/ConjureThorns.tscn")
var graspingvine_scn = preload("res://Scenes/Projectiles/GraspingVine.tscn")
var n_charge = [40, 80]
var n_cd = [0.4, 0.6, 0.8]
# Lightning
var magnetbolt_scn = preload("res://Scenes/Projectiles/MagnetBolt.tscn")
var thunderbolt_scn = preload("res://Scenes/Projectiles/Thunderbolt.tscn")
var lightningbolt_scn = preload("res://Scenes/Projectiles/LightningBolt.tscn")
var l_charge = [60, 150]
var l_cd = [0.6, 0.8, 1]


func _ready():
	add_to_group("Player")
	
	# This is a port test.
	# The reassingment of btn_magic (and other future buttons)
	# may be necessary, though, because we only know of ports
	# after the game has started.
	# Having an _init would also be wise, for we may construct
	# the battle scene manually later.
	
	var node_name = self.get_name()
	controller_port = node_name.substr(node_name.length() - 1, node_name.length()).to_int()
	btn_magic = input_states.new(name_adapter("char_magic"))
	
	set_process(true)
	set_fixed_process(true)

	magic_element = "fire"
	get_node("ChargeBar").set_max(max_charge())


func _process(delta):
	
	################### MOVEMENT ###################

	var direction = Vector2( 0, 0 )
	var new_anim = ""
	
	if !is_stunned:
		if Input.is_action_pressed(name_adapter("char_left")):
			direction -= Vector2( 1, 0 )
		if Input.is_action_pressed(name_adapter("char_right")):
			direction += Vector2( 1, 0 )
		if Input.is_action_pressed(name_adapter("char_down")):
			direction += Vector2( 0, 1 )
		if Input.is_action_pressed(name_adapter("char_up")):
			direction -= Vector2( 0, 1 )
	
		if direction == Vector2( 0, 0 ):
			new_anim = str("idle_", current_anim.split("_")[1])
		else:
			current_direction = direction
			new_anim = define_anim(current_direction)
	
		# should take external forces into consideration
		if !is_rooted:
			var mot = move( direction.normalized()*RUN_SPEED*slow_multiplier + push_direction )
			
			if (is_colliding()):
				var n = get_collision_normal()
				mot = n.slide(mot)
				move(mot)
			
	
		################################################
		if !holding_spell:
			if Input.is_action_pressed(name_adapter("char_fire")):
				change_element("fire")
			if Input.is_action_pressed(name_adapter("char_water")):
				change_element("water")
			if Input.is_action_pressed(name_adapter("char_lightning")):
				change_element("lightning")
			if Input.is_action_pressed(name_adapter("char_nature")):
				change_element("nature")
	
		if ready_to_spell and charge > 0:
			if btn_magic.state() == input_states.NOT_PRESSED or btn_magic.state() == input_states.JUST_RELEASED:
				if active_proj == null:
					release_spell()
				else:
					active_proj.activate()
	
		update_anim( new_anim )
	take_damage(damage_per_sec * delta, self.get_pos())


func _fixed_process(delta):
	if !is_stunned:
		if btn_magic.state() == input_states.HOLD:
			if active_proj == null:
				charge += 1
				get_node("ChargeBar").set_value(charge - current_spell_charge)
				if get_node("ChargeBar").get_value() >= get_node("ChargeBar").get_max(): # Bar Maxed out
					if not get_node("AnimationPlayer").is_playing():
						get_node("AnimationPlayer").play("shake_charge_bar")
					update_max_charge()
			elif wait >= 15:
				active_proj.activate()
				wait = 0
	
		var cd_bar = get_node("CooldownBar")
		cd_bar.set_value( cd_bar.get_value() - 1 )
		
		if wait <= 15:
			wait += 1


func change_element( element ):
	var colors = {"fire":Color(1, 0, 0), "nature":Color(0, 1, 0), "water":Color(0, 0, 1), "lightning":Color(1, 1, 0)}

	if magic_element != element:
		get_node("Sprite/Glow").set_modulate(colors[element])
		get_node("ChargeBar").set_value(charge)
		magic_element = element
		charge = 0
		current_spell_charge = 0
		current_spell_level = 1
		get_node("ChargeBar").set_value(0)
		get_node("ChargeBar").set_max(max_charge())


func max_charge():
	if magic_element == "fire":
		if current_spell_charge == 0:
			return f_charge[0]
		return f_charge[1]
	elif magic_element == "water":
		if current_spell_charge == 0:
			return w_charge[0]
		return w_charge[1]
	if magic_element == "nature":
		if current_spell_charge == 0:
			return n_charge[0]
		return n_charge[1]
	else: # Lightning
		if current_spell_charge == 0:
			return l_charge[0]
		return l_charge[1]


func update_max_charge():
	if current_spell_level == 1:
		current_spell_charge = charge
		current_spell_level += 1
		
	var mc = max_charge()
	print ("Charge = ", charge, "  mc = ", mc)
	get_node("ChargeBar").set_max(mc)


# Returns what spell is suposed to be cast depending on
# magic_element and charge
func define_spell():
	if magic_element == "fire":
		if charge < f_charge[0]:
			return fireball_scn
		elif charge < f_charge[1]:
			return scorching_scn
		return firebolt_scn
	elif magic_element == "water":
		if charge < w_charge[0]:
			return watersplash_scn
		elif charge < w_charge[1]:
			return watersphere_scn
		return tidalwave_scn
	elif magic_element == "nature":
		if charge < n_charge[0]:
			return leafshield_scn
		elif charge < n_charge[1]:
			return conjurethorns_scn
		return graspingvine_scn
	else: # magic_element == lightning
		if charge < l_charge[0]:
			return magnetbolt_scn
		elif charge < l_charge[1]:
			return thunderbolt_scn
		return lightningbolt_scn


# Returns correct cooldown(in seconds) for spell
func define_cooldown(spell):
	if magic_element == "fire":
		if spell == fireball_scn:
			return f_cd[0]
		elif spell == scorching_scn:
			return f_cd[1]
		return f_cd[2]
	elif magic_element == "water":
		if spell == watersplash_scn:
			return w_cd[0]
		elif spell == watersphere_scn:
			return w_cd[1]
		return w_cd[2]
	elif magic_element == "nature":
		if spell == leafshield_scn:
			return n_cd[0]
		elif spell == conjurethorns_scn:
			return n_cd[1]
		return n_cd[2]
	else: # magic_element == eletricity
		if spell == magnetbolt_scn:
			return l_cd[0]
		elif spell == thunderbolt_scn:
			return l_cd[1]
		return l_cd[2]


func release_spell():
	var spell = define_spell()
	var projectile = spell.instance()
	projectile.fire( current_direction.normalized(), self )
	get_parent().add_child( projectile )

	# Resets spell
	ready_to_spell = false
	current_spell = spell
	if spell == leafshield_scn or spell == firebolt_scn: # spells that use activation
		holding_spell = true
		active_proj = projectile
	else:
		spell_ended()


func spell_ended(spell = current_spell):
	var cd = define_cooldown(spell)
	set_cooldown(cd)
	holding_spell = false
	current_spell = null
	active_proj = null


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
	current_spell_charge = 0
	current_spell_level = 1
	ready_to_spell = true

	get_node("CooldownBar").hide()
	get_node("ChargeBar").set_value(0)
	get_node("ChargeBar").set_max(max_charge())
	get_node("ChargeBar").show()


func Slow(time, multiplier):
	slow_multiplier = multiplier
	get_node( "SlowTimer" ).set_wait_time(time)
	get_node( "SlowTimer" ).start()


func Stun(time):
	is_stunned = true
	update_anim( str("idle_", current_anim.split("_")[1]) )
	get_node( "StunTimer" ).set_wait_time(time)
	get_node( "StunTimer" ).start()


func Root(time):
	is_rooted = true
	get_node( "RootTimer" ).set_wait_time(time)
	get_node( "RootTimer" ).start()


# Slow time is over
func _on_SlowTimer_timeout():
	slow_multiplier = 1


# Stun time is over
func _on_StunTimer_timeout():
	is_stunned = false


# Root time is over
func _on_RootTimer_timeout():
	is_rooted = false


func take_damage(damage, proj_knockback):
	health -= damage
	get_node("HealthBar").set_value(health)
	if health <= 0:
		die()
	if proj_knockback != self.get_pos():
		knockback(proj_knockback)


func knockback(proj_knockback):
	self.set_pos(self.get_pos() + proj_knockback * 10)
	pass


func die():
	emit_signal("death")
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
		glow_player.play(new_animation)
		current_anim = new_animation


################################################################

# Function that adds controller_port to the end of
# the name srnt, so that it can be understood by
# the input map.
func name_adapter(name):
	return str(name, "_", controller_port)

