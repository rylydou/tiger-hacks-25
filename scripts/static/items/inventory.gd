extends Node

# Array of Item instances
var items: Array[Item] = []

# Signals
signal item_added(item: Item)
signal item_removed(item: Item)
signal inventory_changed
signal inventory_full


func _ready() -> void:
	pass


# Add an item to inventory
func add_item(item: Item) -> bool:
	# Check if inventory is full
	if items.size() >= Stats.max_inventory_size:
		inventory_full.emit()
		return false
	
	items.append(item)
	item_added.emit(item)
	inventory_changed.emit()
	return true


# Remove an item by index
func remove_item_at(index: int) -> bool:
	if index < 0 or index >= items.size():
		push_warning("Invalid item index: ", index)
		return false
	
	var item = items[index]
	items.remove_at(index)
	item_removed.emit(item)
	inventory_changed.emit()
	return true


# Remove a specific item instance
func remove_item(item: Item) -> bool:
	var index = items.find(item)
	if index == -1:
		push_warning("Item not in inventory")
		return false
	
	return remove_item_at(index)


# Get item by index
func get_item(index: int) -> Item:
	if index < 0 or index >= items.size():
		push_warning("Invalid item index: ", index)
		return null
	
	return items[index]


# Get all items of a specific type
func get_items_by_type(item_type: Item.ResourceType) -> Array[Item]:
	var result: Array[Item] = []
	for item in items:
		if item.resource_type == item_type:
			result.append(item)
	return result


# Get count of items of a specific type
func get_count(item_type: Item.ResourceType) -> int:
	return get_items_by_type(item_type).size()


# Check if inventory contains a specific item
func has_item(item: Item) -> bool:
	return items.find(item) != -1


# Check if inventory has any items of a type
func has_item_type(item_type: Item.ResourceType) -> bool:
	return get_count(item_type) > 0


# Get all items
func get_all_items() -> Array[Item]:
	return items


# Get current inventory size
func get_size() -> int:
	return items.size()


# Get remaining space
func get_remaining_space() -> int:
	return Stats.max_inventory_size - items.size()


# Check if inventory is full
func is_full() -> bool:
	return items.size() >= Stats.max_inventory_size


# Check if inventory is empty
func is_empty() -> bool:
	return items.size() == 0


# Clear entire inventory
func clear() -> void:
	items.clear()
	inventory_changed.emit()


# Print inventory contents
func print_inventory() -> void:
	print("=== INVENTORY ===")
	print("Size: ", items.size(), " / ", Stats.max_inventory_size)
	print()
	
	for i in range(items.size()):
		var item = items[i]
		print("- [", i, "] ", item.item_name, " (", item.get_type_string(), ")")
	
	print("=================")
