extends WorldEnvironment


## How deep the game level is (in Y axis)
@export_range(300.0, 2000.0) var target_depth: float = 500.0

@onready var player: Player = $"../Player"

## particle thickness: 0.0001 is crystal clear
const MIN_VOLUMETRIC_FOG = 0.0001
## particle thickness: 0.2 is murky/claustrophobic
const MAX_VOLUMETRIC_FOG = 0.2

## light intensity: 3.0 is surface glare
const MAX_BG_ENERGY_MULTIPLIER = 3.0
## light intensity: 0.5 is deep-sea abyss
const MIN_BG_ENERGY_MULTIPLIER = 0.5

## light scattering: 0.6 is bright surface glow
const MAX_ANISOTROPY = 0.6
## light scattering: 0.2 is dull/flat depth
const MIN_ANISOTROPY = 0.2

var surface_color = Color("4ed2ff")
var deep_color = Color("001c2bff")


func _process(_delta: float) -> void:
	var depth = player.get_depth()
	var depth_ratio = clamp(depth / -target_depth, 0.0, 1.0)
	
	var fog_density = lerp(
		MIN_VOLUMETRIC_FOG,
		MAX_VOLUMETRIC_FOG,
		depth_ratio
	)
	var fog_anisotropy = lerp(
		MAX_ANISOTROPY, 
		MIN_ANISOTROPY, 
		depth_ratio
	)
	var fog_albedo = lerp(
		surface_color, 
		deep_color, 
		depth_ratio
	)
	var energy = lerp(
		MAX_BG_ENERGY_MULTIPLIER,
		MIN_BG_ENERGY_MULTIPLIER,
		depth_ratio
	)
	
	environment.volumetric_fog_density = fog_density
	environment.volumetric_fog_anisotropy = fog_anisotropy
	environment.volumetric_fog_albedo = fog_albedo
	environment.background_energy_multiplier = energy
	
