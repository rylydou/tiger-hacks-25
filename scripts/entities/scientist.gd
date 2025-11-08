extends Node2D

@export var request_type: Item.ResourceType = Item.ResourceType.NONE
@export var amount_needed: int = 1
@export var time_limit: float = 30.0  # in seconds
@export var sprite_list: Array[Sprite2D] = []

@onready var item_matcher: ItemMatcher = $ItemMatcher
@onready var time_remaining: ProgressBar = $TimeRemaining

var _countdown: float = 0.0


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	sprite_list.pick_random().visible = true
	item_matcher.receiving_item = request_type
	item_matcher.amount_needed = amount_needed
	
	# Connect to item matcher signals
	item_matcher.request_fulfilled.connect(_on_request_fulfilled)
	item_matcher.correct_item_received.connect(_on_correct_item_received)
	item_matcher.incorrect_item_received.connect(_on_incorrect_item_received)
	
	# Setup progress bar
	if time_remaining:
		time_remaining.min_value = 0.0
		time_remaining.max_value = time_limit
		time_remaining.value = time_limit
	
	# Start countdown
	_countdown = time_limit


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	# Countdown timer
	if _countdown > 0.0:
		_countdown -= delta
		# Update progress bar
		if time_remaining:
			time_remaining.value = _countdown
		if _countdown <= 0.0:
			_on_time_out()


func _on_request_fulfilled() -> void:
	queue_free()


func _on_time_out() -> void:
	queue_free()


func _on_incorrect_item_received() -> void:
	pass


func _on_correct_item_received() -> void:
	pass
