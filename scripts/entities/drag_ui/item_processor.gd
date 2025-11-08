extends DraggableItemBin
class_name ItemProcessor

signal processing_started(duration: float)
signal processing_completed
signal processing_progress_changed(progress: float)

@export var max_capacity: int = 1
var _processing_time: float = 0.0
var _last_progress_emission: float = 0.0


func _ready() -> void:
	# Start with processing enabled, not draggable until countdown completes
	super._ready()
	is_draggable = false
	_is_active = true


func _process(delta: float) -> void:
	# Handle dragging and countdown timer
	if _active_drag_sprite and _dragging:
		_active_drag_sprite.global_position = get_global_mouse_position() + _drag_offset
	
	# Only countdown if we have an item
	if count <= 0 or _processing_time <= 0.0:
		return
	
	_processing_time -= delta
	
	# Emit progress (every 1%)
	var progress = 1.0 - (max(0.0, _processing_time) / _get_processing_duration())
	if progress - _last_progress_emission >= 0.01:
		_last_progress_emission = progress
		processing_progress_changed.emit(progress)
	
	# Processing complete
	if _processing_time <= 0.0:
		_processing_time = 0.0
		is_draggable = true
		processing_completed.emit()


func _input_event(viewport, event, shape_idx) -> void:
	# Handle clicks to drag processed items
	if not is_draggable or _dragging:
		return
	
	if count <= 0:
		return

	if event is InputEventMouseButton:
		var mb := event as InputEventMouseButton
		if mb.pressed and mb.button_index == drag_button:
			_spawn_draggable_at(mb.position)


func _spawn_draggable_at(global_point: Vector2) -> void:
	# Create sprite and mark with item type
	super._spawn_draggable_at(global_point)
	
	if _active_drag_sprite:
		_active_drag_sprite.set_meta("item_type", item_type)


func increment_count() -> void:
	# Enforce single item capacity
	if count < max_capacity:
		count += 1


func decrement_count() -> void:
	# Remove item and reset processing state
	if count > 0:
		count -= 1
	
	if count <= 0:
		is_draggable = false
		_processing_time = 0.0
		_last_progress_emission = 0.0


func _get_processing_duration() -> float:
	# Get processing time based on item type
	match receiving_item:
		Item.ResourceType.ROCK:
			return RockItem.new().processing_duration
		Item.ResourceType.PLANT:
			return PlantItem.new().processing_duration
		Item.ResourceType.ANIMAL:
			return AnimalItem.new().processing_duration
		_:
			return 5.0


func _try_receive_item(item_type: Item.ResourceType = Item.ResourceType.NONE) -> bool:
	# Check capacity and type, then start processing
	if count >= max_capacity:
		return false
	
	if item_type != receiving_item:
		return false
	
	var result = super._try_receive_item(item_type)
	
	if result:
		_processing_time = _get_processing_duration()
		_last_progress_emission = 0.0
		processing_started.emit(_processing_time)
	
	return result


func get_processing_progress() -> float:
	# Return progress from 0 to 1
	if _processing_time <= 0.0:
		return 1.0
	
	var max_time = _get_processing_duration()
	return 1.0 - (_processing_time / max_time) if max_time > 0 else 1.0


func get_remaining_time() -> float:
	# Return remaining processing time
	return max(0.0, _processing_time)

