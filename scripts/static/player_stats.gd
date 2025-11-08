extends Node

signal stat_changed(stat_name: String, new_value)
signal money_changed(new_money: int)


# Money
var current_money: int = 1000
var reward_multiplier: float = 1.0
var incorrect_multiplier: float = 0.20

# Score
var current_score: int = 0

# Oxygen upgrades
var oxygen_upgrades: int = 0
var oxygen_upgrade_base_cost: int = 100
var oxygen_upgrade_cost_multiplier: float = 1.2
var oxygen_upgrade_current_cost: int = oxygen_upgrade_base_cost

# Fuel upgrades
var fuel_upgrades: int = 0
var fuel_upgrade_base_cost: int = 50
var fuel_upgrade_cost_multiplier: float = 1.2
var fuel_upgrade_current_cost: int = fuel_upgrade_base_cost

# Processing upgrades
var processing_upgrades: int = 0
var processing_speed: float:
	get:
		return processing_upgrades * 0.1 + 1.0
var processing_upgrade_base_cost: int = 150
var processing_upgrade_cost_multiplier: float = 1.2
var processing_upgrade_current_cost: int = processing_upgrade_base_cost

# Inventory upgrades
var max_inventory_size: int:
	get:
		return 10 + inventory_upgrades * 5
var inventory_upgrades: int = 0
var inventory_upgrade_base_cost: int = 200
var inventory_upgrade_cost_multiplier: float = 1.2
var inventory_upgrade_current_cost: int = inventory_upgrade_base_cost


func _ready() -> void:
	pass

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
