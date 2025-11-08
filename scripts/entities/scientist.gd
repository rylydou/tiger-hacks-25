extends Node2D

signal scientist_done

@export var request_type: Item.ResourceType = Item.ResourceType.NONE
@export var amount_needed: int = 1
@export var time_limit: float = 30.0
@export var sprite_list: Array[AnimatedSprite2D] = []
@export var move_speed: float = 600  # pixels per second

@onready var item_matcher: ItemMatcher = $ItemMatcher
@onready var time_remaining: ProgressBar = $TimeRemaining

var _countdown: float = 0.0
var _request_created: bool = false
var _is_moving: bool = false
var _move_start_pos: Vector2 = Vector2.ZERO
var _move_end_pos: Vector2 = Vector2.ZERO
var _move_elapsed: float = 0.0
var _move_duration: float = 0.0
var _target_location: Node2D = null
var _enter_location: Node2D = null
var _exit_location: Node2D = null


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Pick a random sprite and play its idle animation
	if sprite_list.size() > 0:
		var random_sprite = sprite_list.pick_random()
		random_sprite.visible = true
		random_sprite.animation = "idle"
		random_sprite.play()
	
	# Connect to item matcher signals
	item_matcher.request_fulfilled.connect(_on_request_fulfilled)
	item_matcher.correct_item_received.connect(_on_correct_item_received)
	item_matcher.incorrect_item_received.connect(_on_incorrect_item_received)
	
	# Setup progress bar
	if time_remaining:
		time_remaining.min_value = 0.0
		time_remaining.max_value = time_limit
		time_remaining.value = time_limit
	
	# If request was already created before _ready, configure now
	if _request_created:
		_configure_request()
	
	# Start countdown
	_countdown = time_limit

func create_request(request_type: Item.ResourceType, amount: int, time_limit_sec: float) -> void:
	self.request_type = request_type
	amount_needed = amount
	time_limit = time_limit_sec
	_request_created = true
	
	if is_node_ready():
		_configure_request()


func setup(target_loc: Node2D, enter_loc: Node2D, exit_loc: Node2D, time_limit_sec: float, manager: Node) -> void:
	"""Initialize scientist with location references"""
	_target_location = target_loc
	_enter_location = enter_loc
	_exit_location = exit_loc
	time_limit = time_limit_sec
	
	# Start entering animation
	if _enter_location:
		global_position = _enter_location.global_position
		if _target_location and _target_location.global_position != _enter_location.global_position:
			_start_move_to(_target_location.global_position)
	else:
		global_position = _target_location.global_position

func _configure_request() -> void:
	# Setup item matcher with request parameters
	item_matcher.receiving_items = [request_type]
	item_matcher.correct_items = [request_type]
	item_matcher.primary_correct_item = request_type
	item_matcher.amount_needed = amount_needed
	
	# Setup progress bar
	if time_remaining:
		time_remaining.min_value = 0.0
		time_remaining.max_value = time_limit
		time_remaining.value = time_limit


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	# Handle movement
	if _is_moving:
		_move_elapsed += delta
		var progress = min(1.0, _move_elapsed / _move_duration)
		# Use ease for snappy acceleration/deceleration
		var eased_progress = ease(progress, -2.0)
		global_position = _move_start_pos.lerp(_move_end_pos, eased_progress)
		
		# Movement complete
		if progress >= 1.0:
			_is_moving = false
			global_position = _move_end_pos
	
	# Countdown timer
	if _countdown > 0.0:
		_countdown -= delta
		# Update progress bar
		if time_remaining:
			time_remaining.value = _countdown
		if _countdown <= 0.0:
			_on_time_out()


func _start_move_to(target_pos: Vector2) -> void:
	# Begin lerp movement to target position
	_move_start_pos = global_position
	_move_end_pos = target_pos
	_move_elapsed = 0.0
	var distance = _move_start_pos.distance_to(target_pos)
	_move_duration = distance / move_speed
	_is_moving = true


func _on_request_fulfilled() -> void:
	# Move to exit location if available
	if _exit_location:
		print("Scientist moving to exit location")
		_start_move_to(_exit_location.global_position)
		# Wait for movement to complete before signaling done
		while _is_moving:
			await get_tree().process_frame
	
	scientist_done.emit()
	queue_free()


func _on_time_out() -> void:
	# Move to exit location if available
	if _exit_location:
		_start_move_to(_exit_location.global_position)
		# Wait for movement to complete before signaling done
		while _is_moving:
			await get_tree().process_frame
	
	scientist_done.emit()
	queue_free()


func _on_incorrect_item_received() -> void:
	pass


func _on_correct_item_received() -> void:
	pass
