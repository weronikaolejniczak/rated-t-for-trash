extends Node3D

@export var object_to_spawn: PackedScene
@export var spawn_interval: float = 1.0
@export var speed: float = 5.0
@export var left_x: float = -10.0
@export var right_x: float = 10.0
@export var min_y = 1.0
@export var max_y = 5.0

@onready var camera_3d: Camera3D = $"../Camera/Camera3D"

var sides: Array[String] = ["left", "right"]
var timer: float = 0.0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	timer += delta
	
	if (timer >= spawn_interval):
		timer = 0
		spawn_object()

func spawn_object():
	var side = sides.pick_random()
	# var object = object_to_spawn.instantiate()
