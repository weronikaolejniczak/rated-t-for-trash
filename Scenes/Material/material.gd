extends Node3D

@export var variants: Array[PackedScene]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var scene: PackedScene = variants.pick_random()
	var instance: Node3D = scene.instantiate()
	add_child(instance)
