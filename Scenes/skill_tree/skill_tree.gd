extends Control

@onready var speed_label: RichTextLabel = $MarginContainer/ColorRect/VBoxContainer/MarginContainer/VBoxContainer/SpeedRow/MarginContainer/RichTextLabel
@onready var space_label: RichTextLabel = $MarginContainer/ColorRect/VBoxContainer/MarginContainer/VBoxContainer/SpaceRow/MarginContainer/RichTextLabel
@onready var light_label: RichTextLabel = $MarginContainer/ColorRect/VBoxContainer/MarginContainer/VBoxContainer/LightRow/MarginContainer/RichTextLabel
@onready var speed_button: Button = $MarginContainer/ColorRect/VBoxContainer/MarginContainer/VBoxContainer/SpeedRow/MarginContainer2/SpeedButton
@onready var space_button: Button = $MarginContainer/ColorRect/VBoxContainer/MarginContainer/VBoxContainer/SpaceRow/MarginContainer2/SpaceButton
@onready var light_button: Button = $MarginContainer/ColorRect/VBoxContainer/MarginContainer/VBoxContainer/LightRow/MarginContainer2/LightButton
@onready var player: Player = $"../Player"

var is_open: bool = false


# INTERNAL METHODS AND SIGNALS

func _ready() -> void:
	hide()
	is_open = false
	update_ui()

func _process(_delta: float) -> void:
	pass # Replace with function body.

func _input(event: InputEvent) -> void:
	if (event.is_action_pressed("open_skill_tree")):
		toggle_skill_tree()
	
	if (event.is_action_pressed("exit")):
		is_open = false
		close_menu()


# UPGRADE BUTTONS

func _on_exit_button_pressed() -> void:
	toggle_skill_tree()

func _on_speed_button_pressed() -> void:
	if player.upgrade_speed():
		update_ui()

func _on_space_button_pressed() -> void:
	if player.upgrade_space():
		update_ui()

func _on_light_button_pressed() -> void:
	if player.upgrade_light():
		update_ui()


# UTILITY FUNCTIONS

func toggle_skill_tree() -> void:
	is_open = !is_open
	
	if (is_open):
		open_menu()
	else:
		close_menu()

func open_menu() -> void:
	show()
	update_ui()

func close_menu() -> void:
	hide()

func update_ui() -> void:
	update_buttons()
	update_texts()

func update_buttons() -> void:
	speed_button.disabled = player.get_speed_level() > 4
	space_button.disabled = player.get_space_level() > 4
	light_button.disabled = player.get_light_level() > 4
	pass

func update_texts() -> void:
	var speed_cost = player.get_speed_cost()
	speed_label.text = "Engine thrust (Cost: " + str(speed_cost) + " metal)"
	var space_cost = player.get_space_cost()
	space_label.text = "Cargo space (Cost: " + str(space_cost) + " plastic)"
	var light_cost = player.get_light_cost()
	light_label.text = "Depth light (Cost: " + str(light_cost) + " wood)"
