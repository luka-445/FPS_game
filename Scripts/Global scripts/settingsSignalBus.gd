extends Node

signal on_mouse_sensitivity_changed(value : float)
signal on_master_volume_changed(value : float)
signal on_music_volume_changed(value : float)
signal on_sfx_volume_changed(value : float)

signal update_settings_dictionary(settings_dict : Dictionary)

signal load_settings_dictionary(settings_dict : Dictionary)

func emit_load_Settings_dictionary(settings_dict : Dictionary) -> void:
	load_settings_dictionary.emit(settings_dict)

func emit_update_settings_dictionary(settings_dict : Dictionary):
	update_settings_dictionary.emit(settings_dict)

func emit_on_mouse_sensitivity_changed(value : float) -> void:
	on_mouse_sensitivity_changed.emit(value)

func emit_on_master_volume_changed(value : float) -> void:
	on_master_volume_changed.emit(value)

func emit_on_music_volume_changed(value : float) -> void:
	on_music_volume_changed.emit(value)

func emit_on_sfx_volume_changed(value : float) -> void:
	on_sfx_volume_changed.emit(value)
