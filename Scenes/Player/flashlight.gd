extends Node3D

@export var light_range: float = 2.0

@onready var camera: Camera3D = get_viewport().get_camera_3d()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	# var mouse_pos = get_viewport().get_mouse_position()
	
	# var ray_origin = camera.project_ray_origin(mouse_pos)
	# var ray_direction = camera.project_ray_normal(mouse_pos)
	
	# var plane = Plane(Vector3.FORWARD, global_position.z)
	# var hit = plane.intersects_ray(ray_origin, ray_direction)
	
	# look_at(hit, Vector3.UP)
	pass
