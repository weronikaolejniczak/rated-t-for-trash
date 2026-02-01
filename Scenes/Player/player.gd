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

@export_category("Upgrades")
## What's the initial cost in resources (metal, plastic, wood) for upgrade
@export var initial_upgrade_cost: int = 10
## What's the thrust upgrade amount
@export var thrust_upgrade_amount: float = 50.0
## What's the cargo space upgrade amount
@export var space_upgrade_amount: int = 10
## What's the light strength upgrade amount
@export var light_upgrade_amount: float = 0.5

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

# SPEED

func get_speed_level() -> float:
	return (thrust - 100.0) / thrust_upgrade_amount

func get_speed_cost() -> int:
	return initial_upgrade_cost + (int(get_speed_level()) * 10)

func upgrade_speed() -> float:
	if InventoryManager.try_removing_resource("metal", get_speed_cost()):
		thrust += thrust_upgrade_amount
		return true
	
	return false

# SPACE

func get_space_level() -> float:
	return (InventoryManager.inventory_limit - 10.0) / space_upgrade_amount

func get_space_cost() -> int:
	return initial_upgrade_cost + (int(get_space_level()) * 10)

func upgrade_space() -> bool:
	if InventoryManager.try_removing_resource("plastic", get_space_cost()):
		InventoryManager.inventory_limit += space_upgrade_amount
		return true
	
	return false

# LIGHT

func get_light_level() -> float:
	var level = (spot_light_3d.spot_range - 4.0) / light_upgrade_amount
	return level

func get_light_cost() -> int:
	return initial_upgrade_cost + (int(get_light_level()) * 10)

func upgrade_light() -> bool:
	if InventoryManager.try_removing_resource("wood", get_light_cost()):
		spot_light_3d.spot_range += light_upgrade_amount
		spot_light_3d.light_energy += 2.0
		return true
	
	return false

# INTERNAL METHODS AND SIGNALS

func _physics_process(delta: float) -> void:
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
	
		if not robot_sfx_player_2d.playing:
			if robot_tween: robot_tween.kill()
			robot_sfx_player_2d.play()
			robot_tween = create_tween()
			robot_tween.tween_property(robot_sfx_player_2d, "volume_db", 0, 0.05)
		if not underwater_sfx_player_2d.playing:
			if underwater_tween: underwater_tween.kill()
			underwater_sfx_player_2d.play()
			underwater_tween = create_tween()
			underwater_tween.tween_property(underwater_sfx_player_2d, "volume_db", 0, 0.1)
	else:
		bubble_particles.emitting = false
		if robot_sfx_player_2d.playing:
			if robot_tween == null or not robot_tween.is_running():
				robot_tween = create_tween()
				robot_tween.tween_property(robot_sfx_player_2d, "volume_db", 0, 0.05).set_trans(Tween.TRANS_SINE)
				robot_tween.finished.connect(robot_sfx_player_2d.stop)
		
		if underwater_sfx_player_2d.playing:
			if underwater_tween == null or not underwater_tween.is_running():
				underwater_tween = create_tween()
				underwater_tween.tween_property(underwater_sfx_player_2d, "volume_db", 0, 0.3).set_trans(Tween.TRANS_SINE)
				underwater_tween.finished.connect(underwater_sfx_player_2d.stop)
		
	robot_mesh.rotation.x = lerp(robot_mesh.rotation.x, target_tilt.x, delta * tilt_speed)
	robot_mesh.rotation.y = lerp(robot_mesh.rotation.y, target_tilt.y, delta * tilt_speed)
	robot_mesh.rotation.z = lerp(robot_mesh.rotation.z, target_tilt.z, delta * tilt_speed)
