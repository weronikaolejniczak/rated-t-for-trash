extends CharacterBody3D


@export_category("Material scenes")
@export var small_metal_variants: Array[PackedScene]
@export var big_metal_variants: Array[PackedScene]
@export var small_plastic_variants: Array[PackedScene]
@export var big_plastic_variants: Array[PackedScene]
@export var small_wood_variants: Array[PackedScene]
@export var big_wood_variants: Array[PackedScene]

@export_category("Resource amounts")
## How many resources does a small material give
@export var small_material_gain: int = 1
## How many resources does a big material give
@export var big_material_gain: int = 3
## By how much does the hit increment when clicking
@export var incrementer: int = 1

@onready var player: RigidBody3D = $"../../Player"
@onready var wood_player_3d: AudioStreamPlayer3D = $WoodPlayer3D
@onready var plastic_player_3d: AudioStreamPlayer3D = $PlasticPlayer3D
@onready var metal_player_3d: AudioStreamPlayer3D = $MetalPlayer3D
@onready var click_particles: GPUParticles3D = $ClickParticles

enum MaterialTypes { METAL, PLASTIC, WOOD }
enum MaterialSizes { SMALL, BIG }

var linear_velocity: Vector3 = Vector3.ZERO
var angular_velocity: Vector3 = Vector3.ZERO
var random_material: MaterialTypes
var random_size: MaterialSizes
var click_counter: int = 0

const RAY_LENGTH = 1000.0


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
	add_child.call_deferred(instance)
	
	for child in instance.get_children():
		if (child is CollisionShape3D):
			child.reparent.call_deferred(self)

func _physics_process(delta: float) -> void:
	velocity = linear_velocity
	
	rotate_x(angular_velocity.x * delta)
	rotate_y(angular_velocity.y * delta)
	rotate_z(angular_velocity.z * delta)
	
	move_and_slide()

func _input(event):
	if not (event is InputEventMouseButton and event.pressed): return
	if not (is_clicked(event.position)): return
	
	click_particles.emitting = true
	click_particles.global_position = global_position
	click_particles.restart()
	
	match random_material:
		MaterialTypes.METAL:
			if metal_player_3d:
				metal_player_3d.play()
		MaterialTypes.PLASTIC:
			if plastic_player_3d:
				plastic_player_3d.play()
		MaterialTypes.WOOD:
			if wood_player_3d:
				wood_player_3d.play()
	
	var amount = small_material_gain if random_size == MaterialSizes.SMALL else big_material_gain
	
	if (random_size == MaterialSizes.BIG and click_counter < 5):
		click_counter += incrementer
		return
	
	process_collection(random_material, amount)

func is_clicked(screen_pos: Vector2) -> bool:
	var camera = get_viewport().get_camera_3d()
	if (not camera): return false
	
	var ray_from = camera.project_ray_origin(screen_pos)
	var ray_to = ray_from + camera.project_ray_normal(screen_pos) * RAY_LENGTH

	var query = PhysicsRayQueryParameters3D.create(ray_from, ray_to)
	query.collide_with_bodies = true
	
	var result = get_world_3d().direct_space_state.intersect_ray(query)
	
	return result and result.collider == self

func process_collection(type: MaterialTypes, amount: int):
	var inventory = InventoryManager.get_inventory()
	var inventory_limit = InventoryManager.get_inventory_limit()
	
	match type:
		MaterialTypes.METAL:
			if (inventory.metal == inventory_limit):
				return
			else:
				InventoryManager.adjust_resource("metal", amount)
		MaterialTypes.PLASTIC:
			if (inventory.plastic == inventory_limit):
				return
			else:
				InventoryManager.adjust_resource("plastic", amount)
		MaterialTypes.WOOD:
			if (inventory.wood == inventory_limit):
				return
			else:
				InventoryManager.adjust_resource("wood", amount)
	
	set_process(false)
	set_physics_process(false)
	collision_layer = 0
	
	for child in get_children():
		if (child is Node3D):
			child.hide()
	
	await get_tree().create_timer(2.0).timeout
	queue_free()
