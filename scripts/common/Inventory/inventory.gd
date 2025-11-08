extends Node

# Dictionary mapping ResourceType to their counts
# Format: { ResourceType.ROCK: 5, ResourceType.PLANT: 3, ... }
var items: Dictionary = {}

# Signals
signal item_added(item_type: Item.ResourceType, count: int)
signal item_removed(item_type: Item.ResourceType)
signal item_count_changed(item_type: Item.ResourceType, old_count: int, new_count: int)
signal inventory_changed


func _ready() -> void:
	pass


# Add or increase count of an item type
func add_item(item_type: Item.ResourceType, amount: int = 1) -> void:
	if item_type == Item.ResourceType.NONE:
		push_error("Cannot add NONE item type")
		return
	
	if item_type not in items:
		# New item type
		items[item_type] = amount
		item_added.emit(item_type, amount)
	else:
		# Item type already exists, increase count
		var old_count = items[item_type]
		items[item_type] += amount
		item_count_changed.emit(item_type, old_count, items[item_type])
	
	inventory_changed.emit()


# Remove an item type completely from inventory
func remove_item(item_type: Item.ResourceType) -> void:
	if item_type == Item.ResourceType.NONE:
		push_error("Cannot remove NONE item type")
		return
	
	if item_type not in items:
		push_warning("Item type not in inventory")
		return
	
	items.erase(item_type)
	item_removed.emit(item_type)
	inventory_changed.emit()


# Decrement count of an item type by 1 (remove entirely if count reaches 0)
func decrement_count(item_type: Item.ResourceType) -> void:
	if item_type == Item.ResourceType.NONE:
		push_error("Cannot decrement NONE item type")
		return
	
	if item_type not in items:
		push_warning("Item type not in inventory")
		return
	
	var old_count = items[item_type]
	items[item_type] -= 1
	
	if items[item_type] <= 0:
		remove_item(item_type)
	else:
		item_count_changed.emit(item_type, old_count, items[item_type])
		inventory_changed.emit()


# Set count of an item type
func set_count(item_type: Item.ResourceType, amount: int) -> void:
	if item_type == Item.ResourceType.NONE:
		push_error("Cannot set count for NONE item type")
		return
	
	if amount <= 0:
		if item_type in items:
			remove_item(item_type)
		return
	
	if item_type not in items:
		add_item(item_type, amount)
	else:
		var old_count = items[item_type]
		items[item_type] = amount
		item_count_changed.emit(item_type, old_count, amount)
		inventory_changed.emit()


# Get count of an item type
func get_count(item_type: Item.ResourceType) -> int:
	if item_type == Item.ResourceType.NONE:
		return 0
	
	if item_type in items:
		return items[item_type]
	
	return 0


# Check if inventory contains an item type
func has_item(item_type: Item.ResourceType) -> bool:
	return item_type in items and items[item_type] > 0


# Get all item types in inventory
func get_all_items() -> Array[Item.ResourceType]:
	var result: Array[Item.ResourceType] = []
	for item_type in items.keys():
		result.append(item_type)
	return result


# Get total number of unique item types
func get_total_items() -> int:
	return items.size()


# Get total quantity across all items
func get_total_quantity() -> int:
	var total = 0
	for count in items.values():
		total += count
	return total


# Clear entire inventory
func clear() -> void:
	items.clear()
	inventory_changed.emit()


# Print inventory contents (for debugging)
func print_inventory() -> void:
	print("=== INVENTORY ===")
	print("Total unique items: ", get_total_items())
	print("Total quantity: ", get_total_quantity())
	print()
	
	for item_type in items:
		var count = items[item_type]
		var type_name = Item.new().get_type_string() if item_type == Item.ResourceType.ROCK else "Unknown"
		match item_type:
			Item.ResourceType.ROCK:
				type_name = "Rock"
			Item.ResourceType.PLANT:
				type_name = "Plant"
			Item.ResourceType.ANIMAL:
				type_name = "Animal"
		print("- ", type_name, " x", count)
	
	print("=================")
