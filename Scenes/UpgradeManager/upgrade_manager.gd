extends Node3D
class_name UpgradeManager


## Player that the upgrades apply to
@export var player: RigidBody3D
## Level boundaries node
@export var level_boundaries: Node3D
## What's the initial cost in resources (metal, plastic, wood) for upgrade
@export var initial_upgrade_cost: int = 10

@export_category("Thrust upgrade")
## What's the thrust upgrade amount
@export var thrust_upgrade_amount: float = 50.0
## What's the max depth level
@export var max_thrust_level: int = 4

@export_category("Cargo space upgrade")
## What's the cargo space upgrade amount
@export var space_upgrade_amount: int = 10
## What's the max depth level
@export var max_space_level: int = 4

@export_category("Light upgrade")
## What's the light strength upgrade amount
@export var light_upgrade_amount: float = 0.5
## What's the max depth level
@export var max_light_level: int = 4

@export_category("Depth level upgrade")
## What's the depth upgrade amount
@export var depth_upgrade_amount: int = 1
## What's the max depth level
@export var max_depth_level: int = 4

var depth_level: int = 1


func get_speed_level() -> float:
	return (player.thrust - 100.0) / thrust_upgrade_amount

func get_speed_cost() -> int:
	return initial_upgrade_cost + (int(get_speed_level()) * 10)

func upgrade_speed() -> float:
	if InventoryManager.try_removing_resource("metal", get_speed_cost()):
		player.thrust += thrust_upgrade_amount
		return true
	
	return false

func get_space_level() -> float:
	return (InventoryManager.inventory_limit - 10.0) / space_upgrade_amount

func get_space_cost() -> int:
	return initial_upgrade_cost + (int(get_space_level()) * 10)

func upgrade_space() -> bool:
	if InventoryManager.try_removing_resource("plastic", get_space_cost()):
		InventoryManager.inventory_limit += space_upgrade_amount
		return true
	
	return false

func get_light_level() -> float:
	var level = (player.spot_light_3d.spot_range - 4.0) / light_upgrade_amount
	return level

func get_light_cost() -> int:
	return initial_upgrade_cost + (int(get_light_level()) * 10)

func upgrade_light() -> bool:
	if InventoryManager.try_removing_resource("wood", get_light_cost()):
		player.spot_light_3d.spot_range += light_upgrade_amount
		player.spot_light_3d.light_energy += 2.0
		return true
	
	return false

func get_depth_level() -> int:
	return depth_level

func get_depth_cost() -> int:
	return get_depth_level()

func unlock_depth_level() -> bool:
	if depth_level == max_depth_level: return false
	
	if InventoryManager.try_removing_gears(get_depth_cost()):
		depth_level += 1
		# First boundary is at index 0 but the depth level will be 2
		# Last boundary is at index 2 but the depth level will be 4
		level_boundaries.get_child(depth_level - 2).use_collision = false
		return true
	
	return false
