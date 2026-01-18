extends RigidBody3D
class_name Player


## How much thrust force to apply when moving
@export var thrust: float = 100.0
## How much torque strength to apply when rotating
@export var torque_strength: float = 25.0
## What is the max speed to clamp velocity
@export var max_speed: float = 200.0
## How much the mesh should tilt in radians
@export var tilt_angle: float = deg_to_rad(30.0)
## How fast should the robot tilt
@export var tilt_speed: float = 6.0

@onready var robot_sfx: FmodEventEmitter2D = $RobotSFX
@onready var robot_mesh: Node3D = $Robot
@onready var bubble_particles: GPUParticles3D = $Robot/BubbleParticles
# Make range configurable up to 7m, energy to 14
#@onready var spot_light_3d: SpotLight3D = $Robot/Flashlight/SpotLight3D

var initial_rotation: Vector3 = Vector3.ZERO

static var inventory_limit: int = 999

static var inventory = {
	metal = 0,
	plastic = 0,
	wood = 0
}


static func adjust_resource(type: String, amount: int) -> void:
	if (not inventory.has(type)): return
	
	inventory[type] = clamp(inventory[type] + amount, 0, inventory_limit)

static func try_removing_resource(type: String, amount: int) -> bool:
	if (inventory.has(type) and inventory[type] >= amount):
		inventory[type] -= amount
		return true
	
	return false

static func get_inventory() -> Dictionary:
	return inventory

static func get_inventory_limit() -> int:
	return inventory_limit

static func set_inventory_limit(amount: int) -> void:
	inventory_limit = amount

func get_depth() -> int:
	var depth = floor(self.global_position.y)
	return depth


# INTERNAL METHODS AND SIGNALS

func _physics_process(delta: float) -> void:
	var move_input = Vector3.ZERO
	var target_tilt = initial_rotation
	
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
