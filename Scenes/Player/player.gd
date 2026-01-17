extends RigidBody3D
class_name Player

## How much thrust force to apply when moving
@export var thrust: float = 100.0

## How much torque force to apply when rotating
@export var torque_thrust: float = 25.0

## What is the max speed to clamp velocity
@export var max_speed: float = 200.0

@onready var bubble_particles: GPUParticles3D = $BubbleParticles
@onready var bg_music_emitter_3d: FmodEventEmitter3D = $BgMusicEmitter3D

func get_depth() -> int:
	var depth = floor(self.global_position.y)
	return depth

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if (Input.is_action_pressed("boost")):
		bubble_particles.emitting = true
		apply_central_force(-basis.y * delta * thrust)
		bg_music_emitter_3d.set_parameter("is_swimming", 1.0)
	else:
		bubble_particles.emitting = false
		bg_music_emitter_3d.set_parameter("is_swimming", 0.0)
	
	if (Input.is_action_pressed("rotate_left")):
		apply_torque(Vector3(0.0, 0.0, torque_thrust * delta))
	
	if (Input.is_action_pressed("rotate_right")):
		apply_torque(Vector3(0.0, 0.0, -torque_thrust * delta))
	
	if (Input.is_action_just_pressed("open_skill_tree")):
		bg_music_emitter_3d.set_parameter("menu_open", 1.0)
	
	if (linear_velocity.length() > max_speed):
		linear_velocity = linear_velocity.normalized() * max_speed
