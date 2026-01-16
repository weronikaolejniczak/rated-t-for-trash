extends Node3D

@export var object_to_spawn: PackedScene

## The x offset in meters where the object may spawn
@export var spawn_x_offset: float = 2.0

## The y offset in meters where the object may spawn
@export var spawn_y_offset: float = 2.0

## What is the minimum depth at which objects start spawning
@export_range(-20.0, -10.0) var min_spawn_depth: float = -10.0

## How fast is the spawned object moving
@export var spawn_speed: float = 10.0

@onready var player: Player = $"../Player"
@onready var right_wall: CSGBox3D = $"../WorldBoundaries/Right wall"
@onready var left_wall: CSGBox3D = $"../WorldBoundaries/Left wall"

var sides: Array[String] = ["left", "right"]

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
	var spawn_y: float = min(player.get_depth(), min_spawn_depth)
	return spawn_y

func get_spawn_direction(side: String) -> Vector3:
	var x: float
	if (side == "left"): x = 1.0
	else: x = -1.0
	return Vector3(x, 0.0, 0.0).normalized()

func spawn_object():
	var side = sides.pick_random()
	var wall: CSGBox3D = get_wall(side)
	var spawn_x: float = get_spawn_x(wall, side)
	var spawn_y: float = get_spawn_y()
	
	var object = object_to_spawn.instantiate()
	var spawn_position = Vector3(spawn_x, spawn_y, player.global_position.z)
	var spawn_direction = get_spawn_direction(side)
	var spawn_velocity = spawn_direction * spawn_speed
	
	print("Object spawned at ", spawn_position, " with velocity ", spawn_velocity)
	
	object.position = spawn_position
	object.linear_velocity = spawn_velocity
	add_child(object)

func _on_timer_timeout() -> void:
	spawn_object()
