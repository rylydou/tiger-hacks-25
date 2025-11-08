class_name Player extends CharacterBody2D


@export var camera: Camera2D

@export_group("Jetpack", "jetpack_")

@export var jetpack_boost_accel := 10.0
@export var jetpack_max_speed := 100.0


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


func get_up_vector() -> Vector2:
	return transform.basis_xform(Vector2.UP)


func _physics_process(delta: float) -> void:
	gamepad.poll(delta)
	_process_movement(delta)
	
	queue_redraw()


func _process_movement(delta: float) -> void:
	var gravity := get_gravity()
	
	if not gamepad.jump.down:
		velocity += gravity * delta
	
	var has_gravity := not gravity.is_zero_approx()
	
	if has_gravity:
		motion_mode = CharacterBody2D.MOTION_MODE_GROUNDED
		up_direction = -gravity
		
		rotation = gravity.angle() - (PI / 2.0)
	else:
		motion_mode = CharacterBody2D.MOTION_MODE_FLOATING
	
	if has_gravity:
		_process_gravity(delta)
	else:
		_process_space(delta)
	
	move_and_slide()
	
	var target_zoom := 2.0 if has_gravity else 1.0
	
	camera.zoom = Vector2.ONE * lerpf(camera.zoom.x, target_zoom, Math.smooth(1.0, delta))


func _process_space(delta: float) -> void:
	camera.rotation_smoothing_speed = 5.0
	
	var up := transform.basis_xform(Vector2.UP)
	var right := transform.basis_xform(Vector2.RIGHT)
	
	is_jumping = false
	rotation += gamepad.move.x * space_rotation_speed * delta
	
	if gamepad.jump.down and velocity.project(up).length() < jetpack_max_speed:
		velocity += get_up_vector() * jetpack_boost_accel * delta
	
	velocity = velocity.move_toward(Vector2.ZERO, space_decel_linear * delta) * space_decel_mult
	
	# velocity = velocity
	
	var magnitude := velocity.length()
	var new_angle := rotate_toward(velocity.angle(), up.angle(), (space_jetpack_steering_assist_over_time + absf(gamepad.move.x) * space_jetpack_steering_assist_manual) * delta)
	
	velocity = Vector2.from_angle(new_angle) * magnitude


func _process_gravity(delta: float) -> void:
	camera.rotation_smoothing_speed = 1.0
	
	var up := transform.basis_xform(Vector2.UP)
	var right := transform.basis_xform(Vector2.RIGHT)
	
	var is_grounded = is_on_floor()
	
	if is_grounded:
		is_jumping = false
	
	var move_accel := planet_move_accel_ground if is_grounded else planet_move_accel_air
	
	var projection := velocity.project(right)
	var current_move_speed := projection.length()
	
	if absf(current_move_speed) < absf(planet_move_speed):
		velocity += right * gamepad.move.x * move_accel * delta
	
	# Deceleration if not moving
	if (
			absf(current_move_speed) > planet_max_move_speed
			|| is_zero_approx(gamepad.move.x)
			|| signf(velocity.dot(right)) != signf(gamepad.move.x)
	):
		var decel_linear = planet_decel_ground_linear if is_grounded else planet_decel_air_linear
		var decel_mult = planet_decel_ground_mult if is_grounded else planet_decel_air_mult
		
		velocity = velocity.move_toward(Vector2.ZERO, decel_linear * delta) * decel_mult
	
	# Jumping and boosting
	if is_grounded and gamepad.jump.pressed:
		is_jumping = true
		velocity += get_up_vector() * planet_jump_velocity
	
	if gamepad.jump.down and velocity.project(up).length() < jetpack_max_speed:
		velocity += get_up_vector() * jetpack_boost_accel * delta


func _draw() -> void:
	return
	var gravity := get_gravity()
	
	draw_line(Vector2.ZERO, gravity.rotated(-rotation), Color.RED, 4.0)
	draw_line(Vector2.ZERO, velocity.rotated(-rotation), Color.GREEN, 4.0)
