class_name StartMenu
extends Control

@onready var play = $StartMenuContainer/PanelContainer/VBoxContainer/Play as Button
@onready var settings = $StartMenuContainer/PanelContainer/VBoxContainer/Settings as Button
@onready var quit = $StartMenuContainer/PanelContainer/VBoxContainer/Quit as Button
@onready var optionsMenu = $OptionsMenu as OptionsMenu
@onready var startMenuContainer = $StartMenuContainer as CenterContainer

func _ready():
	handle_signals()
	
func _on_play_button_pressed() -> void:
	get_tree().change_scene_to_file("res://levels/CountryHouse.tscn")

func _on_settings_button_pressed() -> void:
	startMenuContainer.visible = false
	optionsMenu.set_process(true)
	optionsMenu.visible = true

func _on_quit_button_pressed() -> void:
	get_tree().quit()
	
func _on_back_options_menu() -> void:
	startMenuContainer.visible = true
	optionsMenu.visible = false
	

func handle_signals():
	play.pressed.connect(_on_play_button_pressed)
	settings.pressed.connect(_on_settings_button_pressed)
	quit.pressed.connect(_on_quit_button_pressed)
	optionsMenu.exit_options_menu.connect(_on_back_options_menu)
