extends CharacterBody3D


@export var variants: Array[PackedScene]

var linear_velocity: Vector3 = Vector3.ZERO
var angular_velocity: Vector3 = Vector3.ZERO


func _ready() -> void:
	var scene: PackedScene = variants.pick_random()
	var instance: Node3D = scene.instantiate()
	add_child.call_deferred(instance)

func _physics_process(_delta: float) -> void:
	velocity = linear_velocity
	
	move_and_slide()
