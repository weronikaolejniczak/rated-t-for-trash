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

var initial_rotation: Vector3 = Vector3.ZERO

var player_inventory = {
	metal = 0,
	plastic = 0,
	wood = 0
}

func add_metal(amount: int) -> void: player_inventory.metal += amount

func remove_metal(amount: int) -> void: player_inventory.metal -= amount

func add_plastic(amount: int) -> void: player_inventory.plastic += amount

func remove_plastic(amount: int) -> void: player_inventory.plastic -= amount

func add_wood(amount: int) -> void: player_inventory.wood += amount

func remove_wood(amount: int) -> void: player_inventory.wood -= amount

func get_inventory() -> Dictionary:
	return player_inventory

func get_depth() -> int:
	var depth = floor(self.global_position.y)
	return depth

func _process(_delta: float) -> void:
	# print(player_inventory)
	pass

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
		robot_sfx.set_parameter("states", "swimming")
	else:
		bubble_particles.emitting = false
		robot_sfx.set_parameter("states", "idle")
	
	robot_mesh.rotation.x = lerp(robot_mesh.rotation.x, target_tilt.x, delta * tilt_speed)
	robot_mesh.rotation.y = lerp(robot_mesh.rotation.y, target_tilt.y, delta * tilt_speed)
	robot_mesh.rotation.z = lerp(robot_mesh.rotation.z, target_tilt.z, delta * tilt_speed)
