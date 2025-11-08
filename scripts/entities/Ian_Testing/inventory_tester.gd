extends CanvasLayer


func _increase_rocks() -> void:
	var rock = RockItem.new()
	Inventory.add_item(rock)

func _increase_animal() -> void:
	var animal = AnimalItem.new()
	Inventory.add_item(animal)

func _increase_plant() -> void:
	var plant = PlantItem.new()
	Inventory.add_item(plant)
