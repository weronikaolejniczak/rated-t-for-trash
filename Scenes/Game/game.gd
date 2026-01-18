extends Node3D


## How fast does it get dark
@export_range(1000.0, 10000.0) var fog_depth_scale: float = 5000.0
## How deep the game level is (in Y axis)
@export_range(300.0, 2000.0) var target_depth: float = 500.0

@onready var player: Player = $Player
@onready var world_environment: WorldEnvironment = $WorldEnvironment

const MAX_VOLUMETRIC_FOG = 0.2
const MIN_VOLUMETRIC_FOG = 0.0001
const MAX_BG_ENERGY_MULTIPLIER = 3.0
const MIN_BG_ENERGY_MULTIPLIER = 0.5

func _process(_delta: float) -> void:
	var depth = player.get_depth()
	var depth_ratio = clamp(depth / -target_depth, 0.0, 1.0)
	# The cubic ratio makes the result get increasingly dramatic the deeper you go
	var eased_ratio = depth_ratio * depth_ratio * depth_ratio
	
	# We use volumetric fog to create a "Tyndall effect"
	var density = lerp(
		MIN_VOLUMETRIC_FOG,
		MAX_VOLUMETRIC_FOG,
		eased_ratio
	)
	var energy = lerp(
		MAX_BG_ENERGY_MULTIPLIER,
		MIN_BG_ENERGY_MULTIPLIER,
		eased_ratio
	)
	
	# bright and no light -> 0.001wwwww
	# first light -> 0.03
	# very dark -> 1.0sssssssssssssssssss
	# pitch black -> 2.0
	world_environment.environment.volumetric_fog_density = density
	
	# bright and no light -> 3.0
	# very dark -> 1.0
	# pitch black -> 0.5
	world_environment.environment.background_energy_multiplier = energy
