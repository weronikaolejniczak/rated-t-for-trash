extends RigidBody3D
class_name Player

## How much thrust force to apply when moving
@export var thrust: float = 30.0

## How much torque force to apply when rotating
@export var torque_thrust: float = 20.0

## What is the max speed to clamp velocity
@export var max_speed: float = 15.0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:	
	if (Input.is_action_pressed("boost")):
		apply_central_force(-basis.y * delta * thrust)
		
	if (Input.is_action_pressed("rotate_left")):
		apply_torque(Vector3(0.0, 0.0, torque_thrust * delta))
		
	if (Input.is_action_pressed("rotate_right")):
		apply_torque(Vector3(0.0, 0.0, -torque_thrust * delta))
		
	if (linear_velocity.length() > max_speed):
		linear_velocity = linear_velocity.normalized() * max_speed
