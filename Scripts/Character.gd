
extends KinematicBody2D

const RUN_SPEED = 4

var input_states = preload("res://Scripts/input_states.gd")

var btn_magic = input_states.new("ui_magic")
var btn_melee = input_states.new("ui_melee")

var current_anim = "idle_down"
onready var anim_player = get_node("Sprite/AnimationPlayer")

var current_direction = Vector2( 0, 1 )

var magic
var charge = 0
var ready_to_spell = true

var health = 100

# Spells
var fireball_scn = preload("res://Scenes/Projectiles/Fireball.tscn")
var scorching_scn = preload("res://Scenes/Projectiles/ScorchingMissile.tscn")
var watersplash_scn = preload("res://Scenes/Projectiles/WalterSplash.tscn")


func _ready():
	add_to_group("Player")
	set_process(true)
	set_fixed_process(true)

	magic = watersplash_scn


func _process(delta):
	################### MOVEMENT ###################

	var direction = Vector2( 0, 0 )
	var new_anim
	
	if Input.is_action_pressed("ui_left"):
		direction -= Vector2( RUN_SPEED, 0 )
		new_anim = "run_left"
	if Input.is_action_pressed("ui_right"):
		direction += Vector2( RUN_SPEED, 0 )
		new_anim = "run_right"
	if Input.is_action_pressed("ui_up"):
		direction -= Vector2( 0, RUN_SPEED )
		new_anim = "run_up"
	if Input.is_action_pressed("ui_down"):
		direction += Vector2( 0, RUN_SPEED )
		new_anim = "run_down"

	if direction == Vector2( 0, 0 ):
		# Temporary solution to this issue, will probably be
		# replaced when other animations come into play.
		new_anim = str("idle_", current_anim.split("_")[1])
	else:
		current_direction = direction / RUN_SPEED

	# should take external forces into consideration
	move( direction )

	################################################

	if ready_to_spell and charge > 0:
		if btn_magic.state() == 0 or btn_magic.state() == 3:
			release_spell()

	update_anim( new_anim )


func _fixed_process(delta):
	if btn_magic.state() == 2:
		charge += 1
		get_node("ChargeBar").set_value(charge)
		if charge >= 50:
			magic = scorching_scn

	var cd_bar = get_node("CooldownBar")
	cd_bar.set_value( cd_bar.get_value() - 1 )


func release_spell():
	var spell = magic.instance()
	spell.fire( current_direction, self )
	get_parent().add_child( spell )

	# Resets spell
	ready_to_spell = false
	set_cooldown(0.5) # set cooldown DEPENDING oN SpElL
	magic = fireball_scn


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

func update_anim( new_animation ):
	current_anim = anim_player.get_current_animation()

	if new_animation != current_anim:
		anim_player.play(new_animation)

