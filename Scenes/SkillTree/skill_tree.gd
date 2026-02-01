extends Control


@onready var upgrade_manager: UpgradeManager = $"../UpgradeManager"

@onready var speed_label: RichTextLabel = %SpeedLabel
@onready var space_label: RichTextLabel = %SpaceLabel
@onready var light_label: RichTextLabel = $MarginContainer/ColorRect/VBoxContainer/MarginContainer/VBoxContainer/LightRow/MarginContainer/LightLabel

@onready var speed_button: Button = $MarginContainer/ColorRect/VBoxContainer/MarginContainer/VBoxContainer/SpeedRow/MarginContainer2/SpeedButton
@onready var space_button: Button = $MarginContainer/ColorRect/VBoxContainer/MarginContainer/VBoxContainer/SpaceRow/MarginContainer2/SpaceButton
@onready var light_button: Button = $MarginContainer/ColorRect/VBoxContainer/MarginContainer/VBoxContainer/LightRow/MarginContainer2/LightButton

@onready var button_click_player_2d: AudioStreamPlayer2D = $ButtonClickPlayer2D

var is_open: bool = false


func _ready() -> void:
	hide()
	is_open = false
	update_ui()

func _input(event: InputEvent) -> void:
	if (event.is_action_pressed("open_skill_tree")):
		toggle_skill_tree()
	
	if (event.is_action_pressed("exit")):
		is_open = false
		close_menu()

func _on_exit_button_pressed() -> void:
	toggle_skill_tree()

func _on_speed_button_pressed() -> void:
	button_click_player_2d.play()
	if upgrade_manager.upgrade_speed():
		update_ui()

func _on_space_button_pressed() -> void:
	button_click_player_2d.play()
	if upgrade_manager.upgrade_space():
		update_ui()

func _on_light_button_pressed() -> void:
	button_click_player_2d.play()
	if upgrade_manager.upgrade_light():
		update_ui()

func toggle_skill_tree() -> void:
	is_open = !is_open
	
	if (is_open):
		open_menu()
	else:
		close_menu()

func open_menu() -> void:
	button_click_player_2d.play()
	show()
	update_ui()

func close_menu() -> void:
	button_click_player_2d.play()
	hide()

func update_ui() -> void:
	update_buttons()
	update_texts()

func update_buttons() -> void:
	speed_button.disabled = upgrade_manager.get_speed_level() > 4
	space_button.disabled = upgrade_manager.get_space_level() > 4
	light_button.disabled = upgrade_manager.get_light_level() > 4
	pass

func update_texts() -> void:
	var speed_cost = upgrade_manager.get_speed_cost()
	speed_label.text = "Engine thrust (Cost: " + str(speed_cost) + " metal)"
	var space_cost = upgrade_manager.get_space_cost()
	space_label.text = "Cargo space (Cost: " + str(space_cost) + " plastic)"
	var light_cost = upgrade_manager.get_light_cost()
	light_label.text = "Depth light (Cost: " + str(light_cost) + " wood)"
