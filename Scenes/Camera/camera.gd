extends Node3D


## The node that the camera should follow
@export var target: Node3D


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta: float) -> void: 
	if (target):
		global_position = target.global_position
