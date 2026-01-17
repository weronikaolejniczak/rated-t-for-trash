extends Node3D

@onready var player: Player = $"../Player"
@onready var background_music: FmodEventEmitter2D = $BackgroundMusic

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if (Input.is_action_just_pressed("open_skill_tree")):
		background_music.set_parameter("menu_open", 1.0)
	
	# The naming is accidental, those are just adding sound layer
	if (player.is_inside_tree()):
		if (player.get_depth() < -20):
			background_music.set_parameter("is_swimming", 1.0)
		else:
			background_music.set_parameter("is_swimming", 0.0)
		
		if (player.get_depth() < -50):
			background_music.set_parameter("animals_spawn", 1.0)
		else:
			background_music.set_parameter("animals_spawn", 0.0)
		
		if (player.get_depth() < -150):
			background_music.set_parameter("nature_spawn", 1.0)
		else:
			background_music.set_parameter("nature_spawn", 0.0)
