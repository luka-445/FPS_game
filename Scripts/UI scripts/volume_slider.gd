extends HSlider

@export var busName : String

var busIndex : int

func _ready() -> void:
	value_changed.connect(_on_value_changed)
	busIndex = AudioServer.get_bus_index(busName)
	load_data()
	value = db_to_linear(AudioServer.get_bus_volume_db(busIndex))

func load_data() -> void:
	match busName:
		"Master":
			_on_value_changed(SettingsData.get_master_volume())
		"music":
			_on_value_changed(SettingsData.get_music_volume())
		"sfx":
			_on_value_changed(SettingsData.get_sfx_volume())
	
	
func _on_value_changed(value : float) -> void:
	AudioServer.set_bus_volume_db(busIndex, linear_to_db(value))
	match busName:
		"Master":
			SettingsSignalBus.emit_on_master_volume_changed(value)
		"music":
			SettingsSignalBus.emit_on_music_volume_changed(value)
		"sfx":
			SettingsSignalBus.emit_on_sfx_volume_changed(value)
