extends Node3D


@export_category("General")
@export var is_enabled: bool = true
@export var objects_to_spawn: Array[PackedScene]
## How fast is the spawned object moving
@export_range(1.0, 8.0) var object_speed: float = 5.0
## How fast objects spawn
@export_range(0.1, 5.0) var timer_value: float = 0.5

@export_category("Position")
## The x offset in meters from the wall that the object spawned at
@export_range(5.0, 10.0) var spawn_x_offset: float = 5.0
## The y offset in meters from the player where the object may spawn
@export_range(2.0, 15.0) var spawn_y_offset: float = 10.0
## The z offset in meters from the player where the object may spawn
@export_range(-2.0, 2.0) var spawn_z_offset: float = -1.0
## What is the minimum depth at which objects start spawning
@export var min_spawn_depth: float = -10.0

@export_category("Rotation")
## Whether the object is rotating continuously
@export var is_continuously_rotating: bool = false
## The object's rotation angle in radians
@export var rotation_angle: float = 1.0

@onready var player: RigidBody3D = $"../Player"
@onready var spawn_left_wall: CSGBox3D = $"../WorldBoundaries/TransparentLeftWall"
@onready var spawn_right_wall: CSGBox3D = $"../WorldBoundaries/TransparentRightWall"
@onready var timer: Timer = $Timer

var sides: Array[String] = ["left", "right"]


func _ready() -> void:
	if (timer): timer.wait_time = timer_value

func _on_timer_timeout() -> void:
	if (is_enabled): spawn_object()

# UTILITY FUNCTIONS

func get_wall(side: String) -> CSGBox3D:
	var wall: CSGBox3D
	if (side == 'left'): wall = spawn_left_wall
	else: wall = spawn_right_wall
	return wall

func get_spawn_x(wall: CSGBox3D, side: String) -> float:
	var half_wall_width = wall.size.x / 2.0
	var spawn_x = wall.global_position.x
	var offset = half_wall_width + spawn_x_offset
	if (side == 'left'): spawn_x -= offset
	else: spawn_x += offset
	return spawn_x

func get_spawn_y() -> float:
	var random_offset: float = randf_range(-spawn_y_offset, spawn_y_offset)
	var spawn_y: float = min(player.get_depth() + random_offset, min_spawn_depth)
	return spawn_y

func get_spawn_direction(side: String) -> Vector3:
	var x: float
	if (side == "left"): x = 1.0
	else: x = -1.0
	return Vector3(x, 0.0, 0.0).normalized()

func get_spawn_angular_velocity() -> Vector3:
	var x = randf_range(-1.0, 1.0)
	var y = randf_range(-1.0, 1.0)
	var z = randf_range(-1.0, 1.0)
	var spawn_angular_velocity: Vector3 = Vector3(x, y, z).normalized()
	return spawn_angular_velocity

func get_spawn_rotation(side: String) -> Vector3:
	var spawn_rotation: Vector3 = Vector3.ZERO
	if (side == "left"): spawn_rotation.y = PI / 2
	else: spawn_rotation.y = -(PI / 2)
	return spawn_rotation

func spawn_object():
	var side = sides.pick_random()
	var wall: CSGBox3D = get_wall(side)
	var spawn_x: float = get_spawn_x(wall, side)
	var spawn_y: float = get_spawn_y()
	var z_jitter = randf_range(-2.0, 2.0)
	var spawn_z: float = player.global_position.z + spawn_z_offset + z_jitter
	
	var object = objects_to_spawn.pick_random().instantiate()
	var spawn_position = Vector3(spawn_x, spawn_y, spawn_z)
	var spawn_direction = get_spawn_direction(side)
	var spawn_velocity = spawn_direction * object_speed
	
	object.position = spawn_position
	object.linear_velocity = spawn_velocity
	
	add_child(object)
	
	if (is_continuously_rotating):
		var spawn_angular_velocity = get_spawn_angular_velocity()
		object.angular_velocity = spawn_angular_velocity * rotation_angle
	else:
		object.rotation = get_spawn_rotation(side)
