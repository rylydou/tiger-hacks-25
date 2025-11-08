extends CanvasLayer


func _on_button_button_down() -> void:
	var rock = RockItem.new()
	Inventory.add_item(rock)
