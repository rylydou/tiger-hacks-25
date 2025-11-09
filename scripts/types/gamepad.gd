class_name Gamepad extends RefCounted


const DEVICE_AUTO = -2
const DEVICE_KEYBOARD = -1


static func create(device: int) -> Gamepad:
	var gamepad := Gamepad.new()
	gamepad.device = device
	return gamepad


# ---------------------------------------- #


@export var device := 0
@export var deadzone := 0.5
@export var move_deadzone := 0.35
@export var crouch_threshold := 0.7
@export var move_snap_amount := 1.3333
@export var aim_deadzone := 0.5
@export var trigger_deadzone := 0.5


var any := Btn.new()

var menu_ok := Btn.new()
var menu_back := Btn.new()
var menu_pause := Btn.new()
var menu_open_map := Btn.new()

var menu_left := Btn.turbo()
var menu_right := Btn.turbo()
var menu_up := Btn.turbo()
var menu_down := Btn.turbo()

var move := Vector2.ZERO
var aim := Vector2.ZERO

var jump := Btn.new()
var crouch := Btn.new()

var mine := Btn.new()
var action := Btn.new()
var switch := Btn.new()
var drop := Btn.new()
var switch_left := Btn.turbo()
var switch_right := Btn.turbo()

var self_destruct := Btn.new()


func duplicate() -> Gamepad:
	return Gamepad.create(self.device)


func get_connection() -> bool:
	match device:
		-2: return true
		-1: return true
	return false


func get_name() -> String:
	match device:
		-2: return "Auto"
		-1: return "Keyboard"
	return "Unknown"


func vibrate(weak: float, strong: float, duration: float) -> void:
	Input.start_joy_vibration(device, weak, strong, duration)


func poll(delta: float) -> void:
	match device:
		-2:
			var connected_joy_ids := Input.get_connected_joypads()
			var use_joy := -1
			for joy_id in connected_joy_ids:
				use_joy = joy_id
			
			if use_joy >= 0:
				poll_gamepad(delta, use_joy)
			else:
				poll_keyboard(delta)
		-1:
			poll_keyboard(delta)
		_:
			poll_gamepad(delta, device)


func poll_gamepad(delta: float, device: int) -> void:
	any.track((
			Input.is_joy_button_pressed(device, JOY_BUTTON_START)
			or Input.is_joy_button_pressed(device, JOY_BUTTON_BACK)
			or Input.is_joy_button_pressed(device, JOY_BUTTON_A)
			or Input.is_joy_button_pressed(device, JOY_BUTTON_B)
			or Input.is_joy_button_pressed(device, JOY_BUTTON_X)
			or Input.is_joy_button_pressed(device, JOY_BUTTON_Y)
	), delta)
	
	menu_ok.track(Input.is_joy_button_pressed(device, JOY_BUTTON_B), delta)
	menu_back.track(Input.is_joy_button_pressed(device, JOY_BUTTON_A), delta)
	menu_pause.track(Input.is_joy_button_pressed(device, JOY_BUTTON_START), delta)
	menu_open_map.track(Input.is_joy_button_pressed(device, JOY_BUTTON_BACK), delta)
	
	menu_left.track((
			Input.is_joy_button_pressed(device, JOY_BUTTON_DPAD_LEFT) or
			Input.get_joy_axis(device, JOY_AXIS_LEFT_X) <= -deadzone
	), delta)
	menu_right.track((
			Input.is_joy_button_pressed(device, JOY_BUTTON_DPAD_RIGHT) or
			Input.get_joy_axis(device, JOY_AXIS_LEFT_X) >= +deadzone
	), delta)
	menu_up.track((
			Input.is_joy_button_pressed(device, JOY_BUTTON_DPAD_UP) or
			Input.get_joy_axis(device, JOY_AXIS_LEFT_Y) <= -deadzone
	), delta)
	menu_down.track((
			Input.is_joy_button_pressed(device, JOY_BUTTON_DPAD_DOWN) or
			Input.get_joy_axis(device, JOY_AXIS_LEFT_Y) >= +deadzone
	), delta)
	
	move.x = Input.get_joy_axis(device, JOY_AXIS_LEFT_X)
	move.y = Input.get_joy_axis(device, JOY_AXIS_LEFT_Y)
	aim.x = Input.get_joy_axis(device, JOY_AXIS_RIGHT_X)
	aim.y = Input.get_joy_axis(device, JOY_AXIS_RIGHT_Y)
	
	move.x += float(Input.is_joy_button_pressed(device, JOY_BUTTON_DPAD_RIGHT)) - float(Input.is_joy_button_pressed(device, JOY_BUTTON_DPAD_LEFT))
	move.y += float(Input.is_joy_button_pressed(device, JOY_BUTTON_DPAD_DOWN)) - float(Input.is_joy_button_pressed(device, JOY_BUTTON_DPAD_UP))
	
	move.x = clampf(move.x, -1.0, 1.0)
	move.y = clampf(move.y, -1.0, 1.0)
	
	# apply deadzone to account for shitty controller joysticks
	var move_length_squared := move.length_squared()
	if move_length_squared < move_deadzone ** 2.0:
		move = Vector2.ZERO
	else:
		# remap move vector to hide the deadzone
		# 25...100 -> 0...100
		var move_length := sqrt(move_length_squared)
		move = (move / move_length) * ((move_length - move_deadzone) / (1.0 - move_deadzone))
	
	move = round(move.normalized() * move_snap_amount)
	
	jump.track((
			Input.is_joy_button_pressed(device, JOY_BUTTON_A)
	), delta)
	
	action.track((
			Input.is_joy_button_pressed(device, JOY_BUTTON_B)
			or Input.is_joy_button_pressed(device, JOY_BUTTON_X)
			or Input.is_joy_button_pressed(device, JOY_BUTTON_Y)
	), delta)


