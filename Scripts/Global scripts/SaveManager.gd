extends Node

const SETTINGS_SAVE_PATH : String = "user://SettingsData.save"

var settings_dict : Dictionary = {}

func _ready():
	SettingsSignalBus.update_settings_dictionary.connect(on_settings_save)
	load_settings_dictionary()
	

func on_settings_save(data : Dictionary) -> void:
	var save_settings_dict_file = FileAccess.open_encrypted_with_pass(SETTINGS_SAVE_PATH, FileAccess.WRITE, "vinc9926")
	
	var json_data_string = JSON.stringify(data)
	
	save_settings_dict_file.store_line(json_data_string)

func load_settings_dictionary() -> void:
	if not FileAccess.file_exists(SETTINGS_SAVE_PATH):
		return
	
	var save_settings_file = FileAccess.open_encrypted_with_pass(SETTINGS_SAVE_PATH, FileAccess.READ, "vinc9926")
	var loaded_data : Dictionary = {}
	
	while save_settings_file.get_position() < save_settings_file.get_length():
		var json_string = save_settings_file.get_line()
		var json = JSON.new()
		var _parsed_result = json.parse(json_string)
		
		loaded_data = json.get_data()
	
	SettingsSignalBus.emit_load_Settings_dictionary(loaded_data)
