class_name Player extends CharacterBody2D


@export_group("Jetpack", "jetpack_")

@export var jetpack_boost_accel := 10.0


@export_group("Space Movement", "space_")

@export var space_rotation_speed := 1.0

@export var space_decel_linear := 0.0
@export var space_decel_mult := 1.0


@export_group("Planet Movement", "planet_")

@export var planet_max_move_speed := 100.0
@export var planet_move_accel_air := 100.0
@export var planet_move_accel_ground := 100.0
@export var planet_jump_velocity = 500.0

@export var planet_decel_air_linear := 0.0
@export var planet_decel_air_mult := 1.0
@export var planet_decel_ground_linear := 0.0
@export var planet_decel_ground_mult := 1.0

@export var step_time := 0.2
var step_timer := 0.0


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
	
	DevTools.sticky_toast(&"gravity", gravity)
	DevTools.sticky_toast(&"move", gamepad.move)
	
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
		vel_move = 0.0
		_process_space(delta)
	
	var directed_move := Vector2.from_angle(rotation) * vel_move
	velocity += directed_move
	move_and_slide()
	velocity -= directed_move


func _process_space(delta: float) -> void:
	is_jumping = false
	rotation += gamepad.move.x * space_rotation_speed * delta
	
	if gamepad.jump.down:
		velocity += get_up_vector() * jetpack_boost_accel * delta
	
	velocity = velocity.move_toward(Vector2.ZERO, space_decel_linear * delta) * space_decel_mult


var vel_move := 0.0

func _process_gravity(delta: float) -> void:
	var up := transform.basis_xform(Vector2.UP)
	var right := transform.basis_xform(Vector2.RIGHT)
	
	var is_grounded = is_on_floor()
	
	if is_grounded:
		is_jumping = false
	
	var move_accel := planet_move_accel_ground if is_grounded else planet_move_accel_air
	
	var projection := velocity.project(right)
	var current_move_speed := projection.length()
	
	if absf(current_move_speed) < absf(planet_max_move_speed):
		velocity += right * gamepad.move.x * move_accel * delta
	
	# Deceleration if not moving
	if is_zero_approx(gamepad.move.x) || signf(velocity.dot(right)) != signf(gamepad.move.x):
		var decel_linear = planet_decel_ground_linear if is_grounded else planet_decel_air_linear
		var decel_mult = planet_decel_ground_mult if is_grounded else planet_decel_air_mult
		
		velocity = velocity.move_toward(Vector2.ZERO, decel_linear * delta) * decel_mult
	
	if vel_move == 0.0:
		step_timer -= delta
	
	if is_grounded:
		step_timer -= delta
		if step_timer < 0.0:
			step_timer = step_time
			SFX.event(&"sfx/step").at(self).play()
	
	# Jumping and boosting
	
	if is_grounded and gamepad.jump.pressed:
		is_jumping = true
		velocity += get_up_vector() * planet_jump_velocity
	
	if gamepad.jump.down:
		velocity += get_up_vector() * jetpack_boost_accel * delta


func _draw() -> void:
	var gravity := get_gravity()
	
	draw_line(Vector2.ZERO, gravity.rotated(-rotation) * 300.0, Color.RED, 4.0)
	draw_line(Vector2.ZERO, velocity.rotated(-rotation), Color.GREEN, 4.0)
