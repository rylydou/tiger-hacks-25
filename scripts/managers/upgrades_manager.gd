extends Control

@export var oxygen_upgrade_bar: HBoxContainer
@export var fuel_upgrade_bar: HBoxContainer
@export var processing_upgrade_bar: HBoxContainer
@export var inventory_upgrade_bar: HBoxContainer

@onready var oxygen_upgrade_button: Button = oxygen_upgrade_bar.get_node("UpgradeButton") if oxygen_upgrade_bar else null
@onready var fuel_upgrade_button: Button = fuel_upgrade_bar.get_node("UpgradeButton") if fuel_upgrade_bar else null
@onready var processing_upgrade_button: Button = processing_upgrade_bar.get_node("UpgradeButton") if processing_upgrade_bar else null
@onready var inventory_upgrade_button: Button = inventory_upgrade_bar.get_node("UpgradeButton") if inventory_upgrade_bar else null

@onready var oxygen_upgrade_label: Label = oxygen_upgrade_bar.get_node("NumberUpgrades") if oxygen_upgrade_bar else null
@onready var fuel_upgrade_label: Label = fuel_upgrade_bar.get_node("NumberUpgrades") if fuel_upgrade_bar else null
@onready var processing_upgrade_label: Label = processing_upgrade_bar.get_node("NumberUpgrades") if processing_upgrade_bar else null
@onready var inventory_upgrade_label: Label = inventory_upgrade_bar.get_node("NumberUpgrades") if inventory_upgrade_bar else null

func _ready() -> void:
	# Connect button signals
	if oxygen_upgrade_button:
		oxygen_upgrade_button.pressed.connect(upgrade_oxygen)
		update_info_text(oxygen_upgrade_button, oxygen_upgrade_label, Stats.oxygen_upgrade_current_cost, Stats.oxygen_upgrades)
	
	if fuel_upgrade_button:
		fuel_upgrade_button.pressed.connect(upgrade_fuel)
		update_info_text(fuel_upgrade_button, fuel_upgrade_label, Stats.fuel_upgrade_current_cost, Stats.fuel_upgrades)

	if processing_upgrade_button:
		processing_upgrade_button.pressed.connect(upgrade_processing_speed)
		update_info_text(processing_upgrade_button, processing_upgrade_label, Stats.processing_upgrade_current_cost, Stats.processing_upgrades)

	if inventory_upgrade_button:
		inventory_upgrade_button.pressed.connect(upgrade_inventory_size)
		update_info_text(inventory_upgrade_button, inventory_upgrade_label, Stats.inventory_upgrade_current_cost, Stats.inventory_upgrades)

	# Listen for money changes to update button affordability
	Stats.money_changed.connect(_on_money_changed)


func _process(delta: float) -> void:
	pass


func update_info_text(button: Button, label: Label, cost: int, level: int) -> void:
	"""Update button text to show cost"""
	button.text = "Cost: " + str(cost)
	label.text = "Level: " + str(level)
	


func _on_money_changed(new_money: int) -> void:
	"""Update button disabled states based on money"""
	if oxygen_upgrade_button:
		oxygen_upgrade_button.disabled = new_money < Stats.oxygen_upgrade_current_cost
	
	if fuel_upgrade_button:
		fuel_upgrade_button.disabled = new_money < Stats.fuel_upgrade_current_cost
	
	if processing_upgrade_button:
		processing_upgrade_button.disabled = new_money < Stats.processing_upgrade_current_cost
	
	if inventory_upgrade_button:
		inventory_upgrade_button.disabled = new_money < Stats.inventory_upgrade_current_cost


# Oxygen Upgrades
func upgrade_oxygen() -> bool:
	if not Stats.spend_money(Stats.oxygen_upgrade_current_cost):
		print("Not enough money for oxygen upgrade (costs ", Stats.oxygen_upgrade_current_cost, ")")
		return false
	
	Stats.oxygen_upgrades += 1
	Stats.oxygen_upgrade_current_cost = int(Stats.oxygen_upgrade_current_cost * Stats.oxygen_upgrade_cost_multiplier)
	update_info_text(oxygen_upgrade_button, oxygen_upgrade_label, Stats.oxygen_upgrade_current_cost, Stats.oxygen_upgrades)
	print("Purchased oxygen upgrade. Total: ", Stats.oxygen_upgrades, " | Next cost: ", Stats.oxygen_upgrade_current_cost)
	return true


# Fuel Upgrades
func upgrade_fuel() -> bool:
	if not Stats.spend_money(Stats.fuel_upgrade_current_cost):
		print("Not enough money for fuel upgrade (costs ", Stats.fuel_upgrade_current_cost, ")")
		return false
	
	Stats.fuel_upgrades += 1
	Stats.fuel_upgrade_current_cost = int(Stats.fuel_upgrade_current_cost * Stats.fuel_upgrade_cost_multiplier)
	update_info_text(fuel_upgrade_button, fuel_upgrade_label, Stats.fuel_upgrade_current_cost, Stats.fuel_upgrades)
	print("Purchased fuel upgrade. Total: ", Stats.fuel_upgrades, " | Next cost: ", Stats.fuel_upgrade_current_cost)
	return true


# Processing Speed Upgrades
func upgrade_processing_speed() -> bool:
	if not Stats.spend_money(Stats.processing_upgrade_current_cost):
		print("Not enough money for processing speed upgrade (costs ", Stats.processing_upgrade_current_cost, ")")
		return false
	
	# Increment processing upgrades (processing_speed is calculated from this in Stats)
	Stats.processing_upgrades += 1
	Stats.processing_upgrade_current_cost = int(Stats.processing_upgrade_current_cost * Stats.processing_upgrade_cost_multiplier)
	update_info_text(processing_upgrade_button, processing_upgrade_label, Stats.processing_upgrade_current_cost, Stats.processing_upgrades)
	print("Purchased processing speed upgrade. New speed: ", Stats.processing_speed, " | Next cost: ", Stats.processing_upgrade_current_cost)
	return true


# Inventory Size Upgrades
func upgrade_inventory_size() -> bool:
	if not Stats.spend_money(Stats.inventory_upgrade_current_cost):
		print("Not enough money for inventory upgrade (costs ", Stats.inventory_upgrade_current_cost, ")")
		return false
	
	Stats.inventory_upgrades += 1
	# Emit signal with new size (this will trigger Inventory to update)
	Stats.inventory_upgrade_current_cost = int(Stats.inventory_upgrade_current_cost * Stats.inventory_upgrade_cost_multiplier)
	update_info_text(inventory_upgrade_button, inventory_upgrade_label, Stats.inventory_upgrade_current_cost, Stats.inventory_upgrades)
	print("Purchased inventory upgrade. New size: ", Stats.max_inventory_size, " | Next cost: ", Stats.inventory_upgrade_current_cost)
	return true


# Get current upgrade levels for UI display
func get_oxygen_upgrades() -> int:
	return Stats.oxygen_upgrades


func get_fuel_upgrades() -> int:
	return Stats.fuel_upgrades


func get_processing_speed() -> float:
	return Stats.processing_speed


func get_inventory_size() -> int:
	return Stats.max_inventory_size


# Get current costs for UI display
func get_oxygen_cost() -> int:
	return Stats.oxygen_upgrade_current_cost


func get_fuel_cost() -> int:
	return Stats.fuel_upgrade_current_cost


func get_processing_cost() -> int:
	return Stats.processing_upgrade_current_cost


func get_inventory_cost() -> int:
	return Stats.inventory_upgrade_current_cost
