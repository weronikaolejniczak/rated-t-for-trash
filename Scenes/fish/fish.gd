extends Node3D

@export var variants: Array[PackedScene]

var velocity: Vector3 = Vector3.ZERO
var angular_velocity: Vector3 = Vector3.ZERO

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var scene: PackedScene = variants.pick_random()
	var instance: Node3D = scene.instantiate()
	add_child.call_deferred(instance)

func _process(delta: float) -> void:
	global_translate(velocity * delta)
	
	rotate_x(angular_velocity.x * delta)
	rotate_y(angular_velocity.y * delta)
	rotate_z(angular_velocity.z * delta)
