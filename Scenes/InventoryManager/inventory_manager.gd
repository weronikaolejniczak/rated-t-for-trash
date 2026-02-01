extends Node3D
class_name InventoryManager

static var inventory_limit: int = 10

static var inventory = {
	metal = 0,
	plastic = 0,
	wood = 0,
	gears = 0
}

static func adjust_resource(type: String, amount: int) -> void:
	if (not inventory.has(type)): return
	
	inventory[type] = clamp(inventory[type] + amount, 0, inventory_limit)

static func try_removing_resource(type: String, amount: int) -> bool:
	if (inventory.has(type) and inventory[type] >= amount):
		inventory[type] -= amount
		return true
	
	return false

static func try_removing_gears(amount: int) -> bool:
	if inventory.gears >= amount:
		inventory.gears -= amount
		return true
	
	return false

static func get_inventory() -> Dictionary:
	return inventory

static func get_inventory_limit() -> int:
	return inventory_limit

static func set_inventory_limit(amount: int) -> void:
	inventory_limit = amount

static func add_gear() -> void:
	inventory.gears += 1
