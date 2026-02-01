extends Control


@export var limit_color: Color = Color.GREEN
@export var default_color: Color = Color.BLACK

@onready var player: RigidBody3D = $"../Player"
@onready var skill_tree_ui: Control = $"../SkillTreeUI"
@onready var music_player_2d: AudioStreamPlayer2D = $"../Player/MusicPlayer2D"
@onready var volume_button: Button = %VolumeButton

@onready var depth_value: RichTextLabel = %DepthValue
@onready var metal_value: RichTextLabel = %MetalValue
@onready var plastic_value: RichTextLabel = %PlasticValue
@onready var wood_value: RichTextLabel = %WoodValue

@onready var metal_limit_icon: TextureRect = %MetalLimitIcon
@onready var plastic_limit_icon: TextureRect = %PlasticLimitIcon
@onready var wood_limit_icon: TextureRect = %WoodLimitIcon

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
	var depth = player.get_depth()
	depth_value.text = str(depth)
	
	var inventory = player.get_inventory()
	var limit = player.inventory_limit
	
	_update_material_display("metal", inventory.metal, limit, metal_value, metal_limit_icon)
	_update_material_display("plastic", inventory.plastic, limit, plastic_value, plastic_limit_icon)
	_update_material_display("wood", inventory.wood, limit, wood_value, wood_limit_icon)


func _update_material_display(material_name: String, current_value: int, limit: int, label_node: RichTextLabel, icon_node: TextureRect) -> void:
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
