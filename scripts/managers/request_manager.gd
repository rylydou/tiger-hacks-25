extends Node2D
class_name RequestManager

signal request_completed()

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
		# Debug: print occupied locations for troubleshooting
		print("RequestManager: No available locations. Occupied: ", get_number_occupied_locations(), " / ", locations.size())
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
	# Build allowed request types from current inventory contents
	var allowed_requests: Array[Item.ResourceType] = []
	if Inventory and not Inventory.is_empty():
		# Collect types present in inventory
		var seen := {}
		for it in Inventory.get_all_items():
			seen[it.resource_type] = true
		# Always include the refined variant for base types if base is present
		if seen.has(Item.ResourceType.ROCK):
			seen[Item.ResourceType.REFINED_ROCK] = true
		if seen.has(Item.ResourceType.PLANT):
			seen[Item.ResourceType.REFINED_PLANT] = true
		if seen.has(Item.ResourceType.ANIMAL):
			seen[Item.ResourceType.REFINED_ANIMAL] = true
		# Build final array of available types that the inventory can satisfy (count > 0)
		for t in seen.keys():
			# Only include if inventory has at least one of that type, or it's a refined variant we just added
			# If it's a refined we added but inventory doesn't have it, it's still allowed per spec
			allowed_requests.append(t)
	
	# If no allowed requests could be determined, fallback to global possible_requests
	if allowed_requests.size() == 0:
		print("  No items in inventory, using default possible_requests")
		allowed_requests = possible_requests.duplicate()

	var request_type = allowed_requests.pick_random()
	# Determine quantity but cap it to available inventory for that type when possible
	var quantity = randi_range(possible_quantity_range.x, possible_quantity_range.y)
	var max_available = 9999
	if Inventory:
		max_available = Inventory.get_count(request_type)
	if max_available > 0:
		quantity = min(quantity, max_available)
	
	scientist.create_request(request_type, quantity, time_limit)

	print("Spawned scientist at location %d requesting %d of type %s" % [location_idx, quantity, Item.ResourceType.keys()[request_type]])


func _on_scientist_done(location_idx: int) -> void:
	_occupied_locations[location_idx] = false
	request_completed.emit()
	print("Location %d is now available" % location_idx)

func get_number_occupied_locations() -> int:
	var count = 0
	for occupied in _occupied_locations:
		if occupied:
			count += 1
	return count
