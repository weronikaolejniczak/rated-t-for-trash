extends Node3D

enum MaterialTypes { METAL, PLASTIC, WOOD }
enum MaterialSizes { SMALL, BIG }

@export_category("Material scenes")
@export var small_metal_variants: Array[PackedScene]
@export var big_metal_variants: Array[PackedScene]
@export var small_plastic_variants: Array[PackedScene]
@export var big_plastic_variants: Array[PackedScene]
@export var small_wood_variants: Array[PackedScene]
@export var big_wood_variants: Array[PackedScene]

var velocity: Vector3 = Vector3.ZERO
var angular_velocity: Vector3 = Vector3.ZERO
var random_material: MaterialTypes
var random_size: MaterialSizes

const RAY_LENGTH = 1000.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var materials = {
		MaterialTypes.METAL: {
			MaterialSizes.SMALL: small_metal_variants,
			MaterialSizes.BIG: big_metal_variants
		},
		MaterialTypes.PLASTIC: {
			MaterialSizes.SMALL: small_plastic_variants,
			MaterialSizes.BIG: big_plastic_variants
		},
		MaterialTypes.WOOD: {
			MaterialSizes.SMALL: small_wood_variants,
			MaterialSizes.BIG: big_wood_variants
		}
	}

	random_material = MaterialTypes.values().pick_random()
	random_size = MaterialSizes.values().pick_random()
	
	var variants: Array[PackedScene] = materials[random_material][random_size]
	if (variants.is_empty()): return push_error("Exported array is empty!")
	
	var scene: PackedScene = variants.pick_random()
	var instance: Node3D = scene.instantiate()
	add_child(instance)

func _process(delta: float) -> void:
	global_translate(velocity * delta)
	
	rotate_x(angular_velocity.x * delta)
	rotate_y(angular_velocity.y * delta)
	rotate_z(angular_velocity.z * delta)

func _input(event):
	if (event is InputEventMouseButton and event.pressed):
		var camera = get_viewport().get_camera_3d()
		if (not camera): return
		
		var ray_from = camera.project_ray_origin(event.position)
		var ray_to = ray_from + camera.project_ray_normal(event.position) * RAY_LENGTH

		var query_params = PhysicsRayQueryParameters3D.new()
		query_params.from = ray_from
		query_params.to = ray_to
		query_params.collide_with_bodies = true
		
		var result = get_world_3d().direct_space_state.intersect_ray(query_params)
		
		if (result and result.collider == self or is_ancestor_of(result.collider)):
			print("clicked ", MaterialSizes.find_key(random_size), " ", MaterialTypes.find_key(random_material))