func poll_keyboard(delta: float) -> void:
	any.track((
			Input.is_key_pressed(KEY_SPACE)
			or Input.is_key_pressed(KEY_ENTER)
			or Input.is_key_pressed(KEY_E)
	), delta)
	
	menu_ok.track((
			Input.is_physical_key_pressed(KEY_E)
			or Input.is_physical_key_pressed(KEY_SPACE)
			or Input.is_physical_key_pressed(KEY_ENTER)
	), delta)
	menu_back.track((
			Input.is_physical_key_pressed(KEY_Q)
			or Input.is_physical_key_pressed(KEY_BACKSPACE)
			or Input.is_physical_key_pressed(KEY_ESCAPE)
	), delta)
	menu_pause.track(Input.is_key_label_pressed(KEY_ESCAPE), delta)
	menu_open_map.track(Input.is_key_label_pressed(KEY_M), delta)
	
	menu_left.track((
			Input.is_physical_key_pressed(KEY_A)
			or Input.is_physical_key_pressed(KEY_LEFT)
	), delta)
	menu_right.track((
			Input.is_physical_key_pressed(KEY_D)
			or Input.is_physical_key_pressed(KEY_RIGHT)
	), delta)
	menu_up.track((
			Input.is_physical_key_pressed(KEY_W)
			or Input.is_physical_key_pressed(KEY_UP)
	), delta)
	menu_down.track((
			Input.is_physical_key_pressed(KEY_S)
			or Input.is_physical_key_pressed(KEY_DOWN)
	), delta)
	
	var right := float(
			Input.is_physical_key_pressed(KEY_D)
			or Input.is_physical_key_pressed(KEY_RIGHT)
	)
	var left := float(
			Input.is_physical_key_pressed(KEY_A)
			or Input.is_physical_key_pressed(KEY_LEFT)
	)
	move.x = right - left
	
	var down := float(
			Input.is_physical_key_pressed(KEY_S)
			or Input.is_physical_key_pressed(KEY_DOWN)
	)
	var up := float(
			Input.is_physical_key_pressed(KEY_W)
			or Input.is_physical_key_pressed(KEY_UP)
	)
	move.y = down - up
	
	action.track(
			Input.is_physical_key_pressed(KEY_X)
			or Input.is_physical_key_pressed(KEY_E)
			or Input.is_physical_key_pressed(KEY_ENTER)
			or Input.is_physical_key_pressed(KEY_C)
			or Input.is_physical_key_pressed(KEY_Q)
			or Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT)
	, delta)
