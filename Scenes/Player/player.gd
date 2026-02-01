extends RigidBody3D


@export_category("Movement")
## How much thrust force to apply when moving
@export var thrust: float = 100.0
## How much torque strength to apply when rotating
@export var torque_strength: float = 25.0
## What is the max speed to clamp velocity
@export var max_speed: float = 200.0

@export_category("Visuals")
## How much the mesh should tilt in radians
@export var tilt_angle: float = deg_to_rad(30.0)
## How fast should the robot tilt
@export var tilt_speed: float = 6.0

@onready var robot_mesh: Node3D = $Robot
@onready var bubble_particles: GPUParticles3D = $Robot/BubbleParticles
@onready var spot_light_3d: SpotLight3D = $Robot/Flashlight/SpotLight3D
@onready var animation_player: AnimationPlayer = $Robot/AnimationPlayer
@onready var robot_sfx_player_2d: AudioStreamPlayer2D = $RobotSFXPlayer2D
@onready var underwater_sfx_player_2d: AudioStreamPlayer2D = $UnderwaterSFXPlayer2D

var animations = ["Idle1", "Idle2", "Idle3"]
var initial_rotation: Vector3 = Vector3.ZERO
var robot_tween: Tween
var underwater_tween: Tween


func get_depth() -> int:
	var depth = floor(self.global_position.y)
	return depth

func get_current_thrust() -> float:
	return thrust

func play_robot_sfx() -> void:
	if robot_sfx_player_2d.playing: return
	if robot_tween: robot_tween.kill()
	robot_sfx_player_2d.play()
	robot_tween = create_tween()
	robot_tween.tween_property(robot_sfx_player_2d, "volume_db", 0, 0.05)

func stop_robot_sfx() -> void:
	if not robot_sfx_player_2d.playing: return
	if robot_tween == null or not robot_tween.is_running():
		robot_tween = create_tween()
		robot_tween.tween_property(robot_sfx_player_2d, "volume_db", 0, 0.05).set_trans(Tween.TRANS_SINE)
		robot_tween.finished.connect(robot_sfx_player_2d.stop)

func play_underwater_sfx() -> void:
	if underwater_sfx_player_2d.playing: return
	if underwater_tween: underwater_tween.kill()
	underwater_sfx_player_2d.play()
	underwater_tween = create_tween()
	underwater_tween.tween_property(underwater_sfx_player_2d, "volume_db", 0, 0.1)

func stop_underwater_sfx() -> void:
	if not underwater_sfx_player_2d.playing: return
	if underwater_tween == null or not underwater_tween.is_running():
		underwater_tween = create_tween()
		underwater_tween.tween_property(underwater_sfx_player_2d, "volume_db", 0, 0.3).set_trans(Tween.TRANS_SINE)
		underwater_tween.finished.connect(underwater_sfx_player_2d.stop)

func move_player(delta: float) -> void:
	var move_input = Vector3.ZERO
	var target_tilt = initial_rotation
	
	if (!animation_player.is_playing()):
		var random_animation = animations.pick_random()
		animation_player.play(random_animation)
	
	if Input.is_action_pressed("move_up"):
		move_input.y += 1
		target_tilt.x = -tilt_angle
	if Input.is_action_pressed("move_down"):
		move_input.y -= 1
		target_tilt.x = tilt_angle
	if Input.is_action_pressed("move_left"):
		move_input.x -= 1
		target_tilt.y = initial_rotation.y - tilt_angle
	if Input.is_action_pressed("move_right"):
		move_input.x += 1
		target_tilt.y = initial_rotation.y + tilt_angle
	
	if move_input != Vector3.ZERO:
		apply_central_force(move_input.normalized() * thrust * delta)
		bubble_particles.emitting = true
		play_robot_sfx()
		play_underwater_sfx()
	else:
		bubble_particles.emitting = false
		stop_robot_sfx()
		stop_underwater_sfx()
		
	robot_mesh.rotation.x = lerp(robot_mesh.rotation.x, target_tilt.x, delta * tilt_speed)
	robot_mesh.rotation.y = lerp(robot_mesh.rotation.y, target_tilt.y, delta * tilt_speed)
	robot_mesh.rotation.z = lerp(robot_mesh.rotation.z, target_tilt.z, delta * tilt_speed)

func _physics_process(delta: float) -> void:
	move_player(delta)
