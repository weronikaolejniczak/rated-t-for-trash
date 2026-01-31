extends WorldEnvironment


const TARGET_DEPTH = 400.0
const MIN_SUN_LIGHT_ENERGY: float = 0.01
const MAX_SUN_LIGHT_ENERGY: float = 1.5
const MIN_BG_ENERGY_MULTIPLIER: float = 0.01
const MAX_BG_ENERGY_MULTIPLIER: float = 1.5
const MIN_VOLUMETRIC_FOG_DENSITY: float = 0.0
const MAX_VOLUMETRIC_FOG_DENSITY: float = 0.1

@onready var game: Node3D = $".."
@onready var player: Player = $"../Player"
@onready var sun: DirectionalLight3D = $"../DirectionalLight3D"


func _physics_process(_delta: float) -> void:
	var depth = abs(player.get_depth())
	var depth_ratio = depth / TARGET_DEPTH
	
	sun.light_energy = lerp(
		MAX_SUN_LIGHT_ENERGY,
		MIN_SUN_LIGHT_ENERGY,
		depth_ratio
	)
	environment.background_energy_multiplier = lerp(
		MAX_BG_ENERGY_MULTIPLIER,
		MIN_BG_ENERGY_MULTIPLIER,
		depth_ratio
	)
	environment.volumetric_fog_density = lerp(
		MIN_VOLUMETRIC_FOG_DENSITY,
		MAX_VOLUMETRIC_FOG_DENSITY,
		depth_ratio
	)
