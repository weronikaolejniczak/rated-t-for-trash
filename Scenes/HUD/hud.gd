extends Control


@export var limit_color: Color = Color.GREEN
@export var default_color: Color = Color.BLACK

@export var player: RigidBody3D
@export var skill_tree_ui: Control
@export var music_player_2d: AudioStreamPlayer2D
@export var upgrade_manager: Node3D

@onready var volume_button: Button = %VolumeButton

@onready var depth_value: RichTextLabel = %DepthValue
@onready var metal_value: RichTextLabel = %MetalValue
@onready var plastic_value: RichTextLabel = %PlasticValue
@onready var wood_value: RichTextLabel = %WoodValue
@onready var gears_value: RichTextLabel = %GearsValue

@onready var metal_limit_icon: TextureRect = %MetalLimitIcon
@onready var plastic_limit_icon: TextureRect = %PlasticLimitIcon
@onready var wood_limit_icon: TextureRect = %WoodLimitIcon
@onready var gear_upgrade_icon: TextureRect = %GearUpgradeIcon

@onready var notification_player_2d: AudioStreamPlayer2D = $NotificationPlayer2D

const AUDIO_ON = preload("uid://cel8hcccex1xd")
const AUDIO_OFF = preload("uid://4l3nagq4y2qt")

var is_music_playing: bool = true

var materials_at_limit: Dictionary = {
	"metal": false,
	"plastic": false,
	"wood": false
}


func _process(_delta: float) -> void:
	var inventory = InventoryManager.get_inventory()
	var limit = InventoryManager.inventory_limit
	
	update_material_display("metal", inventory.metal, limit, metal_value, metal_limit_icon)
	update_material_display("plastic", inventory.plastic, limit, plastic_value, plastic_limit_icon)
	update_material_display("wood", inventory.wood, limit, wood_value, wood_limit_icon)
	update_depth_display(inventory.gears)

func update_depth_display(gear_amount: int) -> void:
	var depth = player.get_depth()
	var depth_level = upgrade_manager.get_depth_level()
	depth_value.text = str(depth) + "/" + str(depth_level * 100)
	gears_value.text = str(gear_amount)
	
	var is_at_limit = gear_amount == upgrade_manager.get_depth_cost()

	gear_upgrade_icon.visible = is_at_limit
	
	if is_at_limit:
		depth_value.set("theme_override_colors/default_color", limit_color)
		notification_player_2d.play()
	else:
		depth_value.set("theme_override_colors/default_color", default_color)

func update_material_display(material_name: String, current_value: int, limit: int, label_node: RichTextLabel, icon_node: TextureRect) -> void:
	label_node.text = "%d/%d" % [current_value, limit]

	var is_at_limit = (current_value == limit)

	icon_node.visible = is_at_limit

	if is_at_limit:
		label_node.set("theme_override_colors/default_color", limit_color)
	else:
		label_node.set("theme_override_colors/default_color", default_color)

	if is_at_limit and not materials_at_limit[material_name]:
		notification_player_2d.play()

	materials_at_limit[material_name] = is_at_limit

func _on_skill_tree_button_pressed() -> void:
	skill_tree_ui.toggle_skill_tree()

func _on_volume_button_pressed() -> void:
	if is_music_playing:
		music_player_2d.volume_linear = 0
		is_music_playing = false
		volume_button.icon = AUDIO_OFF
	else:
		music_player_2d.volume_linear = 1
		is_music_playing = true
		volume_button.icon = AUDIO_ON
