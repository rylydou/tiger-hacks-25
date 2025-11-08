extends DraggableItemBin
class_name InventoryStock

# Subclass that syncs with the Inventory autoload


func _ready() -> void:
	# Connect to inventory signals and sync count
	super._ready()
	
	# Set output_item_type to track (same as what we display)
	if output_item_type != Item.ResourceType.NONE:
		# Set the sprite texture based on the item type
		var temp_item: Item = null
		match output_item_type:
			Item.ResourceType.ROCK:
				temp_item = RockItem.new()
			Item.ResourceType.PLANT:
				temp_item = PlantItem.new()
			Item.ResourceType.ANIMAL:
				temp_item = AnimalItem.new()
			Item.ResourceType.REFINED_ROCK:
				temp_item = RefinedRockItem.new() if ClassDB.class_exists("RefinedRockItem") else null
			Item.ResourceType.REFINED_PLANT:
				temp_item = RefinedPlantItem.new() if ClassDB.class_exists("RefinedPlantItem") else null
			Item.ResourceType.REFINED_ANIMAL:
				temp_item = RefinedAnimalItem.new() if ClassDB.class_exists("RefinedAnimalItem") else null
		
		if temp_item and temp_item.icon and not item_texture:
			item_texture = temp_item.icon
	
	if Inventory:
		Inventory.connect("item_added", Callable(self, "_on_inventory_item_added"))
		Inventory.connect("item_removed", Callable(self, "_on_inventory_item_removed"))
		Inventory.connect("inventory_changed", Callable(self, "_on_inventory_changed"))
		
		_update_count_from_inventory()


func _get_type_count() -> int:
	# Get count from inventory for this item type
	if not Inventory or output_item_type == Item.ResourceType.NONE:
		return 0
	
	return Inventory.get_count(output_item_type)


func _update_count_from_inventory() -> void:
	# Sync local count with inventory
	if not Inventory:
		# print("InventoryStock._update_count_from_inventory: Inventory is null!")
		return
	
	var new_count = _get_type_count()
	# print("InventoryStock._update_count_from_inventory: setting count to ", new_count)
	count = new_count


func _on_inventory_item_added(item: Item) -> void:
	# Update count when items are added
	# print("InventoryStock._on_inventory_item_added: item type = ", item.resource_type, ", tracking = ", output_item_type)
	if item.resource_type == self.output_item_type:
		_update_count_from_inventory()


func _on_inventory_item_removed(item: Item) -> void:
	# Update count when items are removed
	# print("InventoryStock._on_inventory_item_removed: item type = ", item.resource_type, ", tracking = ", output_item_type)
	if item.resource_type == self.output_item_type:
		_update_count_from_inventory()


func _on_inventory_changed() -> void:
	# Update count on any inventory change
	# print("InventoryStock._on_inventory_changed")
	_update_count_from_inventory()
