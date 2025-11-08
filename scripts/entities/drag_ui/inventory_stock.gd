extends DraggableItemBin
class_name InventoryStock

# Subclass that syncs with the Inventory autoload


func _ready() -> void:
	# Connect to inventory signals and sync count
	super._ready()
	
	if Inventory:
		Inventory.connect("item_added", Callable(self, "_on_inventory_item_added"))
		Inventory.connect("item_removed", Callable(self, "_on_inventory_item_removed"))
		Inventory.connect("item_count_changed", Callable(self, "_on_inventory_item_count_changed"))
		
		_update_count_from_inventory()


func _get_type_count() -> int:
	# Get count from inventory for this item type
	if not Inventory or item_type == Item.ResourceType.NONE:
		return 0
	
	return Inventory.get_count(item_type)


func _update_count_from_inventory() -> void:
	# Sync local count with inventory
	if not Inventory:
		return
	
	count = _get_type_count()


func _on_inventory_item_added(item_type: Item.ResourceType, item_count: int) -> void:
	# Update count when items are added
	if item_type == self.item_type:
		_update_count_from_inventory()


func _on_inventory_item_removed(item_type: Item.ResourceType) -> void:
	# Update count when items are removed
	if item_type == self.item_type:
		_update_count_from_inventory()


func _on_inventory_item_count_changed(item_type: Item.ResourceType, old_count: int, new_count: int) -> void:
	# Update count when inventory count changes
	if item_type == self.item_type:
		_update_count_from_inventory()
