extends Control
@onready var startMenu = preload("res://Scenes/UI/start_menu.tscn") as PackedScene
@onready var country_house = $"../.."
@onready var optionsMenu = $OptionsMenu
@onready var pauseMenu = $PauseMenu

var paused : bool = false:
	set = set_paused

func _ready():
	optionsMenu.exit_options_menu.connect(_on_back_options_menu)

func _unhandled_input(event):
	if event.is_action_pressed("pause"):
		paused = !paused

func set_paused(value : bool) -> void:
	paused = value
	get_tree().paused = paused
	visible = paused 
	
	if visible == true:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	else:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _on_continue_pressed():
	paused = false


func _on_settings_pressed():
	pauseMenu.visible = false
	optionsMenu.set_process(true)
	optionsMenu.visible = true

func _on_back_options_menu() -> void:
	pauseMenu.visible = true
	optionsMenu.visible = false

func _on_quit_pressed():
	get_tree().change_scene_to_packed(startMenu)
