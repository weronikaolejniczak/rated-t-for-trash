extends Node3D

## See in the attached AnimationPlayer what animations are available
@export var animation_name: String

@onready var animation_player: AnimationPlayer = $AnimationPlayer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if (animation_name):
		animation_player.get_animation(animation_name).loop_mode = Animation.LOOP_LINEAR
		animation_player.play(animation_name)
