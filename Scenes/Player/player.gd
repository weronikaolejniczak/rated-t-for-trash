extends RigidBody3D
class_name Player

@export_category("Movement")
## How much thrust force to apply when moving
@export var thrust: float = 100.0
## How much torque strength to apply when rotating
@export var torque_strength: float = 25.0
## What is the max speed to clamp velocity
@export var max_speed: float = 200.0

@export_category("Visuals")
## How much the mesh should tilt in radians
@export var tilt_angle: float = deg_to_rad(30.0)
## How fast should the robot tilt
@export var tilt_speed: float = 6.0

@export_category("Upgrades")
## What's the initial cost in resources (metal, plastic, wood) for upgrade
@export var initial_upgrade_cost: int = 10
## What's the thrust upgrade amount
@export var thrust_upgrade_amount: float = 50.0
## What's the cargo space upgrade amount
@export var space_upgrade_amount: int = 10
## What's the light strength upgrade amount
@export var light_upgrade_amount: float = 0.5

@onready var robot_sfx: FmodEventEmitter2D = $RobotSFX
@onready var robot_mesh: Node3D = $Robot
@onready var bubble_particles: GPUParticles3D = $Robot/BubbleParticles
@onready var spot_light_3d: SpotLight3D = $Robot/Flashlight/SpotLight3D
@onready var animation_player: AnimationPlayer = $Robot/AnimationPlayer

var animations = ["Idle1", "Idle2", "Idle3"]
var initial_rotation: Vector3 = Vector3.ZERO

static var inventory_limit: int = 10

static var inventory = {
	metal = 0,
	plastic = 0,
	wood = 0
}

# RESOURCE LOGIC

static func adjust_resource(type: String, amount: int) -> void:
	if (not inventory.has(type)): return
	
	inventory[type] = clamp(inventory[type] + amount, 0, inventory_limit)

static func try_removing_resource(type: String, amount: int) -> bool:
	if (inventory.has(type) and inventory[type] >= amount):
		inventory[type] -= amount
		return true
	
	return false

# INVENTORY LOGIC

static func get_inventory() -> Dictionary:
	return inventory

static func get_inventory_limit() -> int:
	return inventory_limit

static func set_inventory_limit(amount: int) -> void:
	inventory_limit = amount

func get_depth() -> int:
	var depth = floor(self.global_position.y)
	return depth

func get_current_thrust() -> float:
	return thrust

# SPEED

func get_speed_level() -> float:
	return (thrust - 100.0) / thrust_upgrade_amount

func get_speed_cost() -> int:
	return initial_upgrade_cost + (int(get_speed_level()) * 10)

func upgrade_speed() -> float:
	if try_removing_resource("metal", get_speed_cost()):
		thrust += thrust_upgrade_amount
		return true
	
	return false

# SPACE

func get_space_level() -> float:
	return (inventory_limit - 10.0) / space_upgrade_amount

func get_space_cost() -> int:
	return initial_upgrade_cost + (int(get_space_level()) * 10)

func upgrade_space() -> bool:
	if try_removing_resource("plastic", get_space_cost()):
		inventory_limit += space_upgrade_amount
		return true
	
	return false

# LIGHT

func get_light_level() -> float:
	return (spot_light_3d.spot_range - 5.0) / light_upgrade_amount

func get_light_cost() -> int:
	return initial_upgrade_cost + (int(get_light_level()) * 10)

func upgrade_light() -> bool:
	if try_removing_resource("wood", get_light_cost()):
		spot_light_3d.spot_range += light_upgrade_amount
		spot_light_3d.light_energy += 2.0
		return true
	
	return false

# INTERNAL METHODS AND SIGNALS

func _physics_process(delta: float) -> void:
	var move_input = Vector3.ZERO
	var target_tilt = initial_rotation
	
	if (!animation_player.is_playing()):
		var random_animation = animations.pick_random()
		animation_player.play(random_animation)
	
	if Input.is_action_pressed("move_up"):
		move_input.y += 1
		target_tilt.x = -tilt_angle
	if Input.is_action_pressed("move_down"):
		move_input.y -= 1
		target_tilt.x = tilt_angle
	if Input.is_action_pressed("move_left"):
		move_input.x -= 1
		target_tilt.y = initial_rotation.y - tilt_angle
	if Input.is_action_pressed("move_right"):
		move_input.x += 1
		target_tilt.y = initial_rotation.y + tilt_angle
	
	if move_input != Vector3.ZERO:
		apply_central_force(move_input.normalized() * thrust * delta)
		bubble_particles.emitting = true
		robot_sfx.set_parameter("state", "swimming")
	else:
		bubble_particles.emitting = false
		robot_sfx.set_parameter("state", "idle")
	
	robot_mesh.rotation.x = lerp(robot_mesh.rotation.x, target_tilt.x, delta * tilt_speed)
	robot_mesh.rotation.y = lerp(robot_mesh.rotation.y, target_tilt.y, delta * tilt_speed)
	robot_mesh.rotation.z = lerp(robot_mesh.rotation.z, target_tilt.z, delta * tilt_speed)
