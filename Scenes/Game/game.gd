extends Node3D

## How fast does it get dark
@export_range(1000.0, 10000.0) var fog_depth_scale: float = 5000.0

@onready var player: Player = $Player
@onready var world_environment: WorldEnvironment = $WorldEnvironment

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	var depth = player.get_depth()
	var density = clamp(abs(depth) / fog_depth_scale, 0.0001, 0.2)
	
	# bright and no light -> 0.001
	# first light -> 0.03
	# very dark -> 1.0
	# pitch black -> 2.0
	world_environment.environment.volumetric_fog_density = density
