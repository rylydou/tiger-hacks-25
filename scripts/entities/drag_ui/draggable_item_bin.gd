extends Area2D
class_name DraggableItemBin

signal count_incremented(count: int)
signal count_decremented(count: int)
signal count_changed(count: int)

@export var is_receiving: bool = false
@export var is_draggable: bool = false
@export var item_texture: Texture2D
@export var output_item_type: Item.ResourceType = Item.ResourceType.NONE
@export var receiving_items: Array[Item.ResourceType] = []  # Items this bin can receive
@export var drag_button: int = MOUSE_BUTTON_LEFT

# Cached count from inventory
@export var count: int = 0:
	set(value):
		var old_count = count
		count = max(0, value)
		if count > old_count:
			emit_signal("count_incremented", count)
		elif count < old_count:
			emit_signal("count_decremented", count)
		emit_signal("count_changed", count)

# Dragging state for active sprites
var _active_drag_sprite: Sprite2D = null
var _dragging: bool = false
var _drag_offset: Vector2 = Vector2.ZERO
var _is_active: bool = false


func _ready() -> void:
	pass


func _process(delta: float) -> void:
	# Follow mouse while dragging
	if _is_active and _active_drag_sprite and _dragging:
		_active_drag_sprite.global_position = get_global_mouse_position() + _drag_offset


func _input_event(viewport, event, shape_idx) -> void:
	# Handle bin clicks to start dragging
	if not is_draggable or _dragging or count <= 0:
		return

	if event is InputEventMouseButton:
		var mb := event as InputEventMouseButton
		if mb.pressed and mb.button_index == drag_button:
			_spawn_draggable_at(mb.position)


func _unhandled_input(event: InputEvent) -> void:
	# Handle mouse release and motion while dragging
	if not _dragging or not _active_drag_sprite:
		return
	
	if event is InputEventMouseButton:
		var mb := event as InputEventMouseButton
		if mb.button_index == drag_button and not mb.pressed:
			_dragging = false
			_on_item_drag_ended(_active_drag_sprite)
			_active_drag_sprite = null
			_is_active = false
	elif event is InputEventMouseMotion:
		if _dragging and _active_drag_sprite:
			_active_drag_sprite.global_position = get_global_mouse_position() + _drag_offset


func _spawn_draggable_at(global_point: Vector2) -> void:
	# Create draggable sprite and start dragging
	var sprite = Sprite2D.new()
	var sprite_scale_to_use = Vector2.ONE
	
	# Try to get texture and scale from output item's properties
	if output_item_type != Item.ResourceType.NONE:
		var temp_item: Item = null
		match output_item_type:
			Item.ResourceType.ROCK:
				temp_item = RockItem.new()
			Item.ResourceType.PLANT:
				temp_item = PlantItem.new()
			Item.ResourceType.ANIMAL:
				temp_item = AnimalItem.new()
			Item.ResourceType.REFINED_ROCK:
				temp_item = RefinedRockItem.new()
			Item.ResourceType.REFINED_PLANT:
				temp_item = RefinedPlantItem.new()
			Item.ResourceType.REFINED_ANIMAL:
				temp_item = RefinedAnimalItem.new()
	
		if temp_item:
			if temp_item.icon:
				sprite.texture = temp_item.icon
			# Use the item's sprite scale
			sprite_scale_to_use = temp_item.sprite_scale
	
	# Fall back to item_texture if no icon found
	if not sprite.texture and item_texture:
		sprite.texture = item_texture
	
	sprite.global_position = global_point
	sprite.scale = sprite_scale_to_use
	sprite.set_meta("origin_bin", self)
	
	var root = get_tree().get_current_scene() if get_tree().get_current_scene() else get_tree().get_root()
	root.add_child(sprite)
	
	_active_drag_sprite = sprite
	_dragging = true
	_drag_offset = sprite.global_position - get_global_mouse_position()
	_is_active = true


func _on_item_drag_ended(draggable) -> void:
	# Check for receiving bins at drop location
	if not draggable:
		return

	var origin_bin = draggable.get_meta("origin_bin", null)
	var p: Vector2 = draggable.global_position
	var space := get_world_2d().direct_space_state
	var query := PhysicsPointQueryParameters2D.new()
	query.position = p
	query.collide_with_areas = true
	query.collide_with_bodies = false
	var results := space.intersect_point(query, 32)
	
	print("Drop detected at: ", p, " - Found ", results.size(), " objects")

	for r in results:
		if not r.has("collider"):
			continue
		var collider = r.collider
		print("  Collider: ", collider.name, " (", collider.get_class(), ")")
		
		if collider == origin_bin:
			print("    -> Is origin bin, deleting sprite")
			draggable.queue_free()
			return
		if collider is DraggableItemBin:
			var other_bin: DraggableItemBin = collider
			print("    -> Is DraggableItemBin, is_receiving: ", other_bin.is_receiving)
			if other_bin.is_receiving:
				var origin_item_type = _get_origin_bin_item_type(origin_bin)
				# For ItemMatcher and subclasses, always try to receive (they validate internally)
				# For other bins, check if type matches first
				var should_try_receive = (other_bin is ItemMatcher) or (origin_item_type != Item.ResourceType.NONE and origin_item_type in other_bin.receiving_items)
				print("      origin_item_type: ", origin_item_type, " should_try_receive: ", should_try_receive)
				if should_try_receive:
					var receive_result = other_bin._try_receive_item(origin_item_type)
					print("      _try_receive_item returned: ", receive_result)
					if receive_result:
						if origin_bin and origin_bin != other_bin and origin_bin.is_inside_tree():
							if origin_bin.has_method("decrement_count"):
								origin_bin.decrement_count()
							# Remove item from inventory if origin is InventoryStock
							if origin_bin is InventoryStock and Inventory:
								var items_of_type = Inventory.get_items_by_type(origin_item_type)
								if not items_of_type.is_empty():
									Inventory.remove_item(items_of_type[0])
						draggable.set_meta("origin_bin", other_bin)
						draggable.queue_free()
						return

	draggable.queue_free()


func _try_receive_item(item_type: Item.ResourceType = Item.ResourceType.NONE) -> bool:
	# Override in subclasses for custom receive logic
	if not is_receiving:
		return false
	increment_count()
	return true


func increment_count() -> void:
	# Add one item to this bin
	count += 1


func decrement_count() -> void:
	# Remove one item from this bin
	count -= 1


func _get_origin_bin_item_type(origin_bin) -> Item.ResourceType:
	# Get the item type from the origin bin
	if origin_bin and origin_bin is DraggableItemBin:
		return origin_bin.output_item_type
	return Item.ResourceType.NONE
