extends Control


@onready var background_music: FmodEventEmitter2D = $"../MusicPlayer/BackgroundMusic"

var is_open: bool = false


# INTERNAL METHODS AND SIGNALS

func _ready() -> void:
	hide()
	is_open = false


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("open_skill_tree"): # Make sure "Tab" is mapped to this in Input Map
		toggle_skill_tree()


# UTILITY FUNCTIONS

func toggle_skill_tree() -> void:
	is_open = !is_open
	
	if (is_open):
		open_menu()
	else:
		close_menu()

func open_menu() -> void:
	show()
	background_music.set_parameter("menu_open", 1.0)

func close_menu() -> void:
	hide()
	background_music.set_parameter("menu_open", 0.0)
