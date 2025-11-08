class_name Player extends CharacterBody2D


@export var air_decel_space := 0.0
@export var air_decel_gravity := 0.0
@export var ground_decel := 0.0


@export_group("Gravity Movement")

@export_group("Movement", "move_")
@export var move_speed := 64.0
#@export var move_crouch_speed := 2.0


@export_range(0, 60, 1, "or_greater", "suffix:ticks") var move_accel_ticks := 4.0
@export_range(0, 60, 1, "or_greater", "suffix:ticks") var move_decel_ticks := 4.0
@export_range(0, 60, 1, "or_greater", "suffix:ticks") var move_pivot_ticks := 2.0

@export_range(0, 60, 1, "or_greater", "suffix:ticks") var move_accel_air_ticks := 4.0
@export_range(0, 60, 1, "or_greater", "suffix:ticks") var move_decel_air_ticks := 4.0
@export_range(0, 60, 1, "or_greater", "suffix:ticks") var move_pivot_air_ticks := 2.0


@export_group("Gravity and Jump")
@export_range(0, 16, 1, "or_greater", "suffix:px") var jump_height_min := 8.0
@export_range(0, 16, 1, "or_greater", "suffix:px") var jump_height_max := 32.0
@export_range(0, 120, 1, "or_greater", "suffix:ticks") var jump_ticks := 30.0
@export_range(0, 120, 1, "or_greater", "suffix:ticks") var fall_ticks := 30.0
var fall_gravity := 0.0
var jump_gravity := 0.0
var jump_velocity_min := 0.0
var jump_velocity_max := 0.0
@export var step_time := 0.2
var step_timer := 0.0


@export_group("Space Movement", "space_")

@export var space_rotation_speed := 1.0


var gamepad := Gamepad.create(Gamepad.DEVICE_AUTO)


func _process(delta: float) -> void:
	gamepad.poll(delta)


func _physics_process(delta: float) -> void:
	_process_movement(delta)
	
	queue_redraw()


func _process_movement(delta: float) -> void:
	var gravity := get_gravity()
	
	velocity += gravity * delta
	
	DevTools.sticky_toast(&"gravity", gravity)
	DevTools.sticky_toast(&"move", gamepad.move)
	
	var has_gravity := not gravity.is_zero_approx()
	
	if has_gravity:
		motion_mode = CharacterBody2D.MOTION_MODE_GROUNDED
		up_direction = -gravity
		rotation = gravity.angle() - PI/2.0
	else:
		motion_mode = CharacterBody2D.MOTION_MODE_FLOATING
	
	var deceleration = air_decel_gravity if has_gravity else air_decel_space
	if is_on_floor():
		deceleration = ground_decel
	
	velocity = velocity.move_toward(Vector2.ZERO, deceleration * delta)
	
	if has_gravity:
		pass
	
	_process_walk(delta)
	
	var directed_move := Vector2.from_angle(rotation) * vel_move
	velocity += directed_move
	move_and_slide()
	velocity -= directed_move


var vel_move := 0.0

func _process_walk(delta: float) -> void:
	var is_grounded = is_on_floor()
	var is_pivoting = not is_zero_approx(vel_move) and sign(vel_move) != sign(gamepad.move.x)
	
	var move_ticks := 0.0
	var extra_dec := 0.0
	var extra_smooth := 0.0
	if is_grounded:
		# grounded movement
		if gamepad.move.x == 0.0:
				move_ticks = -move_decel_ticks
		else:
			if is_pivoting:
				move_ticks = move_pivot_ticks
			else:
				move_ticks = move_accel_ticks
	else:
		# air movement
		if gamepad.move.x == 0.0:
			move_ticks = -move_decel_air_ticks
		else:
			if is_pivoting:
				move_ticks = move_pivot_air_ticks
			else:
				move_ticks = move_accel_air_ticks
	
	if move_ticks > 0.0:
		var speed: float = move_speed / (move_ticks / Global.TPS / delta)
		vel_move += gamepad.move.x * speed
	elif move_ticks < 0.0:
		vel_move = move_toward(vel_move, 0.0, move_speed / (-move_ticks / Global.TPS / delta))
	
	var max_speed := move_speed
	vel_move = clamp(vel_move, -max_speed, max_speed)
	
	var hit_wall_on_left := is_on_wall() and test_move(transform, Vector2.LEFT)
	var hit_wall_on_right := is_on_wall() and test_move(transform, Vector2.RIGHT)
	
	if vel_move == 0.0:
		step_timer -= delta
	
	if is_grounded and (
			(vel_move > 0.0 and not hit_wall_on_right) or
			(vel_move < 0.0 and not hit_wall_on_left)
	):
		step_timer -= delta
		if step_timer < 0.0:
			step_timer = step_time
			SFX.event(&"sfx/step").at(self).play()
	
	if hit_wall_on_left:
		if vel_move < 0.0:
			vel_move = 0.0
	
	if hit_wall_on_right:
		if vel_move > 0.0:
			vel_move = 0.0


func _draw() -> void:
	var gravity := get_gravity()
	
	draw_line(Vector2.ZERO, to_local(gravity) * 300.0, Color.RED, 4.0)
	draw_line(Vector2.ZERO, to_local(velocity), Color.GREEN, 4.0)
