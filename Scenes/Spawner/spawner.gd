extends Node3D

@export var object_to_spawn: PackedScene
@export var spawn_interval: float = 1.0
@export var speed: float = 5.0
@export var left_x: float = -10.0
@export var right_x: float = 10.0
@export var up_y = 4.0
@export var down_y = -4.0

var sides: Array[String] = ["left", "right"]

func spawn_object():
	var side = sides.pick_random()
	var object = object_to_spawn.instantiate()
	var position = Vector3(0.0, 0.0, 0.0)
	
	object.position = position
	add_child(object)

func _on_timer_timeout() -> void:
	spawn_object()
