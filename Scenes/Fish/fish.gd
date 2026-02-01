extends CharacterBody3D


@onready var upgrade_manager: UpgradeManager = $"../../UpgradeManager"

@export var level: int = 1

@export_category("Variants")
@export var level_1_variants: Array[PackedScene]
@export var level_2_variants: Array[PackedScene]
@export var level_3_variants: Array[PackedScene]
@export var level_4_variants: Array[PackedScene]

var linear_velocity: Vector3 = Vector3.ZERO
var angular_velocity: Vector3 = Vector3.ZERO
var depth_level_variants = [level_1_variants, level_2_variants, level_3_variants, level_4_variants]


func _ready() -> void:
	var variants: Array[PackedScene] = []
	
	if level == 1:
		variants = level_1_variants
	elif level == 2:
		variants = level_2_variants
	elif level == 3:
		variants = level_3_variants
	elif level == 4:
		variants = level_4_variants
	
	if variants.is_empty(): return
	
	var scene: PackedScene = variants.pick_random()
	var instance: Node3D = scene.instantiate()
	
	add_child.call_deferred(instance)

func _physics_process(_delta: float) -> void:
	velocity = linear_velocity
	
	move_and_slide()
