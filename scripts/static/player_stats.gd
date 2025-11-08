extends Node

signal stat_changed(stat_name: String, new_value)
signal money_changed(new_money: int)

# Money
var current_money: int = 0
var reward_multiplier: float = 1.0
var incorrect_multiplier: float = 0.20

# Score
var current_score: int = 0

# Oxygen upgrades
var max_oxygen_upgrades: int = 5

# Fuel upgrades
var max_fuel_upgrades: int = 5

# Processing upgrades
var processing_speed: float = 1.0 # Percent of Speed (1.0 = 100%)

# Inventory upgrades
var max_inventory_size: int = 20


func _ready() -> void:
	Inventory.max_inventory_size = self.max_inventory_size

func get_processing_speed() -> float:
	return processing_speed

func add_money(amount: int) -> void:
	current_money += amount
	current_score += amount
	money_changed.emit(current_money)


func spend_money(amount: int) -> bool:
	if current_money >= amount:
		current_money -= amount
		money_changed.emit(current_money)
		return true
	return false