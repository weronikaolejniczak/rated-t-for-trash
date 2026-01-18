extends StaticBody3D


enum MaterialTypes { METAL, PLASTIC, WOOD }
enum MaterialSizes { SMALL, BIG }

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

@onready var player: Player = $"../../Player"
@onready var recycling_sfx: FmodEventEmitter3D = $RecyclingSFX

var velocity: Vector3 = Vector3.ZERO
var angular_velocity: Vector3 = Vector3.ZERO
var random_material: MaterialTypes
var random_size: MaterialSizes
var click_counter: int = 0

const RAY_LENGTH = 1000.0


# INTERNAL METHODS AND SIGNALS

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
	
	recycling_sfx.set_parameter("recycle", MaterialTypes.find_key(random_material).to_lower())
	
	var variants: Array[PackedScene] = materials[random_material][random_size]
	if (variants.is_empty()): return push_error("Exported array is empty!")
	
	var scene: PackedScene = variants.pick_random()
	var instance: Node3D = scene.instantiate()
	add_child.call_deferred(instance)
	
	for child in instance.get_children():
		if (child is CollisionShape3D):
			child.reparent.call_deferred(self)

func _process(delta: float) -> void:
	global_translate(velocity * delta)
	
	rotate_x(angular_velocity.x * delta)
	rotate_y(angular_velocity.y * delta)
	rotate_z(angular_velocity.z * delta)

func _input(event):
	if not (event is InputEventMouseButton and event.pressed): return
	if not (_is_clicked(event.position)): return
	
	recycling_sfx.play(true)
	
	var amount = small_material_gain if random_size == MaterialSizes.SMALL else big_material_gain
	
	if (random_size == MaterialSizes.BIG and click_counter < 5):
		click_counter += incrementer
		return
	
	_process_collection(random_material, amount)


# UTILITY FUNCTIONS

func _destroy() -> void:
	for node in get_children():
		node.queue_free()

func _is_clicked(screen_pos: Vector2) -> bool:
	var camera = get_viewport().get_camera_3d()
	if (not camera): return false
	
	var ray_from = camera.project_ray_origin(screen_pos)
	var ray_to = ray_from + camera.project_ray_normal(screen_pos) * RAY_LENGTH

	var query = PhysicsRayQueryParameters3D.create(ray_from, ray_to)
	query.collide_with_bodies = true
	
	var result = get_world_3d().direct_space_state.intersect_ray(query)
	
	return result and result.collider == self

func _process_collection(type: MaterialTypes, amount: int):
	var inventory = Player.get_inventory()
	var inventory_limit = Player.get_inventory_limit()
	
	match type:
		MaterialTypes.METAL:
			if (inventory.metal < inventory_limit):
				Player.adjust_resource("metal", amount)
				_destroy()
		MaterialTypes.PLASTIC:
			if (inventory.plastic < inventory_limit):
				Player.adjust_resource("plastic", amount)
				_destroy()
		MaterialTypes.WOOD:
			if (inventory.wood < inventory_limit):
				Player.adjust_resource("wood", amount)
				_destroy()
