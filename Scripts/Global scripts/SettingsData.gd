extends Node

@onready var DEFAULT_SETTINGS : DefaultSettings = preload("res://Scripts/DefaultSettings.tres")

var mouseSens : float = 1.00
var masterVolume : float = 1.00
var musicVolume : float = 1.00
var sfxVolume  :float = 1.00

var loaded_settings : Dictionary = {}

func _ready():
	handle_signals()
	create_settings_dictionary()

func create_settings_dictionary() -> Dictionary:
	var settings_dict : Dictionary = {
		"mouse_sensitivity"  : mouseSens,
		"master_volume" : masterVolume,
		"music_volume" : musicVolume,
		"sfx_volume" : sfxVolume
	}
	
	return settings_dict

func load_settings(settings : Dictionary) -> void:
	loaded_settings = settings
	on_mouse_sensitivity_set(loaded_settings.mouse_sensitivity)
	on_master_volume_set(loaded_settings.master_volume)
	on_music_volume_set(loaded_settings.music_volume)
	on_sfx_volume_set(loaded_settings.sfx_volume)


func get_mouse_sensitivity() -> float:
	if loaded_settings == {}:
		return DEFAULT_SETTINGS.DEFAULT_MOUSE_SENSITIVITY
	
	return mouseSens

func get_master_volume() -> float:
	if loaded_settings == {}:
		return DEFAULT_SETTINGS.DEFAULT_MASTER_VOLUME
	
	return masterVolume

func get_music_volume() -> float:
	if loaded_settings == {}:
		return DEFAULT_SETTINGS.DEFAULT_MUSIC_VOLUME
	
	return musicVolume

func get_sfx_volume() -> float:
	if loaded_settings == {}:
		return DEFAULT_SETTINGS.DEFAULT_SFX_VOLUME
	
	return sfxVolume

func on_mouse_sensitivity_set(value : float) -> void:
	mouseSens = value

func on_master_volume_set(value : float) -> void:
	masterVolume = value

func on_music_volume_set(value : float) -> void:
	musicVolume = value

func on_sfx_volume_set(value : float) -> void:
	sfxVolume = value

func handle_signals() -> void:
	SettingsSignalBus.on_mouse_sensitivity_changed.connect(on_mouse_sensitivity_set)
	SettingsSignalBus.on_master_volume_changed.connect(on_master_volume_set)
	SettingsSignalBus.on_music_volume_changed.connect(on_music_volume_set)
	SettingsSignalBus.on_sfx_volume_changed.connect(on_sfx_volume_set)
	SettingsSignalBus.load_settings_dictionary.connect(load_settings)
