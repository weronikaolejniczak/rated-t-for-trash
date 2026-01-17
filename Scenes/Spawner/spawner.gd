extends Node3D

@export_category("General")
@export var is_enabled: bool = true
@export var objects_to_spawn: Array[PackedScene]
## How fast is the spawned object moving
@export_range(1.0, 8.0) var object_speed: float = 5.0
## How fast objects spawn
@export var timer_value: float = 0.5

@export_category("Position")
## The x offset in meters from the wall that the object spawned at
@export var spawn_x_offset: float = 2.0
## The y offset in meters from the player where the object may spawn
@export var spawn_y_offset: float = 5.0
## The z offset in meters from the player where the object may spawn
@export var spawn_z_offset: float = -1.0
## What is the minimum depth at which objects start spawning
@export_range(-20.0, -10.0) var min_spawn_depth: float = -10.0

@export_category("Rotation")
## Whether the objects rotate as they spawn
@export var should_rotate: bool = true
## The object's rotation angle in radians
@export var rotation_angle: float = 1.0

@onready var player: Player = $"../Player"
@onready var right_wall: CSGBox3D = $"../WorldBoundaries/Right wall"
@onready var left_wall: CSGBox3D = $"../WorldBoundaries/Left wall"
@onready var timer: Timer = $Timer

var sides: Array[String] = ["left", "right"]

func _ready() -> void:
	if (timer): timer.wait_time = timer_value

func get_wall(side: String) -> CSGBox3D:
	var wall: CSGBox3D
	if (side == 'left'): wall = left_wall
	else: wall = right_wall
	return wall

func get_spawn_x(wall: CSGBox3D, side: String) -> float:
	var spawn_x = wall.global_position.x
	if (side == 'left'): spawn_x -= spawn_x_offset
	else: spawn_x += spawn_x_offset
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

func get_spawn_rotation() -> Vector3:
	var x = randf_range(-1.0, 1.0)
	var y = randf_range(-1.0, 1.0)
	var z = randf_range(-1.0, 1.0)
	var spawn_rotation: Vector3 = Vector3(x, y, z).normalized()
	return spawn_rotation

func spawn_object():
	var side = sides.pick_random()
	var wall: CSGBox3D = get_wall(side)
	var spawn_x: float = get_spawn_x(wall, side)
	var spawn_y: float = get_spawn_y()
	var spawn_z: float = player.global_position.z + spawn_z_offset
	
	var object = objects_to_spawn.pick_random().instantiate()
	var spawn_position = Vector3(spawn_x, spawn_y, spawn_z)
	var spawn_direction = get_spawn_direction(side)
	var spawn_velocity = spawn_direction * object_speed
	var spawn_rotation = get_spawn_rotation()
	
	add_child(object)
	
	object.position = spawn_position
	object.velocity = spawn_velocity
	object.angular_velocity = spawn_rotation * rotation_angle

func _on_timer_timeout() -> void:
	if (is_enabled): spawn_object()
