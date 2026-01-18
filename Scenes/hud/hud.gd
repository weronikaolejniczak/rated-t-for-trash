extends Control

@onready var player: Player = $"../Player"

@onready var depth_value: RichTextLabel = $BottomLeftHUD/HBoxContainer/DepthMeter/TextContainer/Value
@onready var metal_value: RichTextLabel = $BottomLeftHUD/HBoxContainer/Inventory_Metal/TextContainer/Value
@onready var plastic_value: RichTextLabel = $BottomLeftHUD/HBoxContainer/Inventory_Plastic/TextContainer/Value
@onready var wood_value: RichTextLabel = $BottomLeftHUD/HBoxContainer/Inventory_Wood/TextContainer/Value

func format_value(value: int) -> String:
	var inventory_limit = Player.get_inventory_limit()
	return str(value) + "/" + str(inventory_limit)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	var depth = player.get_depth()
	var inventory = Player.get_inventory()
	
	depth_value.text = str(depth)
	metal_value.text = format_value(inventory.metal)
	plastic_value.text = format_value(inventory.plastic)
	wood_value.text = format_value(inventory.wood)
