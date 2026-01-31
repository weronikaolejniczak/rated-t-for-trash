extends Node3D


@onready var game: Node3D = $".."
@onready var player: RigidBody3D = $"../Player"
@onready var fish_spawner: Node3D = $"../FishSpawner"

## Background music audio file path
@onready var music_player_2d: AudioStreamPlayer2D = $Player/MusicPlayer2D
@export var background_music_path: String = "res://Assets/bgm/bgm-loop.ogg"

var first_depth_state: float = 0.0
var second_depth_state: float = 0.0
var third_depth_state: float = 0.0

const FIRST_DEPTH_IN_METERS: float = 30.0
const THIRD_DEPTH_IN_PERCENT: float = 0.75


func _ready() -> void:
	# Load music
	music_player_2d.play()

func _process(_delta: float) -> void:
	if (player.is_inside_tree()):
		var depth = abs(player.get_depth())
		
		var first_depth = 1.0 if depth > FIRST_DEPTH_IN_METERS else 0.0
		if (first_depth != first_depth_state):
			first_depth_state = first_depth
		
		var second_depth = 1.0 if depth > fish_spawner.min_spawn_depth else 0.0
		if (second_depth != second_depth_state):
			second_depth_state = second_depth
		
		var nature_trigger = game.target_depth * THIRD_DEPTH_IN_PERCENT
		var third_depth = 1.0 if depth < -nature_trigger else 0.0
		if (third_depth != third_depth_state):
			third_depth_state = third_depth
