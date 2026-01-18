extends Control


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

func _on_skill_tree_button_pressed() -> void:
	skill_tree_ui.toggle_skill_tree()
