extends CanvasLayer


func _on_button_button_down() -> void:
	Inventory.add_item(Item.ResourceType.ROCK)
