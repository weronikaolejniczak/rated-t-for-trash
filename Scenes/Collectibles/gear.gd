extends CharacterBody3D


@export_category("Rotation")
@export_range(0.005, 0.05) var x_rotation_angle: float = 0.01
@export_range(0.005, 0.05) var y_rotation_angle: float = 0.02

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var gpu_particles_3d: GPUParticles3D = $GPUParticles3D


func _physics_process(_delta: float) -> void:
	rotate_x(x_rotation_angle)
	rotate_y(y_rotation_angle)

func _on_interact_area_3d_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		InventoryManager.add_gear()
		destroy()

func destroy() -> void:
	animation_player.play("scale_down")
	gpu_particles_3d.emitting = true
	await get_tree().create_timer(gpu_particles_3d.lifetime).timeout
	queue_free.call_deferred()
