extends HSlider

func _ready():
	value_changed.connect(_on_value_changed)
	load_data()

func load_data():
	_on_value_changed(SettingsData.get_mouse_sensitivity())
	
func _on_value_changed(inputValue):
	value = inputValue
	SettingsSignalBus.emit_on_mouse_sensitivity_changed(value)
