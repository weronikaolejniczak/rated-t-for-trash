extends Control


@export var red_color: Color = Color.RED
@export var black_color: Color = Color.BLACK

@onready var player: Player = $"../Player"
@onready var skill_tree_ui: Control = $"../SkillTreeUI"

@onready var depth_value: RichTextLabel = $BottomLeftHUD/HBoxContainer/DepthMeter/TextContainer/Value
@onready var metal_value: RichTextLabel = $BottomLeftHUD/HBoxContainer/Inventory_Metal/TextContainer/Value
@onready var plastic_value: RichTextLabel = $BottomLeftHUD/HBoxContainer/Inventory_Plastic/TextContainer/Value
@onready var wood_value: RichTextLabel = $BottomLeftHUD/HBoxContainer/Inventory_Wood/TextContainer/Value


func format_value(value: int) -> String:
	return str(value) + "/" + str(player.inventory_limit)

func _process(_delta: float) -> void:
	var depth = player.get_depth()
	var inventory = Player.get_inventory()
	
	depth_value.text = str(depth)
	metal_value.text = format_value(inventory.metal)
	plastic_value.text = format_value(inventory.plastic)
	wood_value.text = format_value(inventory.wood)
	
	if (inventory.metal == player.inventory_limit):
		metal_value.set("theme_override_colors/default_color", red_color)
	else:
		metal_value.set("theme_override_colors/default_color", black_color)
	
	if (inventory.plastic == player.inventory_limit):
		plastic_value.set("theme_override_colors/default_color", red_color)
	else:
		plastic_value.set("theme_override_colors/default_color", black_color)
	
	if (inventory.wood == player.inventory_limit):
		wood_value.set("theme_override_colors/default_color", red_color)
	else:
		wood_value.set("theme_override_colors/default_color", black_color)

func _on_skill_tree_button_pressed() -> void:
	skill_tree_ui.toggle_skill_tree()
