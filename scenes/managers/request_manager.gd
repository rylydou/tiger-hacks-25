extends Node2D

@export var possible_requests: Array[Item.ResourceType] = [
	Item.ResourceType.ROCK,
	Item.ResourceType.PLANT,
	Item.ResourceType.ANIMAL,
	Item.ResourceType.REFINED_ROCK,
	Item.ResourceType.REFINED_PLANT,
	Item.ResourceType.REFINED_ANIMAL
]

var possible_quantity_range: Vector2i = Vector2i(1, 1)

@export var locations: Array[Node2D] = []
@export var enter_location: Node2D
@export var exit_location: Node2D
@export var scientist_scene: PackedScene = preload("res://scenes/entities/scientist.tscn")
@export var spawn_delay: float = 1.0
@export var time_limit: float = 30.0

# Track which location indices are occupied
var _occupied_locations: Array[bool] = []
var _spawn_timer: float = 0.0


func _ready() -> void:
	# Initialize location tracking
	if locations.size() > 0:
		_occupied_locations.resize(locations.size())
		_occupied_locations.fill(false)
	_spawn_timer = spawn_delay


func _process(delta: float) -> void:
	_spawn_timer -= delta
	if _spawn_timer <= 0.0:
		_try_spawn_scientist()
		_spawn_timer = spawn_delay


func _try_spawn_scientist() -> void:
	# Find an available location
	var location_idx = -1
	for i in range(locations.size()):
		if not _occupied_locations[i]:
			location_idx = i
			break
	
	if location_idx == -1:
		return  # No available locations
	
	# Mark location as occupied
	_occupied_locations[location_idx] = true
	
	# Instantiate scientist
	var scientist = scientist_scene.instantiate()
	if not scientist:
		push_error("Failed to instantiate scientist scene")
		_occupied_locations[location_idx] = false
		return
	
	# Add to scene
	add_child(scientist)
	
	# Give scientist the locations and manager reference
	scientist.setup(locations[location_idx], enter_location, exit_location, time_limit, self)
	
	# Connect done signal
	scientist.scientist_done.connect(func(): _on_scientist_done(location_idx))
	
	# Pick random request
	var request_type = possible_requests.pick_random()
	var quantity = randi_range(possible_quantity_range.x, possible_quantity_range.y)
	scientist.create_request(request_type, quantity, time_limit)
	
	print("Spawned scientist at location %d requesting %d of type %s" % [location_idx, quantity, str(request_type)])


func _on_scientist_done(location_idx: int) -> void:
	_occupied_locations[location_idx] = false
	print("Location %d is now available" % location_idx)
