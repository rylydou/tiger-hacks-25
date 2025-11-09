extends DraggableItemBin
class_name ItemProcessor

signal processing_started(duration: float)
signal processing_completed
signal processing_progress_changed(progress: float)

@export var max_capacity: int = 1

@export var sound_clip: AudioStream = null
@onready var refining_sound: AudioStreamPlayer2D = $RefiningSound

var _processing_time: float = 0.0
var _last_progress_emission: float = 0.0
var _display_sprite: Sprite2D = null


func _ready() -> void:
	# Start with processing enabled, not draggable until countdown completes
	if sound_clip:
		refining_sound.stream = sound_clip
	super._ready()
	is_draggable = false
	_is_active = true
	
	# Create display sprite for showing processed item
	_display_sprite = Sprite2D.new()
	_display_sprite.centered = true
	_display_sprite.position = Vector2.ZERO
	_display_sprite.visible = false
	add_child(_display_sprite)


func _process(delta: float) -> void:
	# Handle dragging and countdown timer
	if _active_drag_sprite and _dragging:
		_active_drag_sprite.global_position = get_global_mouse_position() + _drag_offset
	
	# Only countdown if we have an item
	if count <= 0 or _processing_time <= 0.0:
		refining_sound.stop()
		return
	
	if not refining_sound.playing:
		refining_sound.play()
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
		_show_processed_item()
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
	# Create sprite with output item's icon and mark with output type
	var sprite = Sprite2D.new()
	
	# Get the output item's icon and scale
	var output_item: Item = null
	match output_item_type:
		Item.ResourceType.ROCK:
			output_item = RockItem.new()
		Item.ResourceType.PLANT:
			output_item = PlantItem.new()
		Item.ResourceType.ANIMAL:
			output_item = AnimalItem.new()
		Item.ResourceType.REFINED_ROCK:
			output_item = RefinedRockItem.new()
		Item.ResourceType.REFINED_PLANT:
			output_item = RefinedPlantItem.new()
		Item.ResourceType.REFINED_ANIMAL:
			output_item = RefinedAnimalItem.new()
	
	if output_item and output_item.icon:
		sprite.texture = output_item.icon
		sprite.scale = output_item.sprite_scale
	elif item_texture:
		sprite.texture = item_texture
	
	sprite.global_position = global_point
	sprite.set_meta("origin_bin", self)
	sprite.set_meta("item_type", output_item_type)
	
	var root = get_tree().get_current_scene() if get_tree().get_current_scene() else get_tree().get_root()
	root.add_child(sprite)
	
	_active_drag_sprite = sprite
	_dragging = true
	_drag_offset = sprite.global_position - get_global_mouse_position()
	_is_active = true


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
		_hide_processed_item()


func _show_processed_item() -> void:
	# Display the processed output item
	if not _display_sprite:
		return
	
	var output_item: Item = null
	match output_item_type:
		Item.ResourceType.ROCK:
			output_item = RockItem.new()
		Item.ResourceType.PLANT:
			output_item = PlantItem.new()
		Item.ResourceType.ANIMAL:
			output_item = AnimalItem.new()
		Item.ResourceType.REFINED_ROCK:
			output_item = RefinedRockItem.new()
		Item.ResourceType.REFINED_PLANT:
			output_item = RefinedPlantItem.new()
		Item.ResourceType.REFINED_ANIMAL:
			output_item = RefinedAnimalItem.new()
	
	if output_item and output_item.icon:
		_display_sprite.texture = output_item.icon
		# Ensure scale is NOT inherited from parent; set explicitly
		_display_sprite.scale = output_item.sprite_scale
		# Ensure position is at the processor's center
		_display_sprite.position = Vector2.ZERO
		_display_sprite.visible = true
	elif item_texture:
		_display_sprite.texture = item_texture
		_display_sprite.position = Vector2.ZERO
		_display_sprite.visible = true


func _hide_processed_item() -> void:
	# Hide the processed item display
	if _display_sprite:
		_display_sprite.visible = false


func _get_processing_duration() -> float:
	# Get processing time based on item type
	var base_time: float = 5.0
	if receiving_items.is_empty():
		return base_time / Stats.get_processing_speed()
	
	match receiving_items[0]:
		Item.ResourceType.ROCK:
			base_time = RockItem.new().processing_duration
		Item.ResourceType.PLANT:
			base_time = PlantItem.new().processing_duration
		Item.ResourceType.ANIMAL:
			base_time = AnimalItem.new().processing_duration
	return base_time / Stats.get_processing_speed()


func _try_receive_item(item_type: Item.ResourceType = Item.ResourceType.NONE) -> bool:
	# Check capacity and type, then start processing
	if count >= max_capacity:
		return false
	
	if not (item_type in receiving_items):
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

func turn_on_particles(duration: float) -> void:
	if has_node("ProcessingParticles"):
		var particles = $ProcessingParticles
		particles.emitting = true

func turn_off_particles() -> void:
	if has_node("ProcessingParticles"):
		var particles = $ProcessingParticles
		particles.emitting = false
