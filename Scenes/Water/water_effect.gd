extends Node2D

@export var player: Player

@onready var mat: ShaderMaterial = $Texture.material

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if (mat and player):
		var pos = Vector2(player.global_position.x, player.global_position.y)
		mat.set_shader_parameter("world_offset", pos)
