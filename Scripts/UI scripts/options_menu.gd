class_name OptionsMenu
extends Control

@onready var back = $OptionsMenu/PanelContainer/VBoxContainer/Back as Button

signal exit_options_menu

func _ready():
	back.pressed.connect(on_back_pressed)
	set_process(false)
	
func on_back_pressed() -> void:
	exit_options_menu.emit()
	SettingsSignalBus.emit_update_settings_dictionary(SettingsData.create_settings_dictionary())
	set_process(false)
