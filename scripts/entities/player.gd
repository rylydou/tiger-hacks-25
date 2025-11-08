class_name Player extends CharacterBody2D


@export var o2 := 10.0
@onready var o2_max := o2

@export var camera: Camera2D
@export var home_arrow_anchor: Node2D
@export var fuel_bar: ProgressBar
@export var o2_bar: ProgressBar
@export var jetpack_vfx: GPUParticles2D

@export_group("Jetpack", "jetpack_")

@export var jetpack_boost_accel := 10.0
@export var jetpack_max_speed := 100.0
@export var jetpack_fuel_time := 1.0
@onready var jetpack_fuel_left := jetpack_fuel_time
@export var jetpack_o2_to_fuel_ratio := 1.0

@export_group("Space Movement", "space_")

@export var space_rotation_speed := 1.0
## Will slightly nudge your velocity angle to your current angle over time
@export var space_jetpack_steering_assist_over_time := 0.0
## Will slightly nudge your velocity angle to your current angle when turning
@export var space_jetpack_steering_assist_manual := 0.0

@export var space_decel_linear := 0.0
@export var space_decel_mult := 1.0


@export_group("Planet Movement", "planet_")

@export var planet_move_speed := 100.0
@export var planet_max_move_speed := 100.0
@export var planet_move_accel_air := 100.0
@export var planet_move_accel_ground := 100.0
@export var planet_jump_velocity = 500.0

@export var planet_decel_air_linear := 0.0
@export var planet_decel_air_mult := 1.0
@export var planet_decel_ground_linear := 0.0
@export var planet_decel_ground_mult := 1.0


var gamepad := Gamepad.create(Gamepad.DEVICE_AUTO)

var is_jumping := false
var is_boosting := false
var jump_timer := 0.0
var wait_until_release_before_boosting := false

var time := 0.0


func _ready() -> void:
	o2 = 60 + 30 * Stats.oxygen_upgrades
	o2_max = o2
	
	jetpack_fuel_time = 1.0 + 1.0 * Stats.fuel_upgrades
	jetpack_fuel_left = jetpack_fuel_time


func get_up_vector() -> Vector2:
	return transform.basis_xform(Vector2.UP)


func _physics_process(delta: float) -> void:
	time += delta
	jump_timer -= delta
	
	gamepad.poll(delta)
	_process_movement(delta)
	
	queue_redraw()
	
	home_arrow_anchor.look_at(Vector2.ZERO)
	
	fuel_bar.value = (jetpack_fuel_left / jetpack_fuel_time) * 100.0
	fuel_bar.custom_minimum_size.x = jetpack_fuel_time * 150.0
	
	o2 -= delta
	o2_bar.value = (o2 / o2_max) * 100.0
	
	if o2 < 10.0:
		o2_bar.modulate.a = 0.0 if wrapf(time * 5.0, 0.0, 1.0) < 0.5 else 1.0
	elif o2 < o2_max / 3.0 or o2 < 30.0:
		o2_bar.modulate.a = 0.0 if wrapf(time * 2.0, 0.0, 1.0) < 0.2 else 1.0
	
	if jetpack_fuel_left <= 0.0:
		fuel_bar.modulate.a = 0.0 if wrapf(time * 5.0, 0.0, 1.0) < 0.5 else 1.0
	else:
		fuel_bar.modulate.a = 1.0


func _process_movement(delta: float) -> void:
	var gravity := get_gravity()
	
	var has_gravity := not gravity.is_zero_approx()
	
	if has_gravity:
		motion_mode = CharacterBody2D.MOTION_MODE_GROUNDED
		up_direction = -gravity
		
		rotation = gravity.angle() - (PI / 2.0)
	else:
		motion_mode = CharacterBody2D.MOTION_MODE_FLOATING
	
	var target_zoom := 2.0 if has_gravity else 0.5
	camera.zoom = Vector2.ONE * lerpf(camera.zoom.x, target_zoom, Math.smooth(1.0, delta))
	
	var up := transform.basis_xform(Vector2.UP)
	var right := transform.basis_xform(Vector2.RIGHT)
	
	if not gamepad.jump.down:
		wait_until_release_before_boosting = false
	
	jetpack_vfx.emitting = false
	is_boosting = false
	
	if (
			gamepad.jump.down
			and not wait_until_release_before_boosting
	):
		var current_jetpack_speed := velocity.dot(up)
		
		jetpack_vfx.emitting = true
		
		if (
				current_jetpack_speed < jetpack_max_speed
				or velocity.normalized().dot(up) < 0.99
		):
			var using_o2 := false
			if jetpack_fuel_left < 0.0:
				jetpack_fuel_left += delta
				o2 -= delta * jetpack_o2_to_fuel_ratio
				using_o2 = true
			
			velocity += get_up_vector() * jetpack_boost_accel * delta
			jetpack_fuel_left -= delta
			is_boosting = true
			if jetpack_fuel_left <= 0.0 and not using_o2:
				wait_until_release_before_boosting = true
	else:
		if not (is_jumping and gamepad.jump.down and jump_timer > 0.0):
			velocity += gravity * delta
	
	if has_gravity:
		_process_gravity(delta)
	else:
		_process_space(delta)
	
	move_and_slide()


func _process_space(delta: float) -> void:
	camera.rotation_smoothing_speed = 5.0
	
	var up := transform.basis_xform(Vector2.UP)
	var right := transform.basis_xform(Vector2.RIGHT)
	
	is_jumping = false
	rotation += gamepad.move.x * space_rotation_speed * delta
	
	velocity = velocity.move_toward(Vector2.ZERO, space_decel_linear * delta) * space_decel_mult
	
	# velocity = velocity
	
	var magnitude := velocity.length()
	var new_angle := rotate_toward(velocity.angle(), up.angle(), (space_jetpack_steering_assist_over_time + space_jetpack_steering_assist_manual * float(is_boosting)) * delta)
	
	velocity = Vector2.from_angle(new_angle) * magnitude


func _process_gravity(delta: float) -> void:
	camera.rotation_smoothing_speed = 1.0
	
	var up := transform.basis_xform(Vector2.UP)
	var right := transform.basis_xform(Vector2.RIGHT)
	
	var is_grounded = is_on_floor()
	
	if is_grounded:
		is_jumping = false
		jetpack_fuel_left = jetpack_fuel_time
	
	var move_accel := planet_move_accel_ground if is_grounded else planet_move_accel_air
	
	var projection := velocity.project(right)
	var current_move_speed := projection.length()
	
	if absf(current_move_speed) < absf(planet_move_speed):
		velocity += right * gamepad.move.x * move_accel * delta
		jump_timer = 1.0
	
	# Deceleration if not moving
	if (
			absf(current_move_speed) > planet_max_move_speed
			or is_zero_approx(gamepad.move.x)
			or signf(velocity.dot(right)) != signf(gamepad.move.x)
	):
		var decel_linear = planet_decel_ground_linear if is_grounded else planet_decel_air_linear
		var decel_mult = planet_decel_ground_mult if is_grounded else planet_decel_air_mult
		
		velocity = velocity.move_toward(Vector2.ZERO, decel_linear * delta) * decel_mult
	
	# Jumping and boosting
	if is_grounded and gamepad.jump.pressed:
		is_jumping = true
		velocity += get_up_vector() * planet_jump_velocity
		wait_until_release_before_boosting = true


func _draw() -> void:
	var gravity := get_gravity()
	
	draw_line(Vector2.ZERO, gravity.rotated(-rotation), Color.RED, 4.0)
	draw_line(Vector2.ZERO, velocity.rotated(-rotation), Color.GREEN, 4.0)
